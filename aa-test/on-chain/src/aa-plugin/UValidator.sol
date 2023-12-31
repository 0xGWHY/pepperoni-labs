// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { UserOperation } from "../interfaces/UserOperation.sol";
import { UAuth } from "../auth/UAuth.sol";
import { URegistry } from "../URegistry.sol";

contract UValidator is UAuth {
    URegistry uRegistry;

    constructor(address registryAddress) {
        uRegistry = URegistry(registryAddress);
    }

    error NotImplemented();

    struct AuthInfo {
        address owner;
        bool auth;
    }

    enum AuthStatus {
        PLUGIN_ENABLE,
        PLUGIN_NOT_ACTIVATED,
        PLUGIN_NOT_ADDED
    }

    type ValidationData is uint256;

    mapping(address => AuthInfo) auths;

    function enable(bytes calldata /*_data */) external payable {
        auths[msg.sender].owner = msg.sender;
    }

    function disable(bytes calldata /*_data*/) external payable {
        auths[msg.sender].owner = address(0);
        auths[msg.sender].auth = false;
    }

    function activateAuth() external {
        require(auths[msg.sender].owner != address(0), "add plugin first");
        auths[msg.sender].auth = true;
    }

    function deactivateAuth() external {
        require(auths[msg.sender].owner != address(0), "add plugin first");
        auths[msg.sender].auth = false;
    }

    function getAuthStatus() external view returns(AuthStatus){
        if(auths[msg.sender].owner == address(0)){
            return AuthStatus.PLUGIN_NOT_ADDED;
        } else if(auths[msg.sender].auth == false){
            return AuthStatus.PLUGIN_NOT_ACTIVATED;
        } else {
            return AuthStatus.PLUGIN_ENABLE;
        }
    }

    function validateUserOp(
        UserOperation calldata /* userOp */,
        bytes32 /*userOpHash */,
        uint256 /*missingFunds */
    )
        external
        payable
        returns (ValidationData)
    {
        revert NotImplemented();
    }

    function validateSignature(bytes32 /* hash */, bytes calldata /* signature */) external pure returns (ValidationData) {
        revert NotImplemented();
    }

    function validCaller(address caller, bytes calldata /* data */) external view returns (bool) {
        return uRegistry.isVerifiedContract(caller) && auths[msg.sender].auth;
    }
}
