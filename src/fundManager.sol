// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { console } from "forge-std/Test.sol";

contract FundManager is AccessControl, ReentrancyGuard {
    constructor(address defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function withdrawEth(address _to, uint256 _amount) public nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        address payable to = payable(_to);
        console.log("contract balance", address(this).balance);
        require(_amount <= address(this).balance, "Insufficient funds");
        to.transfer(_amount);
    }

    function withdrawToken(address _token, address _to, uint256 _amount) public nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_amount <= IERC20(_token).balanceOf(address(this)), "Insufficient amount");
        IERC20(_token).transfer(
            _to,
            _amount
        );
        // IERC20(params.collateralToken).safeTransferFrom(//@audit can use fake msg.sender contract for arb call?
        //     // cannot find safeTransferFrom IERC20
        //     borrower,
        //     address(this),
        //     collateralAmount
        // );
    }

    receive() external payable {
    }
}