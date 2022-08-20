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

contract SwapRouter is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using AddressUpgradeable for address payable; 
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public paraswapRouter;
    address public airswapWrapper;
    address public zeroExRouter;
    address public oneInchRouter;
    address public feeAddress;
    
    event Swap(string indexed aggregatorId, address indexed caller, address indexed sourceToken, uint256 sourceTokenAmount, address destinationToken, uint256 destinationTokenAmount, address feeAddress, uint256 feeAmount);

    function initialize() public initializer{
        paraswapRouter = address(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57);
        airswapWrapper = address(0xC32a3c867aBAd28d977e1724f92D9684fF3d2976);
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

        uint256 receivedAmount;
        uint256 feeAmount;
        address destinationToken;
        uint256 swappingTokenAmount;
        bool success;
        bytes memory result;
        bytes memory swapData;
        address swapRouterAddress;

        assembly {
            destinationToken := mload(add(data, 0x40))
            swappingTokenAmount := mload(add(data, 0x60))
            receivedAmount := mload(add(data, 0x80))
            feeAmount := mload(add(data, 0xA0))
            swapData := mload(add(data, 0x0))
            let cc := add(data, 0xE0)
            swapData := add(cc, 0x0)
        }

        if(keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("0xFeeDynamic")))){
            swapRouterAddress = zeroExRouter;
            if(tokenFrom != address(0)){
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), zeroExRouter) == 0){
                    IERC20Upgradeable(tokenFrom).approve(zeroExRouter, type(uint256).max);
                }
            }
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("oneInchV4FeeDynamic")))){
            swapRouterAddress = oneInchRouter;
            if(tokenFrom != address(0)){
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), oneInchRouter) == 0){
                    IERC20Upgradeable(tokenFrom).approve(oneInchRouter, type(uint256).max);
                }
            }
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("airswapV3FeeDynamic")))){
            swapRouterAddress = airswapWrapper;
            if(tokenFrom != address(0)){
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), airswapWrapper) == 0){
                    IERC20Upgradeable(tokenFrom).approve(airswapWrapper, type(uint256).max);
                }
            }
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("paraswapV5FeeDynamic")))){
            swapRouterAddress = paraswapRouter;
            if(tokenFrom != address(0)){
                address proxy = IParaswapRouter(paraswapRouter).getTokenTransferProxy();
                if(IERC20Upgradeable(tokenFrom).allowance(address(this), proxy) == 0){
                    IERC20Upgradeable(tokenFrom).approve(proxy, type(uint256).max);
                }
            }
        }
        if(tokenFrom != address(0)){
            IERC20Upgradeable(tokenFrom).safeTransferFrom(_msgSender(), address(this), amount);
            (success, result) = swapRouterAddress.call(swapData);
        }
        else{
            (success, result) = swapRouterAddress.call{value:swappingTokenAmount}(swapData);
        }
        
        require(success, "Failed to swap");

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

        emit Swap(aggregatorId, _msgSender(), tokenFrom, amount, destinationToken, receivedAmount, feeAddress, feeAmount);
    }

    /**
    * @notice Update feeAddress
    * @param _feeAddress New feeAddress
    */

    function updateFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "INVALID_FEE_WALLET");
        feeAddress = _feeAddress;
    }

    /**
    * @notice Update paraswapRouter
    * @param _paraswapRouter New paraswapRouter
    */

    function updateParaswapRouter(address _paraswapRouter) external onlyOwner {
        require(_paraswapRouter != address(0), "INVALID_ADDRESS");
        paraswapRouter = _paraswapRouter;
    }

    /**
    * @notice Update airswapWrapper
    * @param _airswapWrapper New airswapWrapper
    */

    function updateAirswapWrapper(address _airswapWrapper) external onlyOwner {
        require(_airswapWrapper != address(0), "INVALID_ADDRESS");
        airswapWrapper = _airswapWrapper;
    }

    /**
    * @notice Update zeroExRouter
    * @param _zeroExRouter New zeroExRouter
    */

    function updateZeroExRouter(address _zeroExRouter) external onlyOwner {
        require(_zeroExRouter != address(0), "INVALID_ADDRESS");
        zeroExRouter = _zeroExRouter;
    }

    /**
    * @notice Update oneInchRouter
    * @param _oneInchRouter New oneInchRouter
    */

    function updateOneInchRouter(address _oneInchRouter) external onlyOwner {
        require(_oneInchRouter != address(0), "INVALID_ADDRESS");
        oneInchRouter = _oneInchRouter;
    }
}