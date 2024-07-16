// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import { SafeERC20 } from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import { console } from "forge-std/Test.sol";

contract FundManager is Initializable, AccessControlUpgradeable, UUPSUpgradeable     {

    using SafeERC20 for IERC20;
    // bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {        
        _disableInitializers();
    }
    
    function initialize(address defaultAdmin) initializer public {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);       
    }

    // function _safeTransfer(address token, address to, uint value) private {
    //     (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
    //     require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    // }

    function increaseAllowance(address _token, address _to, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(_token).safeIncreaseAllowance(_to, _amount);
    }

    function decreaseAllowance(address _token, address _to, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(_token).safeDecreaseAllowance(_to, _amount);
    }

    function withdrawEth(address _to, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address payable to = payable(_to);
        // console.log("contract balance", address(this).balance);
        require(_amount <= address(this).balance, "Insufficient funds");
        to.transfer(_amount);
    }

    function withdrawToken(address _token, address _to, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_amount <= IERC20(_token).balanceOf(address(this)), "Insufficient amount");
        // _safeTransfer(_token, _to, _amount);
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(DEFAULT_ADMIN_ROLE)
        override
    {}

    receive() external payable {
    }
}