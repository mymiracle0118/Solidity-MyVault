// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {FundManager} from "../src/fundManager.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";

import "src/fundManager.sol";

contract FundManagerTest is Test {
    FundManager public fundManager;

    uint256 mainnetFork;
    uint256 bscFork;
    uint256 polygonFork;

    address admin = address(0x3EAEd08FF5b1829afC5945B1643707713dA54ac6);
    address alice = address(6);
    address bob = address(7);
    
    IERC20 usdc = IERC20(address(0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359)); // Polygon Mainnet;
    address usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('withdrawToken(address, address, uint256)')));

    function setUp() public {
        mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        bscFork = vm.createFork(vm.envString("BSC_RPC_URL"));
        polygonFork = vm.createFork(vm.envString("POLYGON_RPC_URL"));
    }

    function testWithdrawEth() public {
        vm.selectFork(polygonFork);
        assertEq(vm.activeFork(), polygonFork);

        vm.rollFork(59087427);

        vm.deal(admin, 10 ether);

        vm.startPrank(admin);
        fundManager = new FundManager();
        vm.stopPrank();
        
        // deal(token, to, give, false);
        vm.prank(admin);
        payable(address(fundManager)).transfer(5 ether);
        // vm.prank(admin);
        assertGe(address(fundManager).balance, 5 ether, "havent transferred");

        vm.prank(alice);
        vm.expectRevert();
        fundManager.withdrawEth(admin, 1 ether);

        vm.prank(admin);
        vm.expectRevert();
        fundManager.withdrawEth(admin, 6 ether);

        vm.prank(admin);
        fundManager.withdrawEth(admin, 3 ether);

        assertLt(address(fundManager).balance, 5 ether, "transfer error");
        assertGe(address(admin).balance, 4 ether, "transfer error");    
    }

    function testWithdrawToken() public {
        vm.selectFork(polygonFork);
        assertEq(vm.activeFork(), polygonFork);

        vm.rollFork(59087427);

        vm.deal(admin, 10 ether);

        vm.startPrank(admin);
        fundManager = new FundManager();
        vm.stopPrank();
        // fundManager.initialize(admin);

        // console.log("token balance", usdc.balanceOf(address(admin)));
        deal(address(usdc), admin, 5000 * 10 ** IERC20Metadata(address(usdc)).decimals());
        // deal(token, to, give, false);
        assertEq(usdc.balanceOf(address(admin)), 5000 * 10 ** IERC20Metadata(address(usdc)).decimals(), "deal usdc failed");
        
        vm.startPrank(admin);
        usdc.transfer(address(fundManager), 1000 * 10 ** IERC20Metadata(address(usdc)).decimals());
        vm.stopPrank();

        // assertEq(usdc.balanceOf(address(fundManager)), 1000 * 10 ** IERC20Metadata(address(usdc)).decimals(), "transfer to fundManger failed");

        // assertEq(usdc.balanceOf(address(admin)), 4000 * 10 ** IERC20Metadata(address(usdc)).decimals(), "transfer to fundManger failed");

        
        // vm.startPrank(alice);
        // uint256 transferAmount = 1000 * IERC20Metadata(address(usdc)).decimals();
        // vm.expectRevert();
        // fundManager.withdrawToken(address(usdc), admin, transferAmount);
        // vm.stopPrank();

        vm.startPrank(admin);
        address(fundManager).call(abi.encodeWithSelector(SELECTOR, usdt, alice, 1000 * 10 ** IERC20Metadata(address(usdc)).decimals()));
        // fundManager.withdrawToken(address(usdc), alice, 1000 * 10 ** IERC20Metadata(address(usdc)).decimals());
        vm.stopPrank();

        // assertEq(usdc.balanceOf(address(alice)), 1000 * 10 ** IERC20Metadata(address(usdc)).decimals(), "transfer to fundManger failed");

        // assertEq(usdc.balanceOf(address(fundManager)), 0 * 10 ** IERC20Metadata(address(usdc)).decimals(), "transfer to fundManger failed"); 
    }
}
