// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

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
        address makerAddress;           // Address that created the order.      
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.          
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.      
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.        
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.        
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.          
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.     
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    /// @dev Fills the input order.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.

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

contract SwapRouter is Context, ReentrancyGuard, Initializable{
    using SafeERC20 for IERC20;

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public paraswapRouter;
    address public airswapLight;
    address public zeroExRouter;
    address public pmmRouter;
    address public oneInchRouter;
    address public feeAddress;

    constructor() {}

    function initialize() public initializer{
        _transferOwnership(_msgSender());
        paraswapRouter = address(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57);
        airswapLight = address(0xc98314a5077DBa8F12991B29bcE39F834E82e197);
        zeroExRouter = address(0xDef1C0ded9bec7F1a1670819833240f027b25EfF);
        pmmRouter = address(0x3F93C3D9304a70c9104642AB8cD37b1E2a7c203A);
        oneInchRouter = address(0x1111111254fb6c44bAC0beD2854e76F90643097d);
        feeAddress = address(0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA);
    }

    receive() external payable {}

    function swap(string memory aggregatorId, address tokenFrom, uint256 amount, bytes memory data) external payable{

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
            IERC20(tokenFrom).safeTransferFrom(msg.sender, address(this), amount);
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
                IERC20(tokenFrom).safeTransfer(feeAddress, feeAmount);
            }
            else{
                (success,result) = payable(feeAddress).call{value: feeAmount}("");
                require(success, "Failed to send BNB");
            }
        }
        if(destinationToken != address(0)){
            if(receivedAmount > IERC20(destinationToken).balanceOf(address(this))){
                receivedAmount = IERC20(destinationToken).balanceOf(address(this));
            }
            IERC20(destinationToken).safeTransfer(msg.sender, receivedAmount);
        }
        else{
            if(receivedAmount > address(this).balance){
                receivedAmount = address(this).balance;
            }
            (success,result) = payable(msg.sender).call{value: receivedAmount}("");
            require(success, "Failed to send BNB");
        }
    }

    /**
    * @param fromToken Address of the source token
    * @param fromAmount Amount of source tokens to be swapped
    * @param toAmount Minimum destination token amount expected out of this swap
    * @param expectedAmount Expected amount of destination tokens without slippage
    * @param beneficiary Beneficiary address
    * 0 then 100% will be transferred to beneficiary. Pass 10000 for 100%
    * @param path Route to be taken for this swap to take place

    */

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

    /**
    * @notice AirSwap
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

    /// @param order Order quote to fill
    /// @param signature Signature to confirm quote ownership

    function parsePmmData(bytes memory data) internal view returns(
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

    /// @param _caller Aggregation executor that executes calls described in `data`
    /// @param desc Swap description
    /// @param _data Encoded calls that `caller` should execute in between of swaps

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

    function updateFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "INVALID_FEE_WALLET");
        feeAddress = _feeAddress;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}