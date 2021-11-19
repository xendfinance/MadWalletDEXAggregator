// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract AbstractTCLEntity is Ownable {

    address internal _admin;

    /* modifiers */
    modifier onlyOwnerOrAdmin {
        if(_admin != address(0)){
            require(_msgSender() == owner() || _msgSender() == admin(), "TCL Entity: Sender is neither owner nor admin.");
        }
        else {
            require(_msgSender() == owner(),  "TCL Entity: Sender is not owner.");
        }
        _;
    }

    /* getter & setter for admin address */
    function admin() public view returns (address) {
        return _admin;
    }
    function setAdmin(address newAdmin) external onlyOwnerOrAdmin {
        require(newAdmin != address(0), "TCL Entity: Admin cannot be AddressZero");
        require(newAdmin != owner(), "TCL Entity: Owner and admin cannot be the same address.");
        _admin = newAdmin;
    }
}