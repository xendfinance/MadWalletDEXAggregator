// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CallTest {
    function testCallFunction(address token) public returns(uint256){
        IERC20(token).transferFrom(msg.sender, address(this), 100000);
        return IERC20(token).balanceOf(address(this));
    }
}