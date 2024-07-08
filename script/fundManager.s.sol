// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FundManager} from "../src/fundManager.sol";

contract FundManagerScript is Script {
    FundManager public fundManager;

    function setUp() public {}

    function run() public {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("CONTRACT_OWNER");

        vm.startBroadcast(deployerPrivateKey);

        fundManager = new FundManager(owner);

        console.log("deployed FundManager Address", address(fundManager));

        vm.stopBroadcast();
    }
}
