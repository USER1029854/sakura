// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

/// Rigorously determines whether standard (EVM) Foundry can EXECUTE Abstract
/// (zkSync/EraVM-stack) contracts, by comparing results against ground truth
/// independently read from Abstract's own JSON-RPC during inventory collection.
/// A staticcall returning ok=true with empty/!=32-byte returndata is NOT execution.
contract AbstractForkTest is Test {
    address constant FACTORY  = 0xA1160e73B63F322ae88cC2d8E700833e71D0b2a1;
    address constant POOL_TOP = 0x157BeAA1C7dcC2AAD79846eC693C558609eBc0ea; // WETH/YGG
    address constant WETH     = 0x3439153EB7AF838Ad19d56E1571FBD09333C2809;
    address constant YGG      = 0xa9053DC939D74222F7aa0B3A2bE407abbfd56C6a;

    // Ground truth read from Abstract's own RPC (eth_call) during collection:
    address constant TRUE_OWNER = 0x2BAD8182C09F50c8318d769245beA52C32Be46CD;
    uint256 constant TRUE_WETH_BAL = 134053961997211760000; // ~134.054 WETH
    uint256 constant TRUE_YGG_BAL  = 14653980862057648407118388;

    function test_can_foundry_execute_on_abstract() public {
        emit log_named_uint("factory code length seen by EVM", FACTORY.code.length);
        emit log_named_uint("pool code length seen by EVM", POOL_TOP.code.length);

        bool anyCorrect;

        (bool ok, bytes memory ret) = FACTORY.staticcall(abi.encodeWithSignature("owner()"));
        emit log_named_string("owner() call ok", ok ? "true" : "false");
        emit log_named_uint("owner() returndata length", ret.length);
        if (ok && ret.length == 32) {
            address got = abi.decode(ret, (address));
            emit log_named_address("owner() decoded", got);
            emit log_named_address("owner() expected", TRUE_OWNER);
            if (got == TRUE_OWNER) anyCorrect = true;
        }

        (bool ok2, bytes memory ret2) =
            WETH.staticcall(abi.encodeWithSignature("balanceOf(address)", POOL_TOP));
        emit log_named_string("balanceOf call ok", ok2 ? "true" : "false");
        emit log_named_uint("balanceOf returndata length", ret2.length);
        if (ok2 && ret2.length == 32) {
            uint256 got = abi.decode(ret2, (uint256));
            emit log_named_uint("WETH bal decoded", got);
            emit log_named_uint("WETH bal expected", TRUE_WETH_BAL);
            if (got == TRUE_WETH_BAL) anyCorrect = true;
        }

        (bool ok3, bytes memory ret3) = POOL_TOP.staticcall(abi.encodeWithSignature("slot0()"));
        emit log_named_string("slot0() call ok", ok3 ? "true" : "false");
        emit log_named_uint("slot0() returndata length", ret3.length);

        (bool ok4, bytes memory ret4) = POOL_TOP.staticcall(abi.encodeWithSignature("liquidity()"));
        emit log_named_string("liquidity() call ok", ok4 ? "true" : "false");
        emit log_named_uint("liquidity() returndata length", ret4.length);

        if (anyCorrect) {
            emit log("RESULT: EVM execution on Abstract returns CORRECT values -> PoCs possible");
        } else {
            emit log("RESULT: EVM execution on Abstract does NOT reproduce ground truth");
            emit log("        (EraVM bytecode is not EVM-interpretable) -> Abstract PoCs IMPOSSIBLE");
        }
        assertTrue(true); // informational test; the log is the evidence
    }
}
