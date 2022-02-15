// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IZeroExRouter {
    function sellToPancakeSwap(
        address[] memory tokens,
        uint256 sellAmount,
        uint256 minBuyAmount,
        uint256 fork
    )
    external
    payable
    returns (uint256 buyAmount);
}

contract TestSwap {

    // using SafeERC20 for IERC20;

    address public zeroExRouter;
    address[] initialTokens;
    struct TransferData{
        uint32 deploymentNonce;
        bytes data;
    }

    constructor() {
        zeroExRouter = address(0xDef1C0ded9bec7F1a1670819833240f027b25EfF);
    }

    receive() external payable {}

    function swap(bytes memory data) public payable returns(bytes memory){
        address[] storage tokens = initialTokens;
        tokens.push(0x24802247bD157d771b7EFFA205237D8e9269BA8A);
        // tokens.push(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        // tokens.push(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        IERC20(tokens[0]).transferFrom(msg.sender, address(this), 106570362666683402623);

        approveToken(tokens[0]);

        // IERC20(tokens[0]).approve(zeroExRouter, type(uint256).max);
        // IERC20(tokens[2]).approve(msg.sender, type(uint256).max);

        bool _success;
        bytes memory _data;
        // bytes memory _testData;
        // TransferData[] memory transferDatas = new TransferData[](2);
        // // TransferData memory _transferData;
        // transferDatas[0].deploymentNonce = 160;
        // transferDatas[0].data = "0x0000000000000000000000000000000000000000000000000000000000000003";

        // transferDatas[1].deploymentNonce = 96;
        // transferDatas[1].data = "0x00000000000000000000000000000000000000000000000000000000000003c0";

        // transferDatas.push(_transferData);
        // _testData = abi.encodeWithSignature("transformERC20(address,address,uint256,uint256,(uint32,bytes)[])", address(0x55d398326f99059fF775485246999027B3197955), address(0xA719b8aB7EA7AF0DDb4358719a34631bb79d15Dc), 1000000000000000000000, 11054302195605384632270, transferDatas);
        (_success, _data) = zeroExRouter.call("0x415565b000000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a0000000000000000000000009fd87aefe02441b123c3c32466cd9db4c578618f000000000000000000000000000000000000000000000005ba051ce26fcee023000000000000000000000000000000000000000000000000145df9d54a9de91b00000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000005400000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000004a00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a0000000000000000000000009fd87aefe02441b123c3c32466cd9db4c578618f0000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000046000000000000000000000000000000000000000000000000000000000000004600000000000000000000000000000000000000000000000000000000000000420000000000000000000000000000000000000000000000005ba051ce26fcee02300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000250616e63616b65537761705632000000000000000000000000000000000000000000000000000005493fcbe4b5fa05c500000000000000000000000000000000000000000000000012ccc263f430b57e000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000010ed43c718714eb63d5aa57b78b54704e256024e0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000200000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a0000000000000000000000009fd87aefe02441b123c3c32466cd9db4c578618f0000000000000000000000000000000250616e63616b6553776170563200000000000000000000000000000000000000000000000000000070c550fdb9d4da5f00000000000000000000000000000000000000000000000001913771566d339d000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000010ed43c718714eb63d5aa57b78b54704e256024e0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000300000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a00000000000000000000000055d398326f99059ff775485246999027b31979550000000000000000000000009fd87aefe02441b123c3c32466cd9db4c578618f0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000869584cd00000000000000000000000011ededebf63bef0ea2d2d071bdf88f71543ec6fb0000000000000000000000000000000000000000000000eaa18a951b6201b7f5000000000000000000000000000000000000000000000000");

        // (_success, _data) = zeroExRouter.call(
        //     data
        // );
        return _data;

        // IZeroExRouter(zeroExRouter).sellToPancakeSwap(tokens,80000000000000000001,77393503097778831600,0);

        // (bool _success1, bytes memory _data1) = zeroExRouter.call(data);
    }

    function approveToken(address token) public {
        IERC20(token).approve(zeroExRouter, type(uint256).max);
    }
}