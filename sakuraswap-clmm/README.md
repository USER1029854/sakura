# SakuraSwap CLMM — contract inventory (defensive review)

**Protocol:** SakuraSwap CLMM
**DefiLlama:** https://defillama.com/protocol/sakuraswap-clmm
**Website:** https://sakuraswap.com/
**Category:** Dexs — "Uniswap V3 fork" (per DefiLlama's own description)
**DefiLlama module:** `reservoir-tools-v3/index.js`, parent protocol `sakuraswap`
**Chains:** Abstract, Ink, ZERO Network, Redstone (Redstone's chain is **permanently shut
down** as of 2026-05-15 — see below)

This is an **inventory only** — no vulnerability analysis, no exploit instructions. It
enumerates every deployed contract that holds or controls ≥$10,000 of this protocol's funds
on every chain it has ever run on, going beyond what DefiLlama's own TVL adapter tracks so
that deprecated/legacy/unverified contracts that still hold funds are not missed.

## Scope note: SakuraSwap has three DefiLlama listings — this review covers CLMM only
The DefiLlama parent `sakuraswap` has three child protocols: **SakuraSwap** (aggregate),
**SakuraSwap AMM** (`module: reservoir-tools-v2`, a Uniswap V2-style constant-product fork,
own factory/pair contracts, chains Ink/Abstract/ZERO Network), and **SakuraSwap CLMM**
(`module: reservoir-tools-v3`, the Uniswap V3-style concentrated-liquidity fork this review
covers). AMM and CLMM use **completely separate factory and pool contracts** — confirmed by
diffing the two DefiLlama adapter configs. AMM contracts are out of scope and not inventoried
here.

## Chains this protocol runs on, and the factory found on each
| Chain | Chain ID | Factory address | Status |
|---|---|---|---|
| Abstract | 2741 | `0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1` | Live, dominant chain |
| Ink | 57073 | `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424` | Live |
| ZERO Network | 543210 | `0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1` (same address as Abstract, separate deployment, same deployer EOA) | Live, minimal TVL |
| Redstone | 690 | `0xece75613Aa9b1680f0421E5B2eF376DF68aa83Bb` | **Chain shut down 2026-05-15** — unreachable |

Current DefiLlama-reported TVL by chain (fetched 2026-08-12): Abstract $1,678,480.90, Ink
$57,610.48, ZERO Network $1,249.48, Redstone $0 (last non-zero reading was **$27,589** on
2026-05-22, the day before the chain went dark — see Redstone section).

Every factory address above was obtained from DefiLlama's own TVL-adapter source
(`DefiLlama-Adapters/registries/uniswapV3.js`, key `reservoir-tools-v3`) — this is the
canonical mapping DefiLlama itself uses to compute this protocol's TVL, so it is treated as
ground truth for "where does this protocol's factory live."

## Biggest funded contract found
**Pool `0x157beaa1c7dcc2aad79846ec693c558609ebc0ea` on Abstract** (WETH/YGG, 0.3% fee tier)
— **≈$526,517** (134.05 WETH ≈ $251,661 + 14.65M YGG ≈ $274,856). See
`contracts/abstract/Pool_0x157beaa1/analysis.md`.

---

## Included contracts

### Abstract (13 pools + 1 factory)
| Contract | Role | ≈USD held/controlled | Folder |
|---|---|---|---|
| Pool 0x157beaa1c7dcc2aad79846ec693c558609ebc0ea (WETH/YGG 0.3%) | pool/vault | $526,517 | `contracts/abstract/Pool_0x157beaa1/` |
| Pool 0x7c72570fda921aac316bcef81c0e683904a72d30 (WETH/USDC.e 0.05%) | pool/vault | $369,583 | `contracts/abstract/Pool_0x7c72570f/` |
| Pool 0xda7d037fda848177141e037f9d0c67cae7b53262 (WETH/PENGU 0.3%) | pool/vault | $320,499 | `contracts/abstract/Pool_0xda7d037f/` |
| Pool 0xd992548ee7f02147e4f1695ac72011f7421f7ad0 (USDC.e/GUILD 0.3%) | pool/vault | $95,920 | `contracts/abstract/Pool_0xd992548e/` |
| Pool 0x7135310c271ad682b623e6f346a0b77395d8bcca (USDC.e/PENGU 0.01%) | pool/vault | $38,125 | `contracts/abstract/Pool_0x7135310c/` |
| Pool 0xf9b8af78cfdeadb502a0b9d3d5712ffcde707860 (USDT/USDC.e 0.01%) | pool/vault | $38,015 | `contracts/abstract/Pool_0xf9b8af78/` |
| Pool 0x3bc14f6e54a44199d00bc472b4430fc498bfa416 (WETH/absETH 0.3%) | pool/vault | $27,542 | `contracts/abstract/Pool_0x3bc14f6e/` |
| Pool 0xb6dfd127aa4f90172cf26f45e3ed127efde55c69 (USDT/PENGU 0.01%) | pool/vault | $26,847 | `contracts/abstract/Pool_0xb6dfd127/` |
| Pool 0x2fa6cad879e7c504bc1499c62b6d9dc7cd13c719 (WETH/MIRAI 1%) | pool/vault | $20,104 | `contracts/abstract/Pool_0x2fa6cad8/` |
| Pool 0x8fb483dcb266d95e8ab6dac3cf9062dd9b7e24ce (USDT/WETH 0.3%) | pool/vault | $16,199 | `contracts/abstract/Pool_0x8fb483dc/` |
| Pool 0xf973bac8b0cabf7d33b6e367ca1d581cee2d52ae (GRIND/WETH 1%) | pool/vault | $13,071 | `contracts/abstract/Pool_0xf973bac8/` |
| Pool 0x936276f26e35a15efb56bceee05f959a37895007 (USDT/USDC.e 0.05%) | pool/vault | $12,983 | `contracts/abstract/Pool_0x936276f2/` |
| Pool 0xe089d0c10d8d576430c97bda83acdcb142beb3e8 (WETH/USDC.e 0.3%) | pool/vault | $10,918 | `contracts/abstract/Pool_0xe089d0c1/` |
| Factory 0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1 | admin/governance | $0 direct / controls all 13 above | `contracts/abstract/UniswapV3Factory_0xA1160e73/` |

**Sum of included Abstract pools: ≈$1,516,323** (vs. DefiLlama's $1,678,481 chain total; the
≈$162k difference is spread thinly across ~6,650 dropped dust pools — see
`contracts/abstract/DROPPED_POOLS.md`).

Abstract factory governance: `owner()` = `0x2bad8182c09f50c8318d769245bea52c32be46cd`, a
**plain EOA** (no contract code) — single private key controls fee tiers, ownership
transfer, and protocol-fee collection across every pool on this chain.

### Ink (2 pools + 1 factory)
| Contract | Role | ≈USD held/controlled | Folder |
|---|---|---|---|
| Pool 0xd5aa1bd330a94332f071da5bb3651ec372ea6926 (WETH/USDC.e 0.3%) | pool/vault | $34,603 | `contracts/ink/Pool_0xd5aa1bd3/` |
| Pool 0xc6d49c16129071e21aeea0beef86d9054f89e5a6 (USDT0/USDC.e 0.3%) | pool/vault | $15,467 | `contracts/ink/Pool_0xc6d49c16/` |
| Factory 0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424 | admin/governance | $0 direct / controls both pools above (and 1,871 dropped pools) | `contracts/ink/UniswapV3Factory_0x640887A9/` |

**Sum of included Ink pools: ≈$50,071** (vs. DefiLlama's $57,610 chain total; the ≈$7.5k
difference is spread thinly across ~1,871 dropped dust pools — see
`contracts/ink/DROPPED_POOLS.md`). 1,873 total pools were discovered and every single one
was checked against three anchor-token balances (WETH, the bridged USDC.e actually used
here, and USDT0) via exhaustive `Multicall3` scans across the full set.

Factory `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`, `owner()` =
`0x66c5d722fc52671c7f839bbbf752bc38e0520b91`, a **verified contract named
`CrossChainAccount`** (not an EOA, not a standard multisig). Its constructor args (read via
Blockscout) name `_messenger = 0x4200000000000000000000000000000000000007` (Ink's standard
OP-Stack `L2CrossDomainMessenger` predeploy) and `_l1Owner =
0x1a9C8182C09F50C8318d769245beA52c32BE35BC` — i.e. governance is relayed from **Ethereum L1**
via the canonical OP-Stack bridge. That L1 address was checked directly on Ethereum mainnet
(`eth_getCode` via Etherscan V2, chainid=1): it **is a contract**, and its bytecode contains
the literal revert strings `"Timelock::executeTransaction: Call must come from admin."` /
`"Timelock::queueTransaction: Call must come from admin."` etc. — i.e. it is a **Compound-style
Timelock contract on Ethereum mainnet**. The Timelock's own admin (who can queue/execute
transactions through it) was not further traced — see COULD-NOT-ENUMERATE. Note also the
partial address similarity between this L1 owner (`0x1a9c8182c09f50c8318d769245bea52c32be35bc`)
and the Abstract factory's owner EOA (`0x2bad8182c09f50c8318d769245bea52c32be46cd`) — both
share the substring `82c09f50c8318d769245bea52c32be`, consistent with vanity-address mining
by the same operator, though this is a pattern observation, not proof of common control.

