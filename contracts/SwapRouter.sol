// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

interface IParaswapRouter {

    /**
    * @notice ParaswapV5
    * @param fromToken Address of the source token
    * @param fromAmount Amount of source tokens to be swapped
    * @param toAmount Minimum destination token amount expected out of this swap
    * @param expectedAmount Expected amount of destination tokens without slippage
    * @param beneficiary Beneficiary address
    * 0 then 100% will be transferred to beneficiary. Pass 10000 for 100%
    */

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

    /**
    * @param data Swap Data
    * @return receivedAmount Resulting token amount
    */

    function simpleSwap(
        SimpleData memory data
    ) external payable returns (uint256 receivedAmount);

    /**
    * @dev Returns address for spender
    */
    function getTokenTransferProxy() external view returns (address);
}

interface IAirSwapV3 {
    
    /**
    * @notice AirSwapV3
    * @param nonce uint256 Unique and should be sequential
    * @param expiry uint256 Expiry in seconds since 1 January 1970
    * @param signerWallet address Wallet of the signer
    * @param signerToken address ERC20 token transferred from the signer
    * @param signerAmount uint256 Amount transferred from the signer
    * @param senderToken address ERC20 token transferred from the sender
    * @param senderAmount uint256 Amount transferred from the sender
    * @param v uint8 "v" value of the ECDSA signature
    * @param r bytes32 "r" value of the ECDSA signature
    * @param s bytes32 "s" value of the ECDSA signature
    */

    function swap(
        address recipient,
        uint256 nonce,
        uint256 expiry,
        address signerWallet,
        address signerToken,
        uint256 signerAmount,
        address senderToken,
        uint256 senderAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IOneInchRouter {

    /**
    * @notice OneInch
    * @param srcToken Source token
    * @param dstToken Destination Token
    * @param srcReceiver Address that will receive swap funds
    * @param dstReceiver The address to receive the output of the swap
    * @param amount Amount of source tokens to swap
    * @param minReturnAmount Minimal allowed returnAmount to make transaction commit
    * @param flags Option for burn chi, wrap Eth, unwrap Eth ...
    * @param permit Should contain valid permit that can be used in `IERC20Permit.permit` calls.
    */

    struct SwapDescription {
        IERC20Upgradeable srcToken;
        IERC20Upgradeable dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }
    /**
    * @notice OneInchSwap
    * Performs a swap, delegating all calls encoded in `data` to `caller`. See tests for usage examples
    * @param caller Aggregation executor that executes calls described in `data`
    * @param desc Swap description
    * @param data Encoded calls that `caller` should execute in between of swaps
    * @return returnAmount Resulting token amount
    * @return gasLeft Gas left
    */

    function swap(
        address caller,
        SwapDescription calldata desc,
        bytes calldata data
    )
    external
    payable
    returns (uint256 returnAmount, uint256 gasLeft);
}

contract SwapRouter is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using AddressUpgradeable for address payable; 
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public paraswapRouter;
    address public airswapV3;
    address public zeroExRouter;
    address public oneInchRouter;
    address public feeAddress;

    function initialize() public initializer{
        paraswapRouter = address(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57);
        airswapV3 = address(0x132F13C3896eAB218762B9e46F55C9c478905849);
        zeroExRouter = address(0xDef1C0ded9bec7F1a1670819833240f027b25EfF);
        oneInchRouter = address(0x1111111254fb6c44bAC0beD2854e76F90643097d);
        feeAddress = address(0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA);
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    receive() external payable {}

    /**
    * @notice Performs a swap
    * @param aggregatorId Selected Dex for swapping
    * @param tokenFrom Address of source token to be swapped
    * @param amount Amount of source token
    * @param data Encoded data for swapping
    */ 

    function swap(string memory aggregatorId, address tokenFrom, uint256 amount, bytes memory data) external payable nonReentrant {

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
            IERC20Upgradeable(tokenFrom).safeTransferFrom(_msgSender(), address(this), amount);
        }

        if(keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("0xFeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), zeroExRouter) == 0){
                    IERC20Upgradeable(tokenFrom).approve(zeroExRouter, type(uint256).max);
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
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), oneInchRouter) == 0){
                    IERC20Upgradeable(tokenFrom).approve(oneInchRouter, type(uint256).max);
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
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("airswapV3FeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), airswapV3) == 0){
                    IERC20Upgradeable(tokenFrom).approve(airswapV3, type(uint256).max);
                }
            }
            bytes memory airswapData;
            assembly {
                airswapData := mload(add(data, 0x0))
                let cc := add(data, add(0x0, position))
                airswapData := add(cc, 0x0)
            }
            (address signerToken, uint256 signerAmount, uint256 senderAmount) = airSwapV3Swap(airswapData);
            assembly {
                feeAmount := mload(add(data, add(position, 0x160)))
            }
            destinationToken = signerToken;
            swappingTokenAmount = senderAmount;
            receivedAmount = signerAmount;
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("paraswapV5FeeDynamic")))){
            if(tokenFrom != address(0)){
                address proxy = IParaswapRouter(paraswapRouter).getTokenTransferProxy();
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), proxy) == 0){
                    IERC20Upgradeable(tokenFrom).approve(proxy, type(uint256).max);
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
                IERC20Upgradeable(tokenFrom).safeTransfer(feeAddress, feeAmount);
            }
            else{
                (success,result) = payable(feeAddress).call{value: feeAmount}("");
                require(success, "Failed to send BNB");
            }
        }
        if(destinationToken != address(0)){
            if(receivedAmount > IERC20Upgradeable(destinationToken).balanceOf(address(this))){
                receivedAmount = IERC20Upgradeable(destinationToken).balanceOf(address(this));
            }
            IERC20Upgradeable(destinationToken).safeTransfer(_msgSender(), receivedAmount);
        }
        else{
            if(receivedAmount > address(this).balance){
                receivedAmount = address(this).balance;
            }
            (success,result) = payable(_msgSender()).call{value: receivedAmount}("");
            require(success, "Failed to send BNB");
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
        }
    }

    function parseAirSwapV3Data(bytes memory data) internal pure returns(
        uint256 nonce,
        uint256 expiry,
        address signerWallet,
        address signerToken,
        uint256 signerAmount,
        address senderToken,
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
        IERC20Upgradeable srcToken,
        IERC20Upgradeable dstToken,
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

    function airSwapV3Swap(bytes memory airswapData) internal returns(address, uint256, uint256){
        (
            uint256 nonce,
            uint256 expiry,
            address signerWallet,
            address signerToken,
            uint256 signerAmount,
            address senderToken,
            uint256 senderAmount,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = parseAirSwapV3Data(airswapData);

        IAirSwapV3(airswapV3).swap(
            address(this),
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
        return (signerToken, signerAmount, senderAmount);
    }

    function updateFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "INVALID_FEE_WALLET");
        feeAddress = _feeAddress;
    }
}