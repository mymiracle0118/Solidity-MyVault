// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/fundManager_old.sol";
import "forge-std/Script.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract upgradeScript is Script {
    
    function run() public {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("CONTRACT_OWNER");
        address proxy = vm.envAddress("CONTRACT_PROXY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Upgrade the proxy to a new version; MyTokenV2
        Upgrades.upgradeProxy(address(proxy), "fundManager_old.sol:FundManager", "", owner);

        vm.stopBroadcast();
        // Log the proxy address
        console.log("UUPS Proxy Address:", address(proxy));
    }
}