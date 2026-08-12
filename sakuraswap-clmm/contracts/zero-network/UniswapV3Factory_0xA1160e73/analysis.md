# UniswapV3Factory — 0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1 (ZERO Network)

## Role
Admin / governance contract (factory). Same role as its Abstract counterpart: deploys pools,
holds no funds itself, controls fee-tier and ownership parameters for every pool it deploys
on ZERO Network.

## Discovery
Same DefiLlama adapter source as the Abstract entry (`registries/uniswapV3.js`,
`reservoir-tools-v3.zero_network.factory = 0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1`,
`fromBlock: 1`). This is the *same address* as the Abstract factory — confirmed as a
genuinely separate deployment (not a bridged/mirrored contract) with the **same deployer
EOA** (`0xf3d63166F0Ca56C3c1A3508FcE03Ff0Cf3Fb691e`, per Blockscout
`creator_address_hash`), consistent with deterministic (CREATE2-style) same-address
deployment across chains by one operator.

## Balance / controlled funds
- Native ETH balance: 0 (`eth_getBalance` via `https://explorer.zero.network/api/eth-rpc`).
- No ERC-20 token balances (Blockscout `token-balances` endpoint returns `[]`).
- Included for the same reason as the Abstract factory: it controls fee-tier/ownership
  parameters and the protocol-fee sweep path for every pool it deployed on this chain, even
  though none of those pools individually holds ≥$10k (see chain README — largest pool on
  this chain is ~$3,199).

## Verification status — NOT verified on this chain's own explorer
`https://explorer.zero.network` reports this address as unverified
(`is_verified` absent from the Blockscout `/smart-contracts` response; only raw bytecode
fields returned). **Source in this folder was not obtained by decompiling this deployment.**
Instead: the deployed bytecode was pulled directly from Blockscout
(`deployed_bytecode`, 16,578 hex chars) and compared byte-for-byte (SHA-256) against the
Abstract factory's bytecode fetched live via `eth_getCode`:

```
zero_network deployed_bytecode sha256: ad4906f1b318c4d3e5e5a40dadf28886991e7b6ec31834c025a2644bfe888023
abstract    eth_getCode        sha256: ad4906f1b318c4d3e5e5a40dadf28886991e7b6ec31834c025a2644bfe888023
```

The hashes are **identical**. Because the Abstract deployment at the same address is
independently verified as the canonical, unmodified `UniswapV3Factory.sol`, this proves the
ZERO Network deployment runs the exact same bytecode — with a much higher confidence level
than a heuristic decompilation would give. The `source/`, `abi.json`, and
`compiler_settings.json` files in this folder are copies of that proven-identical source,
not a re-verification performed on this chain.

## Ownership / governance
`owner()` could **not** be read for this deployment: the only reachable RPC endpoint for
ZERO Network from this environment (`https://explorer.zero.network/api/eth-rpc`) accepts
`eth_getLogs`/`eth_getBalance`/`eth_blockNumber` but returns `500 Internal Server Error` for
`eth_call` and `eth_getStorageAt`, and the contract is unverified so Blockscout's
ABI-assisted read-method endpoint doesn't work either. All other public RPC endpoints tried
for chain ID 543210 (official `rpc.zerion.io/v1/zero`, thirdweb, Caldera) were unreachable or
returned "node is not available" — see top-level README COULD-NOT-ENUMERATE. Ownership state
is a mutable storage slot and **cannot be assumed identical to Abstract's** even though the
bytecode is. Treat factory governance on this chain as unverified/unknown.

## Callable surface
Identical ABI to the Abstract factory (proven bytecode match): `createPool` (permissionless),
`setOwner`/`enableFeeAmount` (owner-gated), `getPool`/`feeAmountTickSpacing`/`owner` (read).

## Dependencies / external calls
Same as Abstract factory: deploys `UniswapV3Pool` instances via `CREATE`; each deployed pool
reads this factory's `owner()` to gate its own protocol-fee functions.

## Proxy relationships
None (non-proxy, confirmed via identical bytecode to the non-proxy Abstract deployment).
