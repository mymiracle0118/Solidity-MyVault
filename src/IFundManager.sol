// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

interface IFundManager {
  function increaseAllowance(address _token, address _to, uint256 _amount) external;

  function decreaseAllowance(address _token, address _to, uint256 _amount) external;

  function withdrawEth(address _to, uint256 _amount) external;

  function withdrawToken(address _token, address _to, uint256 _amount) external;
}