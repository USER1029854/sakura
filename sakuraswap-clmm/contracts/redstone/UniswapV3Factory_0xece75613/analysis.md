# UniswapV3Factory — 0xece75613Aa9b1680f0421E5B2eF376DF68aa83Bb (Redstone) — CHAIN DEFUNCT

## Role
Admin / governance contract (factory), by the same pattern as the Abstract/Ink/ZERO Network
deployments of this protocol — but **the chain this contract lives on has been shut down**
and is no longer queryable by anyone, not just from this environment.

## Discovery
Address is from DefiLlama's TVL adapter source for this protocol
(`registries/uniswapV3.js`, `reservoir-tools-v3.redstone.factory =
0xece75613Aa9b1680f0421E5B2eF376DF68aa83Bb`, `fromBlock: 1`). This is the *only* piece of
ground-truth evidence available for this chain's deployment — see below for why nothing else
could be independently confirmed.

## The chain is shut down — this is a material, protocol-relevant fact
Redstone (chain ID 690, an OP-Stack "alt-DA" L2 operated by Lattice, home of the MUD
framework) was **permanently shut down on 2026-05-15 23:59 UTC**. Lattice announced this
on-chain and on X (@latticexyz), explicitly warning: *"If you have funds on Redstone,
withdraw before then — especially anything held in contracts like Uniswap pools. After
shutdown we'll deploy an L1 withdrawal contract for EOA balances, but [funds locked in
contracts are not covered]."* (source: Lattice's shutdown announcement, corroborated by
KuCoin/BingX/Bitget news coverage and L2BEAT's Redstone project page). Only EOA balances get
any L1 recovery path — funds still held inside contracts (pools, position NFTs) at shutdown
time are **not** part of that recovery mechanism.

This is corroborated by DefiLlama's own historical TVL series for this protocol's Redstone
deployment (`chainTvls.Redstone.tvl` in the DefiLlama protocol API response): the chain
tracked a steady **~$25,500–$29,800** in this protocol's pools from March through
2026-05-22, then dropped to a **flat, unchanging $0 every single day from 2026-05-23
onward through 2026-08-12** (the date of this review) — consistent with DefiLlama's own
adapter losing the ability to query the chain (RPC dead) rather than a genuine, gradual
user-driven withdrawal (which would show a declining, not instantly-flat, curve).

## Balance / controlled funds — UNKNOWN, cannot be verified by anyone
- Last DefiLlama-observed aggregate TVL for this protocol on Redstone: **$27,589** (as of
  2026-05-22, the last day before the reported value went flat to $0).
- This total was spread across an unknown number of individual pools; **no per-pool
  breakdown could be obtained** because pool enumeration requires replaying `PoolCreated`
  logs from the factory, which requires a working RPC endpoint for chain ID 690 — none was
  reachable (see below).
- **This factory (and whatever pools it deployed) is included in this inventory on the
  strength of that last-known ~$27.6k aggregate figure**, which is well above the $10k
  inclusion bar, even though the exact current state cannot be confirmed. It is not dropped,
  because there is no affirmative evidence the funds were withdrawn — the abrupt flat-$0
  reporting pattern is far more consistent with the data source going dark than with a
  genuine drain.

## Verification status: SOURCE UNAVAILABLE — could not fetch bytecode, let alone decompile
Every avenue tried to reach chain ID 690 from this environment failed:
- Official RPC `https://rpc.redstonechain.com` (confirmed correct via the OP Superchain
  Registry's `redstone.toml`) — connection refused at the network layer on every attempt.
- Official explorer `https://explorer.redstone.xyz` (Blockscout) — returns Cloudflare error
  1014/403 on every attempt, including via an independent fetch path (not just this
  session's proxy).
- Nine other public RPC aggregators tried (1rpc, Ankr, Tenderly, thirdweb, meowrpc,
  gateway.fm, BlockPI, Conduit, zan.top, Alchemy/Blast/Chainstack/Stackup chain-specific
  subdomains) — all failed to connect or explicitly rejected the request.
- The Wayback Machine has one archived snapshot of this address's Blockscout page
  (2025-05-02), but it is a client-rendered SPA shell with no embedded balance/bytecode data
  — confirms the address existed and was viewed on-chain, nothing more.

Because **no bytecode could be retrieved at all**, no decompilation was possible — a
decompiler needs the deployed bytecode as input, and that could not be obtained by any
method tried. This is a stronger form of "unverified" than the ZERO Network factory (which
at least yielded raw bytecode from Blockscout): here, literally nothing beyond the address
itself and DefiLlama's historical TVL series is available. **No source, no ABI, no
bytecode, no decompilation output are included in this folder** — producing any of those
would mean inventing data, which this review does not do.

## Ownership / governance
Unknown — cannot be read without RPC access.

## Callable surface / dependencies / proxy relationships
Unknown — cannot be determined without bytecode. By strong analogy to the sibling
deployments on Abstract/Ink/ZERO Network (same `reservoir-tools-v3` module, same DefiLlama
adapter pattern), this is *presumed* to be an unmodified Uniswap V3 `UniswapV3Factory` with
the standard ABI, but this is an inference from the sibling deployments, not a
directly-verified fact about this specific contract, and is flagged as such.
