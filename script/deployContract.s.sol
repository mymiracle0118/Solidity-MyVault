// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
// import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "../src/fundManager.sol";
import "../src/Proxy/EIP173Proxy.sol";
import "forge-std/Script.sol";

contract FundManagerScript is Script {
    
    FundManager public fundManager;

    function run() public {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("CONTRACT_OWNER");

        vm.startBroadcast(deployerPrivateKey);

        fundManager = new FundManager();

        console.log("deployed FundManager Address", address(fundManager));

        address payable _implementation = payable(address(fundManager)); // Replace with your token address

        // Encode the initializer function call
        bytes memory data = abi.encodeWithSelector(
            FundManager(_implementation).initialize.selector,
            owner, // Initial owner/admin of the contract
            deployerPrivateKey
        );

        // Deploy the proxy contract with the implementation address and initializer
        EIP173Proxy proxy = new EIP173Proxy(_implementation, owner, data);

        vm.stopBroadcast();
        // Log the proxy address
        console.log("UUPS Proxy Address:", address(proxy));
    }
}