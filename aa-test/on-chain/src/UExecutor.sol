// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { UAuth } from "./auth/UAuth.sol";
import { URegistry } from "./URegistry.sol";
import { UHelper } from "./utils/UHelper.sol";
import { IQueueVault } from "./interfaces/IQueueVault.sol";
import {IUValidator} from "./interfaces/IUValidator.sol";
import { ActionBase } from "./actions/ActionBase.sol";
import { IKernel } from "kernel.git/src/interfaces/IKernel.sol";

contract UExecutor is UAuth, UHelper {
    URegistry public constant registry = URegistry(UREGISTRY_ADDRESS);

    function executeQueue(uint256 _queueId, bytes[] calldata _params) public {
        IQueueVault queueVault = IQueueVault(registry.getAddr(bytes4(keccak256("QueueVault"))));
        queueVault.queueAccessCheck(_queueId);
        address firstAction = queueVault.getFirstAction(_queueId);

        if (_isFL(firstAction)) {
            _flashLoanFirst(_queueId, firstAction, _params);
        } else {
            (address[] memory actions, uint8[][] memory paramMapping) = queueVault.getActions(_queueId);

            bytes32[] memory returnValues = new bytes32[](actions.length);

            for (uint256 i = 0; i < actions.length; ++i) {
                returnValues[i] = _executeAction(actions, _params, paramMapping, i, returnValues);
            }
        }
    }

    function executeQueueFromFlashLoan(uint256 _queueId, bytes[] calldata _params, bytes32 debt) public {
        IQueueVault queueVault = IQueueVault(registry.getAddr(bytes4(keccak256("QueueVault"))));
        queueVault.queueAccessCheck(_queueId);

        (address[] memory actions, uint8[][] memory paramMapping) = queueVault.getActions(_queueId);

        bytes32[] memory returnValues = new bytes32[](actions.length);
        returnValues[0] = debt;

        for (uint256 i = 1; i < actions.length; ++i) {
            returnValues[i] = _executeAction(actions, _params, paramMapping, i, returnValues);
        }
    }

    function _flashLoanFirst(uint256 _queueId, address _firstAction, bytes[] calldata _params) internal {
        IUValidator validator = IUValidator(registry.getAddr(bytes4(keccak256("UValidator"))));
        IUValidator.AuthStatus status = validator.getAuthStatus();

        if(status == IUValidator.AuthStatus.PLUGIN_NOT_ADDED){
            revert('plug-in not added!');
        }
        if(status == IUValidator.AuthStatus.PLUGIN_NOT_ACTIVATED){
            validator.activateAuth();
        }

        ActionBase(_firstAction).executeAction(_queueId, _params);

        validator.deactivateAuth();
    }

    function _executeAction(
        address[] memory _actions,
        bytes[] calldata _params,
        uint8[][] memory _paramMapping,
        uint256 _index,
        bytes32[] memory _returnValues
    )
        internal
        returns (bytes32 response)
    {
        (bool success, bytes memory data) = _actions[_index].delegatecall(
            abi.encodeWithSignature(
                "executeAction(bytes,uint8[],bytes32[])", _params[_index], _paramMapping[_index], _returnValues
            )
        );

        require(success, 'delegateCall fail');

        response = bytes32(data);

    }

    function _isFL(address _firstAction) internal pure returns (bool) {
        return ActionBase(_firstAction).actionType() == uint8(ActionBase.ActionType.FL_ACTION);
    }
}
