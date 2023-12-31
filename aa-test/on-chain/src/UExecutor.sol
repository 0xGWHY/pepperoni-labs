// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { URegistry } from "./URegistry.sol";
import { Constants } from "./utils/Constants.sol";
import { IQueueVault } from "./interfaces/IQueueVault.sol";
import { IUValidator } from "./interfaces/IUValidator.sol";
import { ActionBase } from "./actions/ActionBase.sol";
import { FlashLoanBase } from "./actions/FlashLoanBase.sol";
import { IKernel } from "kernel/IKernel.sol";
import {UEventLogger} from "./logger/UEventLogger.sol";

contract UExecutor is Constants {
    URegistry public constant registry = URegistry(UREGISTRY_ADDRESS);
    UEventLogger public constant logger = UEventLogger(UEVENTLOGGER_ADDRESS);

    // step start 1
    event Process(uint256 indexed queueId, address actionAddress, uint256 currentStep, uint256 tottalStep);

    function executeQueue(uint256 _queueId, bytes[] calldata _params) public payable {
        IQueueVault queueVault = IQueueVault(registry.getAddr(bytes4(keccak256(bytes("QueueVault")))));
        queueVault.queueAccessCheck(_queueId);
        address firstAction = queueVault.getFirstAction(_queueId);

        if (_isFL(firstAction)) {
            _flashLoanFirst(_queueId, firstAction, _params);
        } else {
            (address[] memory actions, uint8[][] memory paramMapping) = queueVault.getActions(_queueId);

            bytes32[] memory returnValues = new bytes32[](actions.length);

            for (uint256 i = 0; i < actions.length; ++i) {
                returnValues[i] = _executeAction(_queueId, actions[i], _params[i], paramMapping[i], returnValues);

                emit Process(_queueId, actions[i], i + 1, actions.length);
            }
        }

        logger.logExecuteQueueEvent(_queueId);
    }

    function executeQueueFromFlashLoan(uint256 _queueId, bytes[] calldata _params, bytes32 debt) public {
        IQueueVault queueVault = IQueueVault(registry.getAddr(bytes4(keccak256(bytes("QueueVault")))));
        queueVault.queueAccessCheck(_queueId);

        (address[] memory actions, uint8[][] memory paramMapping) = queueVault.getActions(_queueId);

        bytes32[] memory returnValues = new bytes32[](actions.length);
        returnValues[0] = debt;

        for (uint256 i = 1; i < actions.length; ++i) {
            returnValues[i] = _executeAction(_queueId, actions[i], _params[i], paramMapping[i], returnValues);

            emit Process(_queueId, actions[i], i + 1, actions.length);
        }
    }

    function _flashLoanFirst(uint256 _queueId, address _firstAction, bytes[] calldata _params) internal {
        IUValidator validator = IUValidator(registry.getAddr(bytes4(keccak256(bytes("UValidator")))));
        IUValidator.AuthStatus status = validator.getAuthStatus();

        if (status == IUValidator.AuthStatus.PLUGIN_NOT_ADDED) {
            revert("plug-in not added!");
        }
        if (status == IUValidator.AuthStatus.PLUGIN_NOT_ACTIVATED) {
            validator.activateAuth();
        }

        FlashLoanBase(_firstAction).executeAction(_queueId, _params);

        validator.deactivateAuth();
    }

    function _executeAction(
        uint256 _queueId,
        address _actions,
        bytes calldata _params,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    )
        internal
        returns (bytes32 response)
    {
        (bool success, bytes memory data) = _actions.delegatecall(
            abi.encodeWithSignature("executeAction(uint256, bytes,uint8[],bytes32[])", _queueId, _params, _paramMapping, _returnValues)
        );

        require(success, "delegateCall fail");

        response = bytes32(data);
    }

    function _isFL(address _firstAction) internal pure returns (bool) {
        return ActionBase(_firstAction).actionType() == uint8(ActionBase.ActionType.FL_ACTION);
    }
}
