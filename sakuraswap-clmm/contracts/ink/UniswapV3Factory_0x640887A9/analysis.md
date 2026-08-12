# UniswapV3Factory — 0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424 (Ink)

## Role
Admin / governance contract (factory). Deploys all pools for this deployment, holds no
funds itself, controls fee-tier and ownership parameters for every pool it deploys.

## Discovery
Address from DefiLlama's TVL adapter source (`registries/uniswapV3.js`,
`reservoir-tools-v3.ink.factory = 0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`,
`fromBlock: 1`). Note: the adapter config also sets
`blacklistedTokens: [ADDRESSES.ethereum.WETH]` — but `ADDRESSES.ethereum.WETH` resolves to
`0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`, which is **Ethereum mainnet's** WETH address,
not Ink's (Ink's real WETH is the OP-Stack predeploy `0x4200...0006`). This looks like a
copy/paste artifact in DefiLlama's own adapter with no actual effect on Ink — flagged here
for transparency, not because it changes anything in this review's own balance figures
(which are independent, direct on-chain reads).

## Balance / controlled funds
- Native ETH balance: 0.
- No ERC-20 balances (factories don't custody swap/LP reserves in Uniswap V3).
- Included for the same "controls funds network-wide" reasoning as the Abstract factory.

## Verification status
Verified on Ink's Blockscout explorer. Contract name `UniswapV3Factory`, compiler
`v0.7.6+commit.7338295f`, `evmVersion: istanbul`, optimizer enabled, 800 runs, no
constructor arguments. Source is the canonical Uniswap V3 core `UniswapV3Factory.sol` — see
`source/` and `abi.json`.

## Ownership / governance
- `owner()` = `0x66c5d722fc52671c7f839bbbf752bc38e0520b91` (read live via `eth_call`).
- That address **is a contract**, verified on Blockscout as `CrossChainAccount`
  (`contracts/CrossChainAccount.sol`). Its constructor args identify
  `_messenger = 0x4200000000000000000000000000000000000007` (Ink's standard OP-Stack
  `L2CrossDomainMessenger` predeploy) and `_l1Owner = 0x1a9C8182C09F50C8318d769245beA52c32BE35BC`.
- **The true governance root is on Ethereum L1, not Ink.** `0x1a9C8182...BE35BC` was checked
  directly on Ethereum mainnet (`eth_getCode` via Etherscan V2, chainid=1): it is a contract
  whose bytecode contains the literal revert strings `"Timelock::executeTransaction: Call
  must come from admin."`, `"Timelock::queueTransaction: Call must come from admin."`, etc.
  — i.e. it is a **Compound-style Timelock on Ethereum mainnet**. Messages queued/executed
  through that L1 Timelock are relayed to Ink via the standard OP-Stack cross-domain
  messenger and land as calls from this `CrossChainAccount`, which then calls
  `setOwner`/`enableFeeAmount` etc. on this factory. The Timelock's own admin was not
  further traced (see top-level COULD-NOT-ENUMERATE).
- Deployer / contract creator was not separately re-verified beyond the above (out of scope
  once the ownership chain terminated at a named, purpose-built Timelock contract).

## Callable surface
- **Admin-gated (`owner()` only, i.e. reachable only via the L1 Timelock → cross-chain
  message path above)**: `setOwner(address)`, `enableFeeAmount(uint24 fee, int24 tickSpacing)`.
- **Permissionless**: `createPool(tokenA, tokenB, fee)` — this is how 1,873 pools came to
  exist on this chain, the vast majority low/no-value (see `DROPPED_POOLS.md`).
- **Read-only**: `getPool`, `feeAmountTickSpacing`, `owner`.

## Dependencies / external calls
Deploys `UniswapV3Pool` instances via `CREATE`; every deployed pool reads this factory's
`owner()` to gate its own `setFeeProtocol`/`collectProtocol`.

## Proxy relationships
None. Not a proxy (`proxy_type: null` per Blockscout, immutable canonical Uniswap V3
factory).
