# UniswapV3Factory — 0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1 (Abstract)

## Role
Admin / governance contract (factory). Deploys all pools for this deployment via `CREATE`,
holds no user funds itself, but controls protocol-wide parameters: which fee tiers exist,
who owns the deployment, and who may sweep the protocol-fee share out of every pool it has
created.

## Discovery
This is the ground-truth entry point for the whole inventory: found via DefiLlama's own TVL
adapter source for this protocol (`module: reservoir-tools-v3/index.js`,
`registries/uniswapV3.js` in `DefiLlama-Adapters`, which hard-codes
`{ abstract: { factory: '0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1', fromBlock: 1 } }`).
Cross-checked as a live, verified contract via Etherscan V2 (`chainid=2741`).

## Balance / controlled funds
- Native ETH balance: 0 (`eth_getBalance`, confirmed live).
- No ERC-20 token balances expected or found (factories do not custody swap/LP reserves in
  the Uniswap V3 design; reserves live in the pools it deploys).
- **Included in this inventory despite $0 direct balance** because it *controls* funds
  network-wide: it can enable new fee tiers, transfer factory ownership, and (via each
  pool's `collectProtocol`, gated on `factory.owner()`) sweep any accrued protocol-fee share
  out of every pool listed in this folder tree.

## Verification status
Verified, contract name `UniswapV3Factory`, compiler `v0.7.6+commit.7338295f` (zksolc
`v1.3.13`, optimization mode 3), no constructor arguments. Source is the unmodified
Uniswap Labs `UniswapV3Factory.sol` core contract — see `source/` and `abi.json`.

## Ownership / governance
- `owner()` = `0x2bad8182c09f50c8318d769245bea52c32be46cd` (read live via `eth_call`).
- That owner address has **no contract bytecode** (`eth_getCode` returns `0x`) — it is a
  plain externally-owned account (EOA), i.e. a single private key, not a multisig or
  timelock. This is a material governance fact: whoever holds that key can unilaterally
  change fee tiers, reassign ownership, or collect protocol fees network-wide on Abstract.
- Deployer / contract creator: `0xf3d63166f0ca56c3c1a3508fce03ff0cf3fb691e` (also an EOA;
  this address is also the direct caller behind the large majority of the 6,663
  `PoolCreated` events on Abstract — see chain README notes on pool-creation spam).

## Callable surface
- **Admin-gated (`owner()` only)**: `setOwner(address)`, `enableFeeAmount(uint24 fee, int24 tickSpacing)`.
- **Permissionless / user-callable**: `createPool(tokenA, tokenB, fee)` — anyone may create a
  new pool for any token pair at an already-enabled fee tier; this is how thousands of
  low/no-liquidity pools came to exist (see chain-level README notes).
- **Read-only**: `getPool(tokenA, tokenB, fee)`, `feeAmountTickSpacing(fee)`, `owner()`.

## Dependencies / external calls
- None outbound at the factory level besides deploying new `UniswapV3Pool` instances via
  `CREATE` (through the `UniswapV3PoolDeployer` base contract) and emitting
  `PoolCreated`/`OwnerChanged`/`FeeAmountEnabled` events.
- All pools deployed by this factory read `IUniswapV3Factory(msg.sender).owner()` at
  runtime to gate their own `setFeeProtocol`/`collectProtocol` functions — i.e. this
  factory's owner is the de facto protocol-fee admin for every pool in `contracts/abstract/`.

## Proxy relationships
None. Not a proxy; immutable, non-upgradeable contract (`Proxy: 0` per Etherscan metadata).
