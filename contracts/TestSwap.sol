// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestSwap {
    function testCallFunction(address callTest, address token, uint256 amount) public returns(uint256 __amount){
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(callTest, amount);
        (, bytes memory data) = callTest.call(abi.encodeWithSignature("testCallFunction(address)", token));
        assembly{__amount := mload(add(data, 0x20))}
        return __amount;
    }
}