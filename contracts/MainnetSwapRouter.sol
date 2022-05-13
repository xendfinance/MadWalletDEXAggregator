// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

interface IParaswapRouter {
    /**
    * @dev Returns address for spender
    */
    function getTokenTransferProxy() external view returns (address);
}

interface IAirSwapWrapper {
    
    /**
    * @notice Wrapped Swap
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
    ) external payable;

    /**
    * @dev Returns address for wrapped eth
    */

    function wethContract() external returns (address);
}

contract MainnetSwapRouter is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using AddressUpgradeable for address payable; 
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public paraswapRouter;
    address public airswapWrapper;
    address public zeroExRouter;
    address public oneInchRouter;
    address public feeAddress;

    function initialize() public initializer{
        paraswapRouter = address(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57);
        airswapWrapper = address(0x3A0e257568cc9c6c5d767d5DC0CD8A9Ac69Cc3aE);
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

        uint256 position;
        uint256 receivedAmount;
        uint256 feeAmount;
        address destinationToken;
        uint256 swappingTokenAmount;

        position = 0xE4;

        assembly {
            destinationToken := mload(add(data, add(position, 0x40)))
            swappingTokenAmount := mload(add(data, add(position, 0x60)))
            feeAmount := mload(add(data, add(position, 0x80)))
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
            position = position + 0xC0;
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
                (success, result) = zeroExRouter.call{value:swappingTokenAmount}(exSwapData);
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
            position = position + 0xC0;
            assembly {
                oneInchData := mload(add(data, 0x0))
                let cc := add(data, position)
                oneInchData := add(cc, 0x0)
            }
            bool success;
            bytes memory result;
            if(tokenFrom != address(0)){
                (success, result) = oneInchRouter.call(oneInchData);
            }
            else{
                (success, result) = oneInchRouter.call{value:swappingTokenAmount}(oneInchData);
            }
            if(success){
                assembly {
                    receivedAmount := mload(add(result, 0x20))
                }
            }
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("airswapV3FeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), airswapWrapper) == 0){
                    IERC20Upgradeable(tokenFrom).approve(airswapWrapper, type(uint256).max);
                }
            }
            bytes memory airswapData;
            position = position + 0xC0;
            assembly {
                airswapData := mload(add(data, 0x0))
                let cc := add(data, 0x1A4)
                airswapData := add(cc, 0x0)
            }
            (uint256 signerAmount) = airSwapV3Swap(airswapData);
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
            position = position + 0xC0;
            assembly {
                paraswapData := mload(add(data, 0x0))
                let cc := add(data, position)
                paraswapData := add(cc, 0x0)
            }
            bool success;
            bytes memory result;
            if(tokenFrom != address(0)){
                (success, result) = paraswapRouter.call(paraswapData);
            }
            else{
                (success, result) = paraswapRouter.call{value:swappingTokenAmount}(paraswapData);
            }
            if(success){
                assembly {
                    receivedAmount := mload(add(result, 0x20))
                }
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
                require(success, "Failed to send ETH");
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
            require(success, "Failed to send ETH");
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

    function airSwapV3Swap(bytes memory airswapData) internal returns(uint256){
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

        if(senderToken == IAirSwapWrapper(airswapWrapper).wethContract()){
            IAirSwapWrapper(airswapWrapper).swap{value:senderAmount}(
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
        }

        else {
            IAirSwapWrapper(airswapWrapper).swap(
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
        }
        return signerAmount;
    }

    /**
    * @notice Update feeAddress
    * @param _feeAddress New feeAddress
    */

    function updateFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "INVALID_FEE_WALLET");
        feeAddress = _feeAddress;
    }
}