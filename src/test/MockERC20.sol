// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../lib/solmate/src/tokens/ERC20.sol";

contract MockERC20 is ERC20("Mock Token", "MOCK", 18) {
  function mint(address to, uint256 amount) external {
    _mint(to, amount);
  }
}