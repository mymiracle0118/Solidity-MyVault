// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FundManager} from "../src/fundManager.sol";

contract FundManagerScript is Script {
    FundManager public fundManager;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        fundManager = new FundManager();

        vm.stopBroadcast();
    }
}
