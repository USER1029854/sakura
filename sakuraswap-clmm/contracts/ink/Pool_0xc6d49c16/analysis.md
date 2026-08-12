# Pool 0xc6d49c16129071e21aeea0beef86d9054f89e5a6 (Ink)

## Role
Pool / liquidity vault (`funded`, user-callable AMM pool). Second-largest funded contract on
Ink.

## Discovery
Found the same way as the WETH/USDC.e pool: full `PoolCreated` log replay from the Ink
factory (1,873 pools total), then ranked by both a USDT0-balance and a USDC.e-balance
`Multicall3.aggregate3` batch scan across all 1,873 pools (this pool ranked #1 by USDT0
balance and #2 by USDC.e balance). Verified source pulled from Blockscout.

## Pair / fee tier
- token0: USDT0 `0x0200C29006150606B650577BBE7B6248F58470c1`
- token1: USDC.e `0xf1815bd50389c46847f0bda824ec8da914045d14`
- fee tier: 0.3%

## Balance / controlled TVL (at time of review)
- USDT0: 7,854.301012 ($7,845.89) — price source: DefiLlama coins.llama.fi (`ink:0x0200C2...`)
- USDC.e: 7,617.119574 ($7,621.34) — price source: DefiLlama coins.llama.fi (`ink:0xf1815bd5...`)
- **Total: $15,467.24**

Two smaller pools for the same USDT0/USDC.e pair exist at other fee tiers (0.01% and 0.05%)
— both individually hold under $1,000 and are dropped (see `../ALL_INCLUDED_AND_DROPPED.md`
in this chain's folder for the full ranked list).

## Verification status
Verified on Ink's Blockscout explorer. Contract name `UniswapV3Pool`, compiler
`v0.7.6+commit.7338295f`, `evmVersion: istanbul`, optimizer enabled 800 runs. Canonical
Uniswap V3 core source — see `source/` and `abi.json`.

## Callable surface
Same standard, unmodified Uniswap V3 pool ABI as every other pool in this inventory:
user-callable `mint`/`burn`/`collect`/`swap`/`flash`; admin-gated (factory owner only)
`setFeeProtocol`/`collectProtocol`. No proxy admin, no upgradeability.

## Dependencies / external calls
- Constructed by and reads `owner()`/`feeAmountTickSpacing` from the Ink factory
  `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`.
- `swap`/`mint`/`flash` invoke `uniswapV3*Callback` functions on the caller (expected to be
  the position manager/router).
- Calls `transfer`/`transferFrom` on USDT0/USDC.e.

## Proxy relationships
None — plain, immutable, non-upgradeable pool contract.
