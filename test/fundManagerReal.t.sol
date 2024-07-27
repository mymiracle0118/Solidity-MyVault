// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {FundManager} from "../src/fundManager.sol";
import {FundManagerUpgrade} from "../src/fundManagerUpgrade.sol";
import {EIP173Proxy} from "../src/Proxy/EIP173Proxy.sol";
import {IFundManager} from "../src/IFundManager.sol";
// import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "src/fundManager.sol";

interface IProxy {
    function upgradeTo(address newImplementation) external;
}

contract FundManagerRealTest is Test {
    uint256 chainFork;

    address payable admin = payable(address(0x3EAEd08FF5b1829afC5945B1643707713dA54ac6));
    address payable alice = payable(address(0x5f56eEBF7b6cC82750d41aC85376c9b2491e2F2e));
    address payable bob = payable(address(7));

    IProxy public proxy;

    FundManagerUpgrade public fundManagerUpgrade;
   
    IERC20 token = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7)); // Polygon Mainnet;
    address payable public _implementation;

    function setUp() public {
        chainFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        // chainFork = vm.createFork(vm.envString("BSC_RPC_URL"));
        // chainFork = vm.createFork(vm.envString("POLYGON_RPC_URL"));
        vm.selectFork(chainFork);
        assertEq(vm.activeFork(), chainFork);
        vm.rollFork(20394506);

        proxy = IProxy(0x7bE1992A648bf4B8F7DbD85cb3E734d8e8863C40);
        _implementation = payable(address(0xaCc5Ebba190D84466319C4c05AccCE10f60FeABf));
    }

    function testWithdrawEth() public {

        bool success;
        bytes memory returnData;

        vm.deal(admin, 10 ether);
      
        vm.prank(admin);
        payable(payable(address(proxy))).transfer(5 ether);
        assertGe(address(proxy).balance, 5 ether, "havent transferred");

        vm.prank(alice);
        vm.expectRevert("Unauthorized");
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(FundManager(_implementation).withdrawEth.selector, alice, 1 ether));

        vm.prank(admin);
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(FundManager(_implementation).withdrawEth.selector, admin, 1 ether));

        assertEq(address(proxy).balance, 4 ether, "transfer error");
        assertEq(address(admin).balance, 6 ether, "transfer error");    
    }

    function testWithdrawToken() public {

        bool success;
        bytes memory returnData;

        uint256 decimalMultiplier = 10 ** IERC20Metadata(address(token)).decimals();       

        vm.deal(admin, 10 ether);

        deal(address(token), admin, 5000 * decimalMultiplier);
        // deal(token, to, give, false);
        assertEq(token.balanceOf(address(admin)), 5000 * decimalMultiplier, "deal token failed");
        
        vm.startPrank(admin);
        (success, returnData) = address(token).call(abi.encodeWithSelector(IERC20.transfer.selector, address(proxy), 1000 * decimalMultiplier));
        // token.transfer(address(proxy), 1000 * decimalMultiplier);
        vm.stopPrank();

        assertEq(token.balanceOf(address(proxy)), 1000 * decimalMultiplier, "transfer to fundManger failed");
        assertEq(token.balanceOf(address(admin)), 4000 * decimalMultiplier, "transfer to fundManger failed");

        
        vm.startPrank(alice);
        uint256 transferAmount = 1000 * decimalMultiplier;
        vm.expectRevert("Unauthorized");  // Adjust with the actual revert message expected
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(FundManager(_implementation).withdrawToken.selector, token, admin, transferAmount));
        vm.stopPrank();

        vm.startPrank(admin);
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(FundManager(_implementation).withdrawToken.selector, token, alice, 1000 * decimalMultiplier));
        vm.stopPrank();

        assertEq(token.balanceOf(address(alice)), 1000 * decimalMultiplier, "transfer to fundManger failed");

        assertEq(token.balanceOf(address(proxy)), 0 * decimalMultiplier, "transfer to fundManger failed"); 
    }

    function testUpgrade() public {

        bool success;
        bytes memory returnData;

        vm.deal(admin, 10 ether);

        vm.prank(admin);
        payable(payable(address(proxy))).transfer(5 ether);
        
        vm.startPrank(admin);
        fundManagerUpgrade = new FundManagerUpgrade();
        proxy.upgradeTo(address(fundManagerUpgrade));
        vm.stopPrank();

        assertGe(address(proxy).balance, 5 ether, "havent transferred");

        vm.startPrank(alice);
        vm.expectRevert("Unauthorized");
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(FundManagerUpgrade(_implementation).withdrawEther.selector, alice, 1 ether));
        vm.stopPrank();

        vm.startPrank(admin);
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(FundManagerUpgrade(_implementation).withdrawEther.selector, admin, 1 ether));
        vm.stopPrank();

        assertEq(address(proxy).balance, 4 ether, "transfer error");
        assertEq(address(admin).balance, 6 ether, "transfer error");    
    }
}
