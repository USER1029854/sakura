# Pool 0xb6dfd127aa4f90172cf26f45e3ed127efde55c69

## Role
Pool / liquidity vault (`funded`, user-callable AMM pool). Holds the entire reserve of both
tokens traded on this market; not a proxy, not an admin contract.

## Discovery
Found by replaying `PoolCreated` event logs (topic0
`0x783cca1c0412dd0d695e784568c96da2e9c22ff989357a2e8b1d9b2b4e6b7118`) emitted by the
SakuraSwap CLMM factory `0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1` on Abstract, from block 1 to latest, via direct
`eth_getLogs` calls against `https://api.mainnet.abs.xyz`. Confirmed as the pool address
decoded from the event's non-indexed data (`tickSpacing`, `pool`). Verified source pulled
from Etherscan V2 API (`chainid=2741`, abscan.org backend).

## Pair / fee tier
- token0: USDT `0x0709f39376deee2a2dfc94a58edeb2eb9df012bd`
- token1: PENGU `0x9ebe3a824ca958e4b3da772d2065518f009cba62`
- fee tier: 0.01%

## Balance / controlled TVL (at time of review)
- USDT: 5,535.979252 ($5,537.98) — price source: defillama coins.llama.fi (abstract:0x0709F3...)
- PENGU: 3,447,669.541442 ($21,309.04) — price source: defillama coins.llama.fi
- **Total: $26,847.01**

This is the #8 largest funded SakuraSwap CLMM contract found on Abstract.

## Verification status
Verified on Abstract's Etherscan-family explorer (abscan.org, via Etherscan V2 unified API).
Contract name `UniswapV3Pool`, compiler `v0.7.6+commit.7338295f` (zksolc `v1.3.13`,
optimization mode 3), no constructor arguments (Uniswap V3 pools read their
token0/token1/fee/tickSpacing from transient factory storage at construction time via
`IUniswapV3Factory(msg.sender).parameters()`, not constructor args). Source and ABI are
byte-for-byte the canonical Uniswap V3 core `UniswapV3Pool.sol` — see `source/` and
`abi.json` in this folder, `metadata.json` for full compiler settings.

## Callable surface
- **User-callable**: `mint(recipient, tickLower, tickUpper, amount, data)` (add liquidity),
  `burn(tickLower, tickUpper, amount)` (remove liquidity), `collect(...)` (withdraw owed
  tokens/fees), `swap(recipient, zeroForOne, amountSpecified, sqrtPriceLimitX96, data)`,
  `flash(recipient, amount0, amount1, data)` (flash loan against pool reserves),
  `increaseObservationCardinalityNext(...)`.
- **Admin-gated** (must be `0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1.owner()`): `setFeeProtocol(feeProtocol0, feeProtocol1)`,
  `collectProtocol(recipient, amount0Requested, amount1Requested)` — lets the factory owner
  sweep any accrued protocol-fee share out of this pool. No direct owner-only withdrawal of
  LP-owned reserves exists; the factory owner's reach is limited to the protocol-fee slice
  (protocol fee was not separately probed per pool in this review — see COULD-NOT-ENUMERATE).
- No proxy admin, no upgradeability — the pool is an immutable, non-upgradeable contract.

## Dependencies / external calls
- Constructed by and reads `owner()`/`feeAmountTickSpacing` from the factory `0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1`.
- `swap`/`mint`/`flash` invoke callback functions (`uniswapV3SwapCallback`,
  `uniswapV3MintCallback`, `uniswapV3FlashCallback`) on `msg.sender`, so the caller is
  expected to be a router/position-manager/flash-borrower contract that implements them
  (typically the periphery `NonfungiblePositionManager` / `SwapRouter` — see chain-level
  README notes on periphery discovery).
- Calls `transfer`/`transferFrom` on token0/token1 (both plain ERC-20s on Abstract).

## Proxy relationships
None. Confirmed non-proxy: `eth_getStorageAt` was not needed to disprove a proxy pattern
here because the verified bytecode is the literal, unmodified `UniswapV3Pool` runtime code
(no `DELEGATECALL`-based dispatch in its logic), matching Uniswap Labs' canonical V3 core.
