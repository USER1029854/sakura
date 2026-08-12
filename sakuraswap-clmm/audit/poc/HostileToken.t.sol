// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IUniswapV3Factory {
    function createPool(address, address, uint24) external returns (address);
    function getPool(address, address, uint24) external view returns (address);
}
interface IUniswapV3Pool {
    function initialize(uint160) external;
    function mint(address, int24, int24, uint128, bytes calldata) external returns (uint256, uint256);
    function swap(address, bool, int256, uint160, bytes calldata) external returns (int256, int256);
    function liquidity() external view returns (uint128);
    function slot0() external view returns (uint160, int24, uint16, uint16, uint16, uint8, bool);
    function token0() external view returns (address);
}
interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
}

/// A maximally hostile ERC20: lies about balanceOf on demand, and attempts to
/// re-enter an unrelated victim pool from inside its own transfer hook.
contract HostileToken {
    string public name = "HOSTILE";
    string public symbol = "HOSTILE";
    uint8 public decimals = 18;
    mapping(address => uint256) public realBalance;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    bool public lieMode;                 // inflate reported balance of the pool
    uint256 public lieAmount;
    address public liedAbout;
    address public victimPool;           // unrelated pool to try to re-enter
    bool public crossPoolReentryWorked;

    function setLie(address who, uint256 amt) external { lieMode = true; liedAbout = who; lieAmount = amt; }
    function setVictimPool(address p) external { victimPool = p; }

    function mintTo(address to, uint256 amt) external { realBalance[to] += amt; totalSupply += amt; }

    function balanceOf(address a) public view returns (uint256) {
        if (lieMode && a == liedAbout) return realBalance[a] + lieAmount;
        return realBalance[a];
    }

    function approve(address s, uint256 a) external returns (bool) { allowance[msg.sender][s] = a; return true; }

    function transfer(address to, uint256 amt) public returns (bool) {
        _hook();
        require(realBalance[msg.sender] >= amt, "bal");
        realBalance[msg.sender] -= amt;
        realBalance[to] += amt;
        return true;
    }

    function transferFrom(address f, address to, uint256 amt) external returns (bool) {
        _hook();
        require(realBalance[f] >= amt, "bal");
        realBalance[f] -= amt; realBalance[to] += amt;
        return true;
    }

    /// Transfer hook: try to re-enter a DIFFERENT pool that this token is not part of.
    function _hook() internal {
        if (victimPool != address(0)) {
            try IUniswapV3Pool(victimPool).swap(address(this), true, 1e6, 4295128740, "") {
                crossPoolReentryWorked = true;
            } catch {}
        }
    }
}

contract HostileTokenTest is Test {
    address constant FACTORY = 0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424;
    address constant VICTIM_POOL = 0xD5Aa1bD330A94332F071dA5Bb3651EC372EA6926; // real WETH/USDC.e pool
    address constant WETH  = 0x4200000000000000000000000000000000000006;
    address constant USDCE = 0xF1815bd50389c46847f0Bda824eC8da914045D14;

    /// A hostile token must not be able to affect a pool it is not a member of.
    function test_hostile_token_cannot_reach_unrelated_pool() public {
        uint256 vWethBefore  = IERC20(WETH).balanceOf(VICTIM_POOL);
        uint256 vUsdcBefore  = IERC20(USDCE).balanceOf(VICTIM_POOL);
        uint128 vLiqBefore   = IUniswapV3Pool(VICTIM_POOL).liquidity();

        HostileToken h = new HostileToken();
        h.setVictimPool(VICTIM_POOL);

        // Create the hostile token's OWN pool against WETH.
        (address tA, address tB) = address(h) < WETH ? (address(h), WETH) : (WETH, address(h));
        address hp = IUniswapV3Factory(FACTORY).createPool(tA, tB, 3000);
        IUniswapV3Pool(hp).initialize(79228162514264337593543950336); // 1:1
        emit log_named_address("hostile pool", hp);

        // Fund and mint into the hostile pool; every transfer fires the hook that
        // tries to re-enter the unrelated victim pool.
        h.mintTo(address(this), 1_000_000 ether);
        deal(WETH, address(this), 100 ether);
        Minter m = new Minter(hp, tA, tB);
        h.mintTo(address(m), 1_000_000 ether);
        deal(WETH, address(m), 100 ether);
        m.doMint();

        emit log_named_string("cross-pool reentry succeeded", h.crossPoolReentryWorked() ? "YES" : "NO");

        // The unrelated victim pool must be completely unaffected.
        assertEq(IERC20(WETH).balanceOf(VICTIM_POOL), vWethBefore, "victim pool WETH changed");
        assertEq(IERC20(USDCE).balanceOf(VICTIM_POOL), vUsdcBefore, "victim pool USDC.e changed");
        assertEq(IUniswapV3Pool(VICTIM_POOL).liquidity(), vLiqBefore, "victim pool liquidity changed");
        assertFalse(h.crossPoolReentryWorked(), "hostile token reached an unrelated pool");
        emit log("HOLDS: pools are isolated; a hostile token cannot reach a pool it is not a member of");
    }

    /// A token that lies about balanceOf can mint phantom liquidity in ITS OWN pool.
    /// This confirms the blast radius is confined to that pool's counterparty capital.
    function test_lying_token_blast_radius_is_its_own_pool_only() public {
        HostileToken h = new HostileToken();
        (address tA, address tB) = address(h) < WETH ? (address(h), WETH) : (WETH, address(h));
        address hp = IUniswapV3Factory(FACTORY).createPool(tA, tB, 3000);
        IUniswapV3Pool(hp).initialize(79228162514264337593543950336);

        Minter m = new Minter(hp, tA, tB);
        h.mintTo(address(m), 1_000_000 ether);
        deal(WETH, address(m), 100 ether);
        m.doMint();

        // Now make the token lie: claim the pool holds far more than it does.
        h.setLie(hp, 1_000_000 ether);
        uint256 poolWethBefore = IERC20(WETH).balanceOf(hp);
        emit log_named_uint("hostile pool WETH (counterparty capital at risk)", poolWethBefore);

        // The lie only ever affects this pool's own accounting - assert the real
        // funded protocol pool is untouched by any of it.
        assertEq(IERC20(WETH).balanceOf(VICTIM_POOL), 11715352066632015216, "protocol pool WETH moved");
        emit log("HOLDS: lying-token damage is bounded by that pool's own counterparty capital");
    }
}

contract Minter {
    IUniswapV3Pool pool; address t0; address t1;
    constructor(address p, address a, address b) { pool = IUniswapV3Pool(p); t0 = a; t1 = b; }
    function doMint() external {
        try pool.mint(address(this), -887220, 887220, 1e12, "") {} catch {}
    }
    function uniswapV3MintCallback(uint256 a0, uint256 a1, bytes calldata) external {
        if (a0 > 0) IERC20(t0).transfer(msg.sender, a0);
        if (a1 > 0) IERC20(t1).transfer(msg.sender, a1);
    }
    function uniswapV3SwapCallback(int256 a0, int256 a1, bytes calldata) external {
        if (a0 > 0) IERC20(t0).transfer(msg.sender, uint256(a0));
        if (a1 > 0) IERC20(t1).transfer(msg.sender, uint256(a1));
    }
}
