// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Test {
    function swap(string memory aggregatorId, address tokenFrom, uint256 amount, bytes memory data) public payable {
        (address fromAddress, address toAddress, uint256 newAmount) = parse(data);

    }

    function parse(bytes memory data) public pure returns(
        address fromAddress,
        address toAddress,
        uint256 newAmount
    ){
        bytes memory data1 = new bytes(0x20);
        bytes memory data2 = new bytes(0x20);
        bytes memory data3 = new bytes(0x20);
        assembly {
            let mc1 := add(data1, 0x20)
            let cc := add(data, 0x20)
            let mc2 := add(data2, 0x20)
            let mc3 := add(data3, 0x20)
            
            mstore(mc1, mload(cc))
            mstore(mc2, mload(add(data, 0x40)))
            mstore(mc3, mload(add(data, 0x60)))
            fromAddress := mload(mc1)
            toAddress := mload(mc2)
            newAmount := mload(mc3)
        }
    }
}