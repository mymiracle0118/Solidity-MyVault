// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import "src/MRPTToken.sol";

contract MockMRPTToken is MRPTToken {
    constructor() MRPTToken() { }
}
