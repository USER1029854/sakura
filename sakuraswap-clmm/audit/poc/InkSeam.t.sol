// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IUniswapV3Factory {
    function getPool(address, address, uint24) external view returns (address);
    function owner() external view returns (address);
    function feeAmountTickSpacing(uint24) external view returns (int24);
}

interface IUniswapV3Pool {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
    function liquidity() external view returns (uint128);
    function slot0() external view returns (uint160, int24, uint16, uint16, uint16, uint8, bool);
    function factory() external view returns (address);
}

interface INFPM {
    function factory() external view returns (address);
    function WETH9() external view returns (address);
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}

/// Tests the periphery<->core integration seam on the real deployed Ink contracts.
/// POOL_INIT_CODE_HASH in the deployed NonfungiblePositionManager is the canonical
/// Ethereum-mainnet Uniswap V3 constant; this fork compiled its pools with
/// bytecodeHash="none", so the real init code hash may differ.
contract InkSeamTest is Test {
    address constant FACTORY = 0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424;
    address constant NFPM    = 0xC0836E5B058BBE22ae2266e1AC488A1A0fD8DCE8;
    address constant POOL_WETH_USDCE = 0xD5Aa1bD330A94332F071dA5Bb3651EC372EA6926;
    address constant POOL_USDT0_USDCE = 0xc6D49c16129071e21AEeA0beeF86D9054f89e5a6;
    address constant WETH  = 0x4200000000000000000000000000000000000006;
    address constant USDCE = 0xF1815bd50389c46847f0Bda824eC8da914045D14;
    address constant USDT0 = 0x0200C29006150606B650577BBE7B6248F58470c1;

    bytes32 constant DEPLOYED_INIT_CODE_HASH =
        0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    function computeAddress(address factory, address t0, address t1, uint24 fee, bytes32 initHash)
        internal pure returns (address)
    {
        return address(uint160(uint256(keccak256(abi.encodePacked(
            hex"ff", factory, keccak256(abi.encode(t0, t1, fee)), initHash
        )))));
    }

    function test_seam_and_state() public {
        // ---- ground truth from the live chain ----
        address realPool = IUniswapV3Factory(FACTORY).getPool(WETH, USDCE, 3000);
        emit log_named_address("factory.getPool(WETH,USDC.e,3000)", realPool);
        assertEq(realPool, POOL_WETH_USDCE, "inventory pool address must match factory registry");

        // pool is genuinely wired to this factory
        assertEq(IUniswapV3Pool(realPool).factory(), FACTORY, "pool.factory()");
        assertEq(INFPM(NFPM).factory(), FACTORY, "NFPM points at same factory");

        // ---- the seam: does the NFPM's hardcoded hash reproduce the real pool? ----
        address predicted = computeAddress(FACTORY, WETH, USDCE, 3000, DEPLOYED_INIT_CODE_HASH);
        emit log_named_address("PoolAddress.computeAddress(canonical hash)", predicted);
        emit log_named_bytes32("POOL_INIT_CODE_HASH in NFPM", DEPLOYED_INIT_CODE_HASH);

        if (predicted == realPool) {
            emit log("SEAM OK: canonical init code hash reproduces the real pool address");
        } else {
            emit log("SEAM BROKEN: NFPM computes an address that is NOT the real pool");
            emit log_named_uint("code size at predicted address", predicted.code.length);
            // Direction-of-impact check: is the predicted address occupied/occupiable?
            assertEq(predicted.code.length, 0, "predicted address holds no code");
        }

        // ---- live funded state of the two included pools ----
        emit log_named_uint("pool1 WETH bal ", IERC20(WETH).balanceOf(POOL_WETH_USDCE));
        emit log_named_uint("pool1 USDC.e bal", IERC20(USDCE).balanceOf(POOL_WETH_USDCE));
        emit log_named_uint("pool1 liquidity", IUniswapV3Pool(POOL_WETH_USDCE).liquidity());
        emit log_named_uint("pool2 USDT0 bal ", IERC20(USDT0).balanceOf(POOL_USDT0_USDCE));
        emit log_named_uint("pool2 USDC.e bal", IERC20(USDCE).balanceOf(POOL_USDT0_USDCE));

        emit log_named_address("factory.owner()", IUniswapV3Factory(FACTORY).owner());
    }
}
