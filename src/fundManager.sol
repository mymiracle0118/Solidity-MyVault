// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FundManager is Initializable, OwnableUpgradeable {
    using SafeERC20 for IERC20;
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
    }

    function test public nonReentrant {

    }

    // pull the collateral from the borrower
        // IERC20(params.collateralToken).safeTransferFrom(//@audit can use fake msg.sender contract for arb call?
        //     // cannot find safeTransferFrom IERC20
        //     borrower,
        //     address(this),
        //     collateralAmount
        // );
    // return the collateral to the borrower
        // IERC20(params.collateralToken).safeTransfer(
        //     loan.borrower,
        //     loan.collateralAmount
        // );
}