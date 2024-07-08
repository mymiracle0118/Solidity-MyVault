// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import "src/fundManager.sol";

contract FundManagerTest is Test {
    FundManager public fundManager;

    uint256 mainnetFork;
    uint256 bscFork;
    uint256 polygonFork;

    address admin = address(5);
    address alice = address(6);
    address bob = address(7);

    function setUp() public {
        mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        bscFork = vm.createFork(vm.envString("BSC_RPC_URL"));
        polygonFork = vm.createFork(vm.envString("POLYGON_RPC_URL"));
    }

    function testWithdrawEth() public {
        vm.selectFork(polygonFork);
        assertEq(vm.activeFork(), polygonFork);

        vm.rollFork(59087427);

        fundManager = new FundManager(admin);

        vm.deal(admin, 10 ether);
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
}
