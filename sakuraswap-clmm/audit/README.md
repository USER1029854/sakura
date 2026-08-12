# SakuraSwap CLMM — security audit artifacts

Companion to the contract inventory in `../`. Defensive review only.

## Verdict

**INCONCLUSIVE for the protocol as a whole — zero qualifying findings in the analyzed
remainder.** 88.8% of protocol-scale TVL was enumerated upstream ($1,566,394 of
$1,764,930). Every analyzed value and authority path is sound, proven by 9 passing fork
tests against the real deployed contracts.

The verdict is capped at INCONCLUSIVE — not clean — for two reasons, neither of which is a
weakness found in the visible code:

1. The **Redstone factory** (`0xece75613…83Bb`, ~$27,589 last known) could not be analyzed
   at all — its chain was decommissioned 2026-05-15 and no bytecode is retrievable.
2. **90.3% of the analyzed TVL sits on Abstract, which cannot be executed against.**
   Abstract is a zkSync/EraVM-stack chain; standard Foundry cannot interpret its bytecode
   (see `poc/AbstractFork.t.sol` — every call returns `ok=true` with 0-length returndata).

## Headline result: the code is unmodified Uniswap V3

All 619 `.sol` files in the inventory are canonical Uniswap V3. 563 are byte-identical to
`v3-core` / `v3-periphery` v1.0.0. The 16 that differ do so **only** in pragma upper bounds
(`>=0.5.0` vs `>=0.5.0 <0.8.0`) and NatSpec comments — both semantically inert, incapable of
affecting deployed bytecode. Three periphery files use `public` where v1.0.0 used
`external`, matching later official Uniswap releases.

**There are zero semantic fork modifications** — the usual place a fork bug lives is empty.

## Bounded blast radius on the Abstract EOA owner

Abstract's factory `owner()` is a plain EOA (single key) controlling 13 pools holding
~$1.52M. Established by execution, not inspection: `collectProtocol` is hard-clamped to
`protocolFees.token0/1`, so **even total compromise of that key cannot reach LP principal** —
only fees accruing after the change. With `feeProtocol` maxed (1/4) and real swap volume
generated, the owner extracted 0.0015 WETH from a pool holding 11.7 WETH.

## Invariants tested (all PASS, real deployed contracts, Ink fork)

| # | Invariant | File |
|---|---|---|
| INV1 / INV1b | Factory-owner extraction bounded to accrued protocol fees | `poc/Adversarial.t.sol` |
| INV2 | Unprivileged callers rejected by every authority path | `poc/Adversarial.t.sol` |
| INV3 | Position key binds to `msg.sender`; foreign positions revert `NP` | `poc/Adversarial.t.sol` |
| INV4 | Raw-balance donation doesn't move accounting basis, not recoverable | `poc/Adversarial.t.sol` |
| INV5 | `lock` blocks reentrancy during callbacks | `poc/Adversarial.t.sol` |
| ISO1 | Hostile token cannot reach a pool it is not a member of | `poc/HostileToken.t.sol` |
| ISO2 | Lying-token damage confined to its own pool's counterparty capital | `poc/HostileToken.t.sol` |
| SEAM | Periphery↔core `POOL_INIT_CODE_HASH` reproduces the real pool | `poc/InkSeam.t.sol` |

V3 reads live `balanceOf` in `mint`/`flash` and never caches reserves, so the V2-style
cached-reserve-vs-real-balance desync class cannot exist here.

## Reproducing

```bash
forge init --no-git /tmp/audit && cd /tmp/audit
cp <this-dir>/poc/*.t.sol test/

# The 8 invariant + seam tests (all must pass):
forge test --fork-url https://rpc-gel.inkonchain.com \
  --match-path "test/{Adversarial,HostileToken,InkSeam}.t.sol" -vv

# Demonstrates Abstract cannot be executed against (informational):
forge test --fork-url https://api.mainnet.abs.xyz \
  --match-contract AbstractForkTest -vv
```

Verified with forge 1.5.1-stable. Ink fork tests hit live state; exact balances drift, and
`test_INV1b` asserts relative bounds rather than absolute figures for that reason.

## Contingencies — read before relying on the zero

- **zksolc v1.3.13 correctness is assumed and untested** (affects $1.52M). Abstract's source
  is verified identical to canonical; its compiled semantics are not independently verified
  and could not be here. If zksolc miscompiled any pool logic, every Abstract conclusion
  flips.
- **Token contracts are referenced but ABSENT from the inventory.** 5 of the 8 tokens
  backing the largest pools are upgradeable proxies: USDC.e, absETH, MIRAI, USDT, and
  YGG + GUILD — the latter two **sharing one beacon implementation
  (`0x05b00ef3489e21e57b3e93a72bc9f59c57bb199b`)**, a single upgrade authority across ~$622k
  of pool value. A token upgrade admin can rewrite `balanceOf`/`transfer` and drain the
  honest counterparty asset from any pool their token sits in. This is a privileged
  third-party action, so it does not clear the unprivileged-attacker bar — but pool solvency
  is contingent on these absent contracts, and they are not asserted honest here.
- **ZERO Network authority state is unverified** — `owner()` unreadable (RPC rejects
  `eth_call`); parity with Abstract assumed, not proven.
- **Scope**: on-chain code only. Key compromise, signer leakage, insider action and
  off-chain infrastructure account for most stolen value industry-wide and are not
  analyzable here — particularly relevant given Abstract's single-EOA owner and the L1
  Timelock admin behind Ink, which was not traced. A clean result on the analyzed code is
  not a statement that the protocol is safe.
