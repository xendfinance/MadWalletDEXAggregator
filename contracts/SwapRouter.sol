// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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
    function getTokenTransferProxy() external view returns (address);
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
    function ORDER_TYPEHASH() external view returns(bytes32);
    function DOMAIN_SEPARATOR() external view returns(bytes32);
    function signerFee() external view returns(uint256);
    function authorize(address sender) external;
    function revoke() external;
}

interface IZeroExRouter {
    function sellToPancakeSwap(address[] memory tokens, uint256 sellAmount, uint256 minBuyAmount, uint8 fork) external payable returns (uint256 buyAmount);
}

interface IPmmRouter {

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
    returns (uint256 returnAmount, uint256 gasLeft);
}

contract SwapRouter is Ownable{

    address public paraswapRouter;
    address public airswapLight;
    address public zeroExRouter;
    address public pmmRouter;
    address public oneInchRouter;
    address public feeAddress;

    constructor() {
        paraswapRouter = address(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57);
        airswapLight = address(0xc98314a5077DBa8F12991B29bcE39F834E82e197);
        zeroExRouter = address(0xDef1C0ded9bec7F1a1670819833240f027b25EfF);
        pmmRouter = address(0x3F93C3D9304a70c9104642AB8cD37b1E2a7c203A);
        oneInchRouter = address(0x1111111254fb6c44bAC0beD2854e76F90643097d);
        feeAddress = address(0x0B25a50F0081c177554e919EeFf192Cfe9EfDe15);
    }

    receive() external payable {}

    function swap(string memory aggregatorId, address tokenFrom, uint256 amount, bytes memory data) public payable{

        bytes4 fName;
        uint256 position;
        uint256 receivedAmount;
        uint256 feeAmount;
        address destinationToken;
        uint256 swappingTokenAmount;

        assembly {
            fName := mload(add(data, 0x20))
        }

        if(fName == 0x5f575529) {
            position = 0xE4;
            assembly {
                feeAmount := mload(add(data, 0x1A4))
            }
        }
        else{
            assembly {
                feeAmount := mload(add(data, 0xC0))
            }
        }

        assembly {
            destinationToken := mload(add(data, add(position, 0x40)))
            swappingTokenAmount := mload(add(data, add(position, 0x60)))
        }

        if(tokenFrom != address(0)){
            IERC20(tokenFrom).transferFrom(msg.sender, address(this), amount);
        }

        if(keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("0xFeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), zeroExRouter) == 0){
                    IERC20(tokenFrom).approve(zeroExRouter, type(uint256).max);
                }
            }
            bytes memory exSwapData;
            position = position + 0x120;
            assembly {
                exSwapData := mload(add(data, 0x0))
                let cc := add(data, position)
                exSwapData := add(cc, 0x0)
            }
            bool success;
            bytes memory result;
            if(tokenFrom != address(0)){
                (success, result) = zeroExRouter.call(exSwapData);
            }
            else{
                uint256 inputAmount;
                bytes4 selector;
                assembly {
                    selector := mload(add(exSwapData, 0x20))
                }
                if(selector == 0xc43c9ef6) {
                    assembly {
                        inputAmount := mload(add(exSwapData, 0x44))
                    }
                }
                else{
                    assembly {
                        inputAmount := mload(add(exSwapData, 0x64))
                    }
                }
                (success, result) = zeroExRouter.call{value:inputAmount}(exSwapData);
            }
            if(success){
                assembly {
                    receivedAmount := mload(add(result, 0x20))
                }
            }
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("oneInchV4FeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), oneInchRouter) == 0){
                    IERC20(tokenFrom).approve(oneInchRouter, type(uint256).max);
                }
            }
            bytes memory oneInchData;
            position = position + 0x120;
            assembly {
                oneInchData := mload(add(data, 0x0))
                let cc := add(data, position)
                oneInchData := add(cc, 0x0)
            }
            (address _caller, IOneInchRouter.SwapDescription memory desc, bytes memory _data) = parseOneInchData(oneInchData);
            if(tokenFrom != address(0)){
                (receivedAmount, ) = IOneInchRouter(oneInchRouter).swap(_caller, desc, _data);
            }
            else{
                uint256 inputAmount;
                assembly {
                    inputAmount := mload(add(oneInchData, 0x104))
                }
                (receivedAmount, ) = IOneInchRouter(oneInchRouter).swap{value: inputAmount}(_caller, desc, _data);
            }
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("pmmFeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), pmmRouter) == 0){
                    IERC20(tokenFrom).approve(pmmRouter, type(uint256).max);
                }
            }
            bytes memory pmmData;
            uint256 takerAssetFillAmount;
            uint256 takerAssetFillAmountPosition = position + 0x60;
            position = position + 0x180;
            assembly {
                pmmData := mload(add(data, 0x0))
                let cc := add(data, position)
                pmmData := add(cc, 0x0)
                takerAssetFillAmount := mload(add(data, takerAssetFillAmountPosition)) 
            }        
            (IPmmRouter.Order memory order, bytes memory signature) = parsePmmData(pmmData);
            IPmmRouter.FillResults memory fillResults = IPmmRouter(pmmRouter).fillOrder(order, takerAssetFillAmount, signature);
            receivedAmount = fillResults.makerAssetFilledAmount;
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("airswapLightFeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), airswapLight) == 0){
                    IERC20(tokenFrom).approve(airswapLight, type(uint256).max);
                }
            }
            bytes memory airswapData;
            assembly {
                airswapData := mload(add(data, 0x0))
                let cc := add(data, add(0x0, position))
                airswapData := add(cc, 0x0)
            }
            (IERC20 senderToken, uint256 signerAmount) = airSwapLightSwap(airswapData);
            assembly {
                feeAmount := mload(add(data, add(position, 0x160)))
            }
            destinationToken = address(senderToken);
            receivedAmount = signerAmount;
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("paraswapV5FeeDynamic")))){
            if(tokenFrom != address(0)){
                address proxy = IParaswapRouter(paraswapRouter).getTokenTransferProxy();
                if(IERC20(tokenFrom).allowance(address(this), proxy) == 0){
                    IERC20(tokenFrom).approve(proxy, type(uint256).max);
                }
            }
            bytes memory paraswapData;
            position = position + 0x120;
            assembly {
                paraswapData := mload(add(data, 0x0))
                let cc := add(data, position)
                paraswapData := add(cc, 0x0)
            }
            IParaswapRouter.SimpleData memory simpleData = parseParaswapData(paraswapData);
            if(tokenFrom != address(0)){
                receivedAmount = IParaswapRouter(paraswapRouter).simpleSwap(simpleData);
            }
            else{
                uint256 inputAmount;
                assembly {
                    inputAmount := mload(add(paraswapData, 0x84))
                }
                receivedAmount = IParaswapRouter(paraswapRouter).simpleSwap{value:inputAmount}(simpleData);
            }
        }

        bool success;
        bytes memory result;
        if(swappingTokenAmount < amount){
            if(tokenFrom != address(0)){
                IERC20(tokenFrom).transfer(feeAddress, feeAmount);
            }
            else{
                (success,) = payable(feeAddress).call{value: feeAmount}("");            
            }
        }
        if(destinationToken != address(0)){
            if(receivedAmount > IERC20(destinationToken).balanceOf(address(this))){
                receivedAmount = IERC20(destinationToken).balanceOf(address(this));
            }
            IERC20(destinationToken).transfer(msg.sender, receivedAmount);
        }
        else{
            if(receivedAmount > address(this).balance){
                receivedAmount = address(this).balance;
            }
            (success,result) = payable(msg.sender).call{value: receivedAmount}("");
        }
    }

    function parseParaswapData(bytes memory data) internal pure returns(
        IParaswapRouter.SimpleData memory simpleData
    ){
        (simpleData.fromToken,
        simpleData.toToken,
        simpleData.fromAmount,
        simpleData.toAmount,
        simpleData.expectedAmount,
        simpleData.beneficiary,
        simpleData.partner,
        simpleData.feePercent) = getParaswapData_1(data);

        (simpleData.deadline,
        simpleData.uuid,
        simpleData.callees,
        simpleData.exchangeData,
        simpleData.startIndexes,
        simpleData.values,
        simpleData.permit) = getParaswapData_2(data);
        return simpleData;
    }

    function getParaswapData_1(bytes memory data) internal pure returns(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 expectedAmount,
        address payable beneficiary,
        address payable partner,
        uint256 feePercent){
        assembly {
            fromToken := mload(add(data, 0x44))
            toToken := mload(add(data, 0x64))
            fromAmount := mload(add(data, 0x84))
            toAmount := mload(add(data, 0xA4))
            expectedAmount := mload(add(data, 0xC4))
            beneficiary := mload(add(data, 0x164))
            partner := mload(add(data, 0x184))
            feePercent := mload(add(data, 0x1A4))
        }        
    }

    function getParaswapData_2(bytes memory data) internal pure returns(
        uint256 deadline,
        bytes16 uuid,
        address[] memory callees,
        bytes memory exchangeData,
        uint256[] memory startIndexes,
        uint256[] memory values,
        bytes memory permit){
        uint32 length;
        
        assembly {
            deadline := mload(add(data, 0x1E4))
            uuid := mload(add(data, 0x204))
            length := mload(add(data, 0x224)) // length of callees
            callees := msize()
            mstore(add(callees, 0x00), length)
            for { let n := 0 } lt(n, length) { n := add(n, 1) } {
                mstore(add(callees, mul(add(n, 1), 0x20)), mload(add(data, add(0x244, mul(n, 0x20)))))
            }
            mstore(0x40, add(callees, mul(add(length, 1), 0x20)))
            let position := add(0x244, mul(0x20, length))
            length := mload(add(data, position)) // length of exchangeData

            exchangeData := mload(add(data, 0x0))
            let cc := add(data, position)
            exchangeData := add(cc, 0x0)

            position := add(add(position, length), 60)
            length := mload(add(data, position)) // length of startIndexes
            position := add(position, 0x20)
            startIndexes := msize()
            mstore(add(startIndexes, 0x00), length)
            for { let n := 0 } lt(n, length) { n := add(n, 1) } {
                mstore(add(startIndexes, mul(add(n, 1), 0x20)), mload(add(data, add(position, mul(n, 0x20)))))
            }
            mstore(0x40, add(startIndexes, mul(add(length, 1), 0x20)))

            position := add(position, mul(length, 0x20))
            length := mload(add(data, position)) // length of values
            position := add(position, 0x20)
            values := msize()
            mstore(add(values, 0x00), length)
            for { let n := 0 } lt(n, length) { n := add(n, 1) } {
                mstore(add(values, mul(add(n, 1), 0x20)), mload(add(data, add(position, mul(n, 0x20)))))
            }
            mstore(0x40, add(values, mul(add(length, 1), 0x20)))
            // permit := mload(add(data, 0x60))
        }
    }

    function parseAirSwapData(bytes memory data) internal pure returns(
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
    ){
        assembly {
            nonce := mload(add(data, 0x20))
            expiry := mload(add(data, 0x40))
            signerWallet := mload(add(data, 0x60))
            signerToken := mload(add(data, 0x80))
            signerAmount := mload(add(data, 0xA0))
            senderToken := mload(add(data, 0xC0))
            senderAmount := mload(add(data, 0xE0))
            v := mload(add(data, 0x100))
            r := mload(add(data, 0x120))
            s := mload(add(data, 0x140))
        }
    }

    function parsePmmData(bytes memory data) internal returns(
        IPmmRouter.Order memory order,
        bytes memory signature
    ){
        (order.makerAddress,          
        order.takerAddress,          
        order.feeRecipientAddress,   
        order.senderAddress,         
        order.makerAssetAmount,      
        order.takerAssetAmount,      
        order.makerFee) = getPmmOrderInfo_1(data);

        (order.takerFee,              
        order.expirationTimeSeconds, 
        order.salt,                  
        order.makerAssetData,          
        order.takerAssetData,
        signature) = getPmmOrderInfo_2(data);
    }
    function getPmmOrderInfo_1(bytes memory data) internal view returns(
        address makerAddress,
        address takerAddress,
        address feeRecipientAddress,
        address senderAddress,
        uint256 makerAssetAmount,
        uint256 takerAssetAmount,
        uint256 makerFee){
        assembly {
            makerAddress := mload(add(data, 0x20))
            // takerAddress := mload(add(data, 0x40))
            feeRecipientAddress := mload(add(data, 0x60))
            senderAddress := mload(add(data, 0x80))
            makerAssetAmount := mload(add(data, 0xA0))
            takerAssetAmount := mload(add(data, 0xC0))
            makerFee := mload(add(data, 0xE0))
        }
        takerAddress = address(this);
    }

    function getPmmOrderInfo_2(bytes memory data) internal pure returns(
        uint256 takerFee,
        uint256 expirationTimeSeconds,
        uint256 salt,
        bytes memory makerAssetData,
        bytes memory takerAssetData,
        bytes memory signature){
        uint256 length;
        assembly {
            takerFee := mload(add(data, 0x100))
            expirationTimeSeconds := mload(add(data, 0x120))
            salt := mload(add(data, 0x140))

            let position := 0x1A0
            length := mload(add(data, position)) // length of markerAssetData
            makerAssetData := mload(add(data, 0x0))
            let cc := add(data, 0x1A0)
            makerAssetData := add(cc, 0x0)

            position := add(add(position, length), 60)
            length := mload(add(data, position)) // length of takerAssetData
            takerAssetData := mload(add(data, 0x0))
            cc := add(data, position)
            takerAssetData := add(cc, 0x0)

            position := add(add(position, length), 60)
            signature := mload(add(data, 0x0))
            cc := add(data, position)
            signature := add(cc, 0x0)
        }
    }

    function parseOneInchData(bytes memory data) internal view returns(
        address _caller,
        IOneInchRouter.SwapDescription memory desc,
        bytes memory _data
    ){
        assembly {
            _caller := mload(add(data, 0x24))
        }

        (desc.srcToken,
        desc.dstToken,
        desc.srcReceiver,
        desc.dstReceiver,
        desc.amount,
        desc.minReturnAmount,
        desc.flags) = getOneInchDescData_1(data);

        (desc.permit,
        _data) = getOneInchDescData_2(data);
    }

    function getOneInchDescData_1(bytes memory data) internal view returns(
        IERC20 srcToken,
        IERC20 dstToken,
        address payable srcReceiver,
        address payable dstReceiver,
        uint256 amount,
        uint256 minReturnAmount,
        uint256 flags
    ){
        assembly {
            srcToken := mload(add(data, 0x84))
            dstToken := mload(add(data, 0xA4))
            srcReceiver := mload(add(data, 0xC4))
            // dstReceiver := mload(add(data, 0xE4))
            amount := mload(add(data, 0x104))
            minReturnAmount := mload(add(data, 0x124))
            flags := mload(add(data, 0x144))
        }
        dstReceiver = payable(address(this));
    }

    function getOneInchDescData_2(bytes memory data) internal pure returns(
        bytes memory permit,
        bytes memory _data
    ){
        uint256 lengthOfPermit;
        assembly {
            permit := mload(add(data, 0x0))
            let cc := add(data, 0x184)
            permit := add(cc, 0x0)
            lengthOfPermit := mload(add(data, 0x184))

            let position := add(0x184, lengthOfPermit)
            _data := mload(add(data, 0x0))
            cc := add(data, add(position, 0x20))
            _data := add(cc, 0x0)
        }
    }

    function airSwapLightSwap(bytes memory airswapData) internal returns(IERC20, uint256){
        (
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
        ) = parseAirSwapData(airswapData);
        {
            bytes32 hash = keccak256(
                abi.encode(
                IAirSwapLight(airswapLight).ORDER_TYPEHASH(),
                nonce,
                expiry,
                signerWallet,
                signerToken,
                signerAmount,
                IAirSwapLight(airswapLight).signerFee(),
                address(this),
                senderToken,
                senderAmount
                )
            );
            bytes32 digest =
            keccak256(abi.encodePacked("\x19\x01", IAirSwapLight(airswapLight).DOMAIN_SEPARATOR(), hash));
            address signatory = ecrecover(digest, v, r, s);
            IAirSwapLight(airswapLight).authorize(signatory);
        }

        IAirSwapLight(airswapLight).swap(
            nonce,
            expiry,
            signerWallet,
            signerToken,
            signerAmount,
            senderToken,
            senderAmount,
            v,
            r,
            s
        );
        return (senderToken, signerAmount);
    }

    function updateFeeAddress(address _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }
}