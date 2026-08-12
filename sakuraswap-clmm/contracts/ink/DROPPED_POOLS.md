# Ink — dropped pools (1,871 of 1,873 discovered)

## Discovery method
All 1,873 pools deployed by factory `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424` on Ink were
enumerated by replaying every `PoolCreated` event log from block 1 to latest (`eth_getLogs`
against `https://rpc-gel.inkonchain.com`, chunked in 9,500-block windows — this RPC caps
`eth_getLogs` ranges at 10,000 blocks — fetched with 12 concurrent workers). Raw output:
`../../data/ink_all_pools_raw.json` (1,873 rows). Same permissionless-factory pattern as
Abstract: 1,837 of 1,873 pools (98%) pair with WETH, and 1,860 distinct token addresses
appear across the full set — consistent with mass/bot-created pools for freshly-deployed,
low/no-value tokens rather than organic listings.

## How the $10k cut was determined
1. Every pool's balance of three "anchor" tokens — WETH (`0x4200...0006`), the bridged
   `USDC.e` actually used by this protocol's liquidity (`0xf1815bd50389c46847f0bda824ec8da914045d14`
   — **not** the same address as the generic "USDC" in DefiLlama's Ink core-assets list,
   which turned out to have negligible liquidity here), and `USDT0`
   (`0x0200C29006150606B650577BBE7B6248F58470c1`) — was read in three `Multicall3.aggregate3`
   batch passes covering all 1,873 pools each. Raw outputs:
   `../../data/ink_weth_balance_scan_raw.json`, `../../data/ink_usdce_balance_scan_raw.json`,
   `../../data/ink_usdt0_balance_scan_raw.json`.
2. Ranked descending, exactly **one** pool has meaningful WETH (11.72 WETH ≈ $21,958 vs. the
   next-highest at 0.32 WETH ≈ $609), and **two** pools have meaningful USDT0/USDC.e (a
   $15,467 pool and a $34,603 pool — the same WETH/USDC.e pool from the WETH scan). Every
   other pool's anchor-token holdings, even summed across all three scans for the same pool,
   fall well under $10k (spot-checked precisely for the next 5 highest-WETH pools — see
   `../../data/ink_included_pools_valued.json` vs. the raw scans; none exceeds ~$900
   combined).
3. No DefiLlama per-token USD breakdown is available for Ink at the granularity used for
   Abstract (the API did not return a populated `tokensInUsd` breakdown for this chain at
   review time), so unlike Abstract this bound relies solely on the exhaustive anchor-token
   multicall scans above, not a cross-check against DefiLlama's own aggregates. This is
   flagged in the top-level COULD-NOT-ENUMERATE section.
4. The 17 pools that touch **none** of the three anchor tokens were additionally checked
   exhaustively (both sides' raw balances read, both tokens' symbols resolved) rather than
   assumed zero. Two of them — `brBTC/uniBTC` (`0x4bf9cc8afdb9daf3e441281312f3b94eb8683567`)
   and `kBTC/uniBTC` (`0x95022a57745ef5cb8e2cb142a6e729fa9a722181`) — looked potentially
   material from raw integer balances (~100,000+ units) until their decimals (8) and live
   BTC-scale prices (~$62,888 and ~$63,456 per token respectively) were applied: true values
   are ~$126 and ~$139. Every other non-anchor pool held test/placeholder tokens (literally
   named `Test`, `Test2`, `MTK`, `TK01`/`TK02`, `TSTUSDC`, etc.) with de-minimis balances.

## Exact drop reason for every dropped pool
**Holds < $10,000 in the protocol's funds**, per the balance evidence in the raw scan files
above. None was dropped for any other reason.
