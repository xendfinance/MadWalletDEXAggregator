// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IParaswapRouter {
    struct SimpleData {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address[] callees;
        bytes exchangeData;
        uint256[] startIndexes;
        uint256[] values;
        address payable beneficiary;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }
    function simpleSwap(
        SimpleData memory data
    ) external payable returns (uint256 receivedAmount);
}

interface IAirSwapLight {
    function swap(
        uint256 nonce,
        uint256 expiry,
        address signerWallet,
        IERC20 signerToken,
        uint256 signerAmount,
        IERC20 senderToken,
        uint256 senderAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IZeroExRouter {
    function sellToPancakeSwap(address[] memory tokens, uint256 sellAmount, uint256 minBuyAmount, uint8 fork) external payable returns (uint256 buyAmount);
}

interface IDodoRouter {

    struct Order {
        address makerAddress;          
        address takerAddress;          
        address feeRecipientAddress;   
        address senderAddress;         
        uint256 makerAssetAmount;      
        uint256 takerAssetAmount;      
        uint256 makerFee;              
        uint256 takerFee;              
        uint256 expirationTimeSeconds; 
        uint256 salt;                  
        bytes makerAssetData;          
        bytes takerAssetData;           
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;
        uint256 takerAssetFilledAmount;
        uint256 makerFeePaid;          
        uint256 takerFeePaid;          
    }

    function fillOrder(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
    external
    returns (FillResults memory fillResults);
}

interface IOneInchRouter {
    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }
    function swap(
        address caller,
        SwapDescription calldata desc,
        bytes calldata data
    )
    external
    payable
    returns (uint256 returnAmount, uint256 gasLeft)
}

contract Test {

    address paraswapRouter;
    address airswapLight;
    address zeroExRouter;
    address dodoRouter;
    address oneInchRouter;

    constructor() {
        // paraswapRouter = address(0xdef171fe48cf0115b1d80b88dc8eab59176fee57);
        // airswapLight = address(0xc98314a5077DBa8F12991B29bcE39F834E82e197);
        // zeroExRouter = address(0xdef1c0ded9bec7f1a1670819833240f027b25eff);
        // dodoRouter = address(0x3F93C3D9304a70c9104642AB8cD37b1E2a7c203A);
        // oneInchRouter = address(0x1111111254fb6c44bac0bed2854e76f90643097d);
    }

    function swap(string memory aggregatorId, address tokenFrom, uint256 amount, bytes memory data) public payable {
        (address fromAddress, address toAddress, uint256 newAmount) = parse(data);
        // switch(aggregatorId){
        //     case '0xFeeDynamic':
        //         break;
        //     case 'oneInchV4FeeDynamic':
        //         break;
        //     case 'pmmFeeDynamic':
        //         break;
        //     case 'airswapLightFeeDynamic':
        //         break;
        //     case 'paraswapV5FeeDynamic':
        //         break;
        // }
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