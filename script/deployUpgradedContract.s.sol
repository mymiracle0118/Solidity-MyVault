// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
// import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "../src/fundManagerUpgrade.sol";
import "../src/Proxy/EIP173Proxy.sol";
import "forge-std/Script.sol";

contract FundManagerUpgradeScript is Script {
    
    FundManagerUpgrade public fundManagerUpgrade;

    function run() public {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // address owner = vm.envAddress("CONTRACT_OWNER");

        vm.startBroadcast(deployerPrivateKey);

        fundManagerUpgrade = new FundManagerUpgrade();

        console.log("deployed FundManager Address", address(fundManagerUpgrade));

        vm.stopBroadcast();
    }
}