// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

    type ValidationData is uint256;

    mapping(address => AuthInfo) auths;

    function enable(bytes calldata _data) external payable {
        auths[msg.sender].owner = msg.sender;
    }

    function disable(bytes calldata _data) external payable {
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

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingFunds
    )
        external
        payable
        returns (ValidationData)
    {
        revert NotImplemented();
    }

    function validateSignature(
        bytes32 hash,
        bytes calldata signature
    )
        external
        view
        returns (ValidationData)
    {
        revert NotImplemented();
    }

    function validCaller(address caller, bytes calldata data) external view returns (bool) {
        return uRegistry.isVerifiedContract(caller) && auths[msg.sender].auth;
    }
}
