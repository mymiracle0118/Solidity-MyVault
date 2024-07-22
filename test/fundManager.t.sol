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

contract FundManagerTest is Test {
    uint256 chainFork;

    address payable admin = payable(address(0x3EAEd08FF5b1829afC5945B1643707713dA54ac6));
    address payable alice = payable(address(0x5f56eEBF7b6cC82750d41aC85376c9b2491e2F2e));
    address payable bob = payable(address(7));

    FundManager public fundManager;
    FundManagerUpgrade public fundManagerUpgrade;
    
    IERC20 token = IERC20(address(0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359)); // Polygon Mainnet;

    bytes4 private constant SELECTOR_WITHDRAW_ETHER = bytes4(keccak256(bytes('withdrawEth(address _to, uint256 _amount)')));
    bytes4 private constant SELECTOR_WITHDRAW_TOKEN = bytes4(keccak256(bytes('withdrawToken(address _token, address _to, uint256 _amount)')));
    bytes4 private constant SELECTOR_WITHDRAW_ETHER_UPDATE = bytes4(keccak256(bytes('withdrawEther(address _to, uint256 _amount)')));

    function setUp() public {
        // chainFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        // chainFork = vm.createFork(vm.envString("BSC_RPC_URL"));
        chainFork = vm.createFork(vm.envString("POLYGON_RPC_URL"));
        vm.selectFork(chainFork);
        assertEq(vm.activeFork(), chainFork);
        vm.rollFork(59680276);
    }

    function testWithdrawEth() public {

        bool success;
        bytes memory returnData;

        // uint256 decimalMultiplier = 10 ** 18;       

        vm.deal(admin, 10 ether);

        vm.startPrank(admin);
        fundManager = new FundManager();

        address payable _implementation = payable(address(fundManager)); // Replace with your token address

        bytes memory data = abi.encodeWithSelector(
            FundManager(_implementation).initialize.selector,
            admin, // Initial owner/admin of the contract
            admin
        );

        EIP173Proxy proxy = new EIP173Proxy(_implementation, admin, data);
        vm.stopPrank();
        
        // deal(token, to, give, false);
        vm.prank(admin);
        payable(payable(address(proxy))).transfer(5 ether);
        // vm.prank(admin);
        assertGe(address(proxy).balance, 5 ether, "havent transferred");

        // vm.prank(alice);
        // vm.expectRevert();
        // (success, returnData) = address(proxy).call(abi.encodeWithSelector(SELECTOR_WITHDRAW_ETHER, token, alice, 1 ether));
        // // proxy.withdrawEth(admin, 1 ether);

        // vm.prank(admin);
        // vm.expectRevert();
        // (success, returnData) = address(proxy).call(abi.encodeWithSelector(SELECTOR_WITHDRAW_ETHER, token, alice, 1 ether));

        vm.prank(admin);
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(SELECTOR_WITHDRAW_ETHER, alice, 1 ether));

        assertLt(address(proxy).balance, 4 ether, "transfer error");
        assertGe(address(admin).balance, 9 ether, "transfer error");    
    }

    function testWithdrawToken() public {

        bool success;
        bytes memory returnData;

        uint256 decimalMultiplier = 10 ** IERC20Metadata(address(token)).decimals();       

        vm.deal(admin, 10 ether);

        vm.startPrank(admin);
        fundManager = new FundManager();
        address payable _implementation = payable(address(fundManager)); // Replace with your token address
        bytes memory data = abi.encodeWithSelector(
            FundManager(_implementation).initialize.selector,
            admin, // Initial owner/admin of the contract
            admin
        );
        EIP173Proxy proxy = new EIP173Proxy(_implementation, admin, data);
        vm.stopPrank();

        deal(address(token), admin, 5000 * decimalMultiplier);
        // deal(token, to, give, false);
        assertEq(token.balanceOf(address(admin)), 5000 * decimalMultiplier, "deal token failed");
        
        vm.startPrank(admin);
        token.transfer(address(proxy), 1000 * decimalMultiplier);
        vm.stopPrank();

        assertEq(token.balanceOf(address(proxy)), 1000 * decimalMultiplier, "transfer to fundManger failed");

        assertEq(token.balanceOf(address(admin)), 4000 * decimalMultiplier, "transfer to fundManger failed");

        
        vm.startPrank(alice);
        uint256 transferAmount = 1000 * IERC20Metadata(address(token)).decimals();
        vm.expectRevert();
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(SELECTOR_WITHDRAW_TOKEN, token, admin, transferAmount));
        // proxy.withdrawToken(address(token), admin, transferAmount);
        vm.stopPrank();

        vm.startPrank(admin);
        // address(proxy).call(abi.encodeWithSelector(SELECTOR, token, alice, 1000 * decimalMultiplier));
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(SELECTOR_WITHDRAW_TOKEN, token, alice, 1000 * decimalMultiplier));
        // proxy.withdrawToken(address(token), alice, 1000 * decimalMultiplier);
        vm.stopPrank();

        assertEq(token.balanceOf(address(alice)), 1000 * decimalMultiplier, "transfer to fundManger failed");

        assertEq(token.balanceOf(address(proxy)), 0 * decimalMultiplier, "transfer to fundManger failed"); 
    }

    function testUpgradeOnPolygon() public {

        bool success;
        bytes memory returnData;

        uint256 decimalMultiplier = 10 ** IERC20Metadata(address(token)).decimals();       

        vm.deal(admin, 10 ether);

        vm.startPrank(admin);
        fundManager = new FundManager();
        address payable _implementation = payable(address(fundManager)); // Replace with your token address
        bytes memory data = abi.encodeWithSelector(
            FundManager(_implementation).initialize.selector,
            admin, // Initial owner/admin of the contract
            admin
        );
        EIP173Proxy proxy = new EIP173Proxy(_implementation, admin, data);
        vm.stopPrank();
        
        vm.startPrank(admin);
        fundManagerUpgrade = new FundManagerUpgrade();
        proxy.upgradeTo(address(fundManagerUpgrade));
        vm.stopPrank();

        vm.startPrank(alice);
        // fundManagerUpgrade = new FundManagerUpgrade();
        (success, returnData) = address(proxy).call(abi.encodeWithSelector(SELECTOR_WITHDRAW_ETHER_UPDATE, token, alice, 1000));
        // proxy.withdrawEther(address(token), admin, 1000);
        vm.stopPrank();
    }
}
