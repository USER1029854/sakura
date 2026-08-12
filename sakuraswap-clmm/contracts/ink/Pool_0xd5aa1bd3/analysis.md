# Pool 0xd5aa1bd330a94332f071da5bb3651ec372ea6926 (Ink)

## Role
Pool / liquidity vault (`funded`, user-callable AMM pool). This is the **largest funded
contract on Ink** for this protocol.

## Discovery
Found by replaying `PoolCreated` event logs (topic0
`0x783cca1c0412dd0d695e784568c96da2e9c22ff989357a2e8b1d9b2b4e6b7118`) emitted by the
SakuraSwap CLMM factory `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424` on Ink, from block 1 to
latest, via `eth_getLogs` against `https://rpc-gel.inkonchain.com` (1,873 pools total on this
chain; every pool's WETH balance was then ranked via a `Multicall3.aggregate3` batch call —
this pool ranked #1 by a wide margin: 11.72 WETH vs. 0.32 WETH for the next-highest).
Verified source pulled from Blockscout (`explorer.inkonchain.com`).

## Pair / fee tier
- token0: WETH `0x4200000000000000000000000000000000000006` (OP-Stack canonical WETH predeploy)
- token1: USDC.e `0xf1815bd50389c46847f0bda824ec8da914045d14` (bridged USDC — note: **not**
  the same address as the "USDC" entry in DefiLlama's core-assets list for Ink,
  `0x2D270e6886d130D724215A266106e6832161EAEd`, which has negligible liquidity in this
  protocol's pools; this `USDC.e` address is the one actually used)
- fee tier: 0.3%

## Balance / controlled TVL (at time of review)
- WETH: 11.715352 ($21,957.71) — price source: DefiLlama coins.llama.fi (`ink:0x4200...0006`)
- USDC.e: 12,638.6846 ($12,645.69) — price source: DefiLlama coins.llama.fi (`ink:0xf1815bd5...`)
- **Total: $34,603.40**

## Verification status
Verified on Ink's Blockscout explorer. Contract name `UniswapV3Pool`, compiler
`v0.7.6+commit.7338295f`, `evmVersion: istanbul`, optimizer enabled, 800 runs (per the
factory's compiler settings — this pool matches). Source is the canonical Uniswap V3 core
`UniswapV3Pool.sol` — see `source/` and `abi.json`.

## Callable surface
Same as every other pool in this inventory (standard, unmodified Uniswap V3 pool ABI):
- **User-callable**: `mint`, `burn`, `collect`, `swap`, `flash`,
  `increaseObservationCardinalityNext`.
- **Admin-gated** (must be `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424.owner()`, currently
  the `CrossChainAccount` contract `0x66c5d722fc52671c7f839bbbf752bc38e0520b91` — see the
  Ink factory's `analysis.md`): `setFeeProtocol`, `collectProtocol`.
- No proxy admin, no upgradeability.

## Dependencies / external calls
- Constructed by and reads `owner()`/`feeAmountTickSpacing` from the Ink factory
  `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`.
- `swap`/`mint`/`flash` invoke `uniswapV3*Callback` functions on the caller — in practice
  this includes the SakuraSwap CLMM `NonfungiblePositionManager`
  `0xC0836E5B058BBE22ae2266e1AC488A1A0fD8DCE8` on Ink (confirmed wired to this same factory,
  though itself dropped from this inventory for holding no material funds — see
  `../NonfungiblePositionManager_0xC0836E5B_DROPPED_below_threshold/DROPPED.md`).
- Calls `transfer`/`transferFrom` on WETH/USDC.e.

## Proxy relationships
None — plain, immutable, non-upgradeable pool contract.
