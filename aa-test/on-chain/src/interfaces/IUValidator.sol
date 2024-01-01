// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { UserOperation } from "./UserOperation.sol";

interface IUValidator {
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

    function enable(bytes calldata _data) external payable;
    function disable(bytes calldata _data) external payable;
    function activateAuth() external;
    function deactivateAuth() external;
    function getAuthStatus() external view returns (AuthStatus);
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingFunds
    )
        external
        payable
        returns (ValidationData);
    function validateSignature(bytes32 hash, bytes calldata signature) external pure returns (ValidationData);
    function validCaller(address caller, bytes calldata data) external view returns (bool);
}
