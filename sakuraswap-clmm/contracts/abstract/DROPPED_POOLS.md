# Abstract — dropped pools (6,650 of 6,663 discovered)

## Discovery method
All 6,663 pools deployed by factory `0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1` on Abstract
were enumerated by replaying every `PoolCreated` event log from block 1 to latest
(`eth_getLogs` against `https://api.mainnet.abs.xyz`, chunked in 50,000-block windows). Raw
output: `../../data/abstract_all_pools_raw.json` (6,663 rows: pool address, token0, token1,
fee, tickSpacing, creation block/tx).

The factory is **permissionless** — `createPool(tokenA, tokenB, fee)` can be called by
anyone — and the deployer EOA `0xf3d63166f0ca56c3c1a3508fce03ff0cf3fb691e` is the direct
caller behind the overwhelming majority of these 6,663 pools (confirmed via
`txlistinternal`/`txlist` against the factory, Etherscan V2 API). This is consistent with
either bulk/automated pool pre-creation (e.g. a "create a market for any token" UX pattern)
or spam. 6,309 of the 6,663 pools (95%) involve a distinct, unique token address on at least
one side — consistent with mass-created pools for freshly-deployed, low/no-value tokens.

## How the $10k cut was determined without pricing all 6,663 pools individually
1. **WETH side, exhaustively.** 6,318 of 6,663 pools (95%) pair with WETH
   (`0x3439153eb7af838ad19d56e1571fbd09333c2809`). Every one of these pools' WETH balance was
   read in a single pass via `Multicall3.aggregate3` (batched `balanceOf` calls, 300/batch;
   raw output `../../data/abstract_weth_balance_scan_raw.json`). Ranked descending, WETH
   balance falls from 143 WETH (pool #1) to 3.28 WETH (pool #8) to under 3 WETH for every
   remaining pool (1,164 pools with non-zero but small WETH; 5,147 pools with **zero** WETH
   balance). At the reference price used throughout this review (ETH ≈ $1,877.31), 3 WETH ≈
   $5,632 — below the $10k bar even before considering the paired token, and DefiLlama's own
   per-token USD breakdown for this chain (`sakuraswap_protocol.json` →
   `chainTvls.Abstract.tokensInUsd`, latest snapshot) shows every token symbol besides the
   ones already captured in the 13 included pools (WETH, USDC.e, USDT, YGG, PENGU, GUILD,
   GRIND, absETH) totals **under $10k across ALL of its pools combined** (highest untouched
   symbol: KONA at $5,919.89 aggregate) — so no additional WETH-paired pool beyond the
   already-included set can cross $10k.
2. **Non-WETH pools, exhaustively.** The 345 pools that do *not* pair with WETH were checked
   completely: both token balances were read for every one of them (690 `balanceOf` calls
   via Multicall3), and every counterparty token's `symbol()`/`decimals()` was resolved (195
   unique tokens). Four of these 345 pools involve USDC.e/USDT (priced ~$1) and were valued
   exactly; the rest were cross-referenced against live DefiLlama prices where available
   (PENGU, GUILD, TYAG, ABSTER). Two pools (AMY/USDT, MLP/USDC.e) contain tokens with **no**
   DefiLlama price feed at all; both are paired against a de-minimis priced-token amount
   ($577 and $1,460 respectively) and are extremely unlikely to cross $10k, but this
   specific pair could not be *fully* priced — flagged in the top-level COULD-NOT-ENUMERATE
   section rather than silently dropped.
3. Full computation: `../../data/abstract_included_pools_valued.json` (the 13 that made the
   cut) — every other row across both scans fell under $10k and is dropped for that reason.

## Exact drop reason for every dropped pool
**Holds < $10,000 in the protocol's funds**, per the balance/price evidence in
`../../data/abstract_all_pools_raw.json`,
`../../data/abstract_weth_balance_scan_raw.json`, and the non-WETH pool/token scan described
above. None was dropped for any other reason (none is a duplicate proxy/implementation pair
— every pool is an independent, non-proxy deployment; none was found to be "unrelated to
protocol funds" — they are all genuine pools deployed by this factory; none was excluded as
"fully migrated" — Abstract is the live, dominant chain for this protocol).
