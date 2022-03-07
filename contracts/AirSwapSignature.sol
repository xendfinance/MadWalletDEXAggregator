// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AirSwapSignature{

    bytes32 public constant ORDER_TYPEHASH = 0x0dff175eea65781504a2f9b1454d4e7953e1c9c9cb76cb16ce5a5491f9b2961b;
    bytes32 public constant DOMAIN_SEPARATOR = 0x2dae893bad03fda26e751156bc0bb0159f9ac2a06838a9d05207492304758321;
    
    function getOrderHash(
        uint256 nonce,
        uint256 expiry,
        address signerWallet,
        IERC20 signerToken,
        uint256 signerAmount,
        uint256 signerFee,
        address senderWallet,
        IERC20 senderToken,
        uint256 senderAmount
    ) public view returns (bytes32) {
        return
        keccak256(
            abi.encode(
            ORDER_TYPEHASH,
            nonce,
            expiry,
            signerWallet,
            signerToken,
            signerAmount,
            signerFee,
            senderWallet,
            senderToken,
            senderAmount
            )
        );
    }

    function getSignatory(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (address) {
        bytes32 digest =
        keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hash));
        address signatory = ecrecover(digest, v, r, s);
        // Ensure the signatory is not null
        require(signatory != address(0), "INVALID_SIG");
        return signatory;
    }
}