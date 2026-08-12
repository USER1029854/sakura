# NonfungiblePositionManager — 0xC0836E5B058BBE22ae2266e1AC488A1A0fD8DCE8 (Ink) — DROPPED

## Why this address was investigated
Found by walking the Ink factory's (`0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`) internal
transactions (`GET /api/v2/addresses/{factory}/internal-transactions` on
`explorer.inkonchain.com`) and inspecting each unique caller's verified source. This
contract is verified as `NonfungiblePositionManager` with constructor argument
`_factory = 0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`, i.e. it is confirmed to be
SakuraSwap CLMM's own position-manager periphery contract on Ink (not a template deployed
by an unrelated project reusing the same code, of which there are several others on Ink —
see chain README).

## Why it was dropped
- Native ETH balance: 0.
- Token balances (`token-balances` endpoint): exactly two ERC-20 balances, both spam/airdrop
  tokens with no DefiLlama or Blockscout price feed (`exchange_rate: null`):
  - "DEGRES OPIUM" (`DEGRES`), 99,781 tokens
  - "Telegram @vipTron888_bot" (a phishing-pattern token name), 8,888 units
- In the Uniswap V3 architecture the `NonfungiblePositionManager` does **not** custody pool
  reserves at rest — those live in the pool contracts themselves; the position manager only
  tracks NFT ownership of LP positions and forwards `mint`/`burn`/`collect` calls to pools.
  It also has no owner-gated sweep function over pool funds, so it does not "control" funds
  in the sense the other admin/governance contracts in this inventory do.
- Net: **$0 in real, priced value held**, and no structural control over protocol funds.
  Drops under the "<$10k" rule.

Source/ABI/compiler settings were still fetched and are saved here for completeness/audit
trail, since it is a genuine, verified, protocol-relevant contract — it is just excluded
from the "included" inventory for holding no material funds.
