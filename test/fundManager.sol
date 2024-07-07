// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundManager} from "../src/fundManger.sol";

contract CounterTest is Test {
    FundManager public fundManager;

    function setUp() public {
        fundManager = new FundManager();
    }
}