### ZERO Network (factory only — no pool crosses $10k)
| Contract | Role | ≈USD held/controlled | Folder |
|---|---|---|---|
| Factory 0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1 | admin/governance | $0 direct; controls 35 pools, largest ≈$3,199 | `contracts/zero-network/UniswapV3Factory_0xA1160e73/` |

All 35 pools deployed on this chain were individually enumerated and priced — every single
one is below the $10k bar (largest ≈$3,199). Full table:
`contracts/zero-network/ALL_POOLS_DROPPED_below_10k.md`. The factory itself is included
under the "controls funds" criterion even though its own balance is $0 and none of its pools
individually qualifies, because it is the sole governance point for all 35 (and any future)
pools on this chain.

### Redstone — chain shut down, factory address documented, nothing else obtainable
| Contract | Role | ≈USD held/controlled | Folder |
|---|---|---|---|
| Factory 0xece75613Aa9b1680f0421E5B2eF376DF68aa83Bb | admin/governance (presumed, unconfirmed) | Last known aggregate for this chain ≈$27,589 (2026-05-22); per-pool breakdown unobtainable | `contracts/redstone/UniswapV3Factory_0xece75613/` |

Redstone (Lattice's MUD-focused OP-Stack L2, chain ID 690) was **permanently shut down on
2026-05-15 23:59 UTC**. Lattice's own shutdown announcement explicitly warned that funds
"held in contracts like Uniswap pools" would **not** be covered by the post-shutdown L1
EOA-balance recovery path. DefiLlama's historical TVL series for this protocol on Redstone
shows a steady ~$25.5k–$29.8k through 2026-05-22, then flat, unchanging $0 every day from
2026-05-23 through 2026-08-12 (today) — consistent with the data source going dark, not a
genuine gradual withdrawal. No RPC endpoint or block explorer for chain ID 690 was reachable
from this environment after extensive attempts (see COULD-NOT-ENUMERATE); no bytecode, no
source, no decompilation was possible. The factory is still **included** (not dropped) on
the strength of the last observed ~$27.6k aggregate, which is well above the $10k bar and for
which there is no evidence of a legitimate withdrawal before the cutoff.

---

## Dropped contracts and exact reasons

| Contract | Chain | Reason dropped |
|---|---|---|
| 6,650 of 6,663 pools created by the Abstract factory | Abstract | Holds < $10,000 — see `contracts/abstract/DROPPED_POOLS.md` for full methodology and `data/abstract_all_pools_raw.json` / `data/abstract_weth_balance_scan_raw.json` for the complete balance evidence on every pool |
| 1,871 of 1,873 pools created by the Ink factory | Ink | Holds < $10,000 — see `contracts/ink/DROPPED_POOLS.md` for full methodology and `data/ink_all_pools_raw.json` / `data/ink_weth_balance_scan_raw.json` / `data/ink_usdce_balance_scan_raw.json` / `data/ink_usdt0_balance_scan_raw.json` for the complete balance evidence on every pool |
| All 35 pools created by the ZERO Network factory | ZERO Network | Holds < $10,000 — see `contracts/zero-network/ALL_POOLS_DROPPED_below_10k.md` (full table, every pool individually priced) |
| NonfungiblePositionManager `0xC0836E5B058BBE22ae2266e1AC488A1A0fD8DCE8` | Ink | Holds < $10,000 — only two unpriced spam/airdrop tokens ($0 real value); does not structurally custody or control pool reserves in the Uniswap V3 design. See `contracts/ink/NonfungiblePositionManager_0xC0836E5B_DROPPED_below_threshold/DROPPED.md` |
| SakuraSwap **AMM** factory/pair contracts (sibling protocol, `reservoir-tools-v2`) | Ink, Abstract, ZERO Network | Unrelated to protocol funds **for this review's scope** — a distinct DefiLlama-listed protocol (SakuraSwap AMM) with its own separate factory and pair contracts, not part of "SakuraSwap CLMM" |
| Unverified contract `0x1eAaf56A63314829221b56AC0C217aDA1FA3cC06` (Ink) | Ink | Called the Ink factory internally but holds $0 (native and token balances both zero); not investigated further |

---

## COULD-NOT-ENUMERATE — every place this search may be incomplete

1. **Redstone chain is fully unreachable — the single largest gap.** No RPC endpoint (14
   candidates tried: official `rpc.redstonechain.com`, 1rpc, Ankr, Tenderly, thirdweb,
   meowrpc, gateway.fm, BlockPI, Conduit, zan.top, Alchemy/Blast/Chainstack/Stackup
   chain-specific subdomains) and no block explorer (`explorer.redstone.xyz`, Cloudflare
   1014/403 on every attempt including via an independent fetch path) could be reached. Only
   the factory address and DefiLlama's historical TVL series are available. **No pool
   addresses, no bytecode, no source, no per-contract balances for this chain could be
   obtained by anyone** — the chain's infrastructure is decommissioned, not merely blocked
   from this sandbox. The last known aggregate (~$27.6k, 2026-05-22) is presumed to still be
   real and unrecoverable, per Lattice's own shutdown notice, but this is inference, not
   direct verification.

2. **ZERO Network: `eth_call` and `eth_getStorageAt` are blocked on the only reachable RPC.**
   `https://explorer.zero.network/api/eth-rpc` serves `eth_getLogs`/`eth_getBalance`/
   `eth_blockNumber` (used to fully enumerate and price all 35 pools) but returns `500` for
   `eth_call`/`eth_getStorageAt`. Consequences: (a) the factory's `owner()` could not be read
   for this specific deployment — governance parity with Abstract's factory is *assumed* via
   identical bytecode but not proven for the owner slot, which is mutable per-chain state;
   (b) no periphery contracts (position manager, router) were found via Blockscout's
   contract-name search on this chain (search returned zero results), but this could reflect
   genuinely minimal deployment rather than an exhaustive negative.

3. **Abstract: the long tail beyond ~20 pools (by WETH balance) was bounded, not individually
   re-priced.** See `contracts/abstract/DROPPED_POOLS.md` for the exact methodology and why
   the bound is sound (DefiLlama's own per-token USD aggregates cap every un-included token
   symbol below $10k across *all* of its pools combined). Two specific non-WETH pools
   (AMY/USDT and MLP/USDC.e) contain a token with no DefiLlama price feed at all, paired
   against a de-minimis priced-token amount ($577 and $1,460) — treated as below threshold
   on strong circumstantial grounds, not a directly priced certainty.

4. **Ink: same bound methodology as Abstract, but without a DefiLlama per-token
   cross-check.** All 1,873 pools were scanned across three anchor tokens (WETH, USDC.e,
   USDT0) via `Multicall3`. The 17 pools touching *none* of those three anchors were then
   checked exhaustively (both token balances read directly, both symbols resolved) rather
   than assumed safe — this actually turned up two BTC-pegged pools (brBTC/uniBTC and
   kBTC/uniBTC) that looked concerning by raw integer balance until decimals (8) and live
   BTC-scale prices (~$62–63k/token) were applied, resolving to ~$126 and ~$139 respectively;
   every other non-anchor pool held test/placeholder tokens (`Test`, `MTK`, `TK01`/`TK02`,
   etc.) with de-minimis or zero balances. Unlike Abstract, DefiLlama's API did not return a
   populated per-token USD breakdown for Ink at review time, so this exhaustive pass (rather
   than a DefiLlama cross-check) is the sole evidence backing the Ink drop list — considered
   solid since it covers 100% of pools, not a sample.

5. **Periphery contracts (SwapRouter, Quoter, Migrator, TickLens) were not conclusively
   identified on any chain.** On Ink, 5 verified `NonfungiblePositionManager` and 9 verified
   `SwapRouter` template deployments exist from *other* protocols reusing the same
   `reservoir-tools-v3` template; only the position manager wired to SakuraSwap's own factory
   (via constructor-arg matching) was positively identified — no SwapRouter with a matching
   constructor arg was found among the 9 checked. On Abstract, the explorer's frontend
   (`explorer.mainnet.abs.xyz`) does not expose a working contract-search API from this
   environment (serves the SPA shell for `/api/v2/search` and `/api/v2/stats`; only
   `/api/v2/addresses/{addr}` and `/api/v2/smart-contracts/{addr}` work), so no equivalent
   search was possible there — periphery contracts on Abstract were not identified at all.
   This does not affect fund-holding conclusions (routers/position-managers do not custody
   pool reserves at rest in the Uniswap V3 design, confirmed for the one instance we did
   fully inspect on Ink), but it does mean the "dependencies" callback surface described in
   each pool's `analysis.md` is described generically, not address-by-address.

6. **Internal-transaction listings used to find periphery contracts were not exhaustively
   paginated.** The Ink factory's internal-transactions and transactions listings were read
   via Blockscout's default single-page response (≤50 items); if a periphery contract
   interacted with the factory only after those first ~50 internal calls, it would not have
   surfaced by this method.

7. **No exhaustive search for a treasury/timelock/staking/gauge contract was performed on any
   chain** beyond following the concrete leads that emerged from factory/pool transaction
   graphs (which surfaced only the position manager on Ink). None was found, but the absence
   of a finding is not the same as a proof of absence.

8. **Pricing methodology relies on DefiLlama's `coins.llama.fi` and Blockscout's
   `exchange_rate` field**, both third-party price oracles that can occasionally be stale or
   wrong for illiquid, unaudited long-tail tokens (several of the pool constituents here are
   exactly that). Where no price was available at all (MIRAI, GRIND, AMY, MLP), this is
   stated explicitly per contract rather than guessed.

---

## DECOMPILATION STATUS

| Contract | Chain | Status |
|---|---|---|
| Factory `0xece75613Aa9b1680f0421E5B2eF376DF68aa83Bb` | Redstone | **Not decompiled — bytecode itself could not be retrieved.** Every RPC/explorer avenue for chain ID 690 failed (see COULD-NOT-ENUMERATE #1); a decompiler requires deployed bytecode as input, which was never obtainable. No pseudocode of any kind is included for this contract. |
| Factory `0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1` | ZERO Network | **Not independently decompiled — deployed bytecode was retrieved and proven byte-identical (SHA-256 match) to the independently-verified Abstract deployment at the same address.** The Abstract copy's verified Uniswap Labs source is included in this ZERO Network folder with that provenance explicitly documented in `analysis.md`; a from-scratch decompilation was judged unnecessary and strictly lower-confidence than the proven bytecode match. |

Every other included contract (all 13 Abstract pools, both Ink pools, and the Abstract and
Ink factories — 17 contracts total) is **verified** on its respective chain's explorer
(Etherscan V2 for Abstract, Blockscout for Ink) — full verified Solidity source, ABI, and
compiler settings are saved in each folder's `source/`, `abi.json`, and
`metadata.json`/`compiler_settings.json`. No decompilation was required for any live,
verified contract.

---

## Proxy / recent-implementation-change check

**No proxies were found anywhere in this deployment.** Every included contract (factory and
pool instances on every chain) is a plain, immutable, non-upgradeable contract — confirmed
via the explorer's own `Proxy: 0` / `proxy_type: null` verification metadata for every
verified contract, and via the fact that all bytecode inspected (including the unverified
ZERO Network factory) matches the canonical, non-proxy Uniswap V3 core contracts exactly. No
`eth_getStorageAt` probing of the EIP-1967 implementation/admin slots was needed to *rule
out* a proxy pattern here, because the verified source itself contains no `DELEGATECALL`
dispatch logic — but as a direct on-chain cross-check, both the EIP-1967 implementation slot
(`0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bb`) and admin slot
(`0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`) were read live via
`eth_getStorageAt` for the Abstract factory, the Ink factory, the largest Abstract pool
(`0x157beaa1...`), and the largest Ink pool (`0xd5aa1bd3...`) — all returned all-zero on
every contract checked, confirming none of them is a transparent/UUPS/EIP-1967 proxy. Consequently there is **no "implementation changed
recently" case to report** — there is no proxy anywhere in this inventory whose
implementation could change.

---

## Repository layout
```
sakuraswap-clmm/
  README.md                          (this file)
  data/                               raw enumeration + valuation outputs (reproducibility)
  contracts/
    abstract/
      UniswapV3Factory_0xA1160e73/    verified source, ABI, compiler settings, analysis.md
      Pool_<addr>/  (x13)             one per included pool
      DROPPED_POOLS.md                methodology + reasons for the other 6,650 pools
    ink/
      UniswapV3Factory_0x640887A9/
      Pool_0xd5aa1bd3/ , Pool_0xc6d49c16/     the 2 included pools
      NonfungiblePositionManager_0xC0836E5B_DROPPED_below_threshold/
      DROPPED_POOLS.md                methodology + reasons for the other 1,871 pools
    zero-network/
      UniswapV3Factory_0xA1160e73/
      ALL_POOLS_DROPPED_below_10k.md  full table of all 35 pools found, all below threshold
    redstone/
      UniswapV3Factory_0xece75613/    analysis.md explaining the chain shutdown + gap
```
