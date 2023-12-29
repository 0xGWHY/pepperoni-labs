// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { UAuth } from "./auth/UAuth.sol";
import { URegistry } from "./URegistry.sol";
import { UHelper } from "./utils/UHelper.sol";
import { QueueVault } from "./queue/QueueVault.sol";
import { ActionBase } from "./actions/ActionBase.sol";

contract UExecutor is UAuth, UHelper {
    URegistry public constant uRegistry = URegistry(UREGISTRY_ADDRESS);

    function executeQueue(uint256 _queueId, bytes[] calldata _params) public {
        QueueVault queueVault = QueueVault(uRegistry.getAddr(bytes4(keccak256("QueueVault"))));
        queueVault.queueAccessCheck(_queueId);
        address firstAction = queueVault.getFirstAction(_queueId);

        if (_isFL(firstAction)) {
            _flashLoanFirst(_queueId, firstAction, _params);
        } else {
            (address[] memory actions, uint256[] memory paramMapping) =
                queueVault.getActions(_queueId);
            _executeActions(actions, _params, paramMapping);
        }
    }

    function _flashLoanFirst(
        uint256 _queueId,
        address _firstAction,
        bytes[] calldata _params
    )
        internal
    { }

    function _executeActions(
        address[] memory actions,
        bytes[] calldata params,
        uint256[] memory paramMapping
    )
        internal
    {
        bytes32[] memory returnValues = new bytes32[](actions.length);
        for (uint256 i = 0; i < actions.length; ++i) {
            returnValues[i] = _executeAction(params, paramMapping, i, returnValues);
        }
    }

    function _executeActionsFromFlashLoan(
        address[] memory actions,
        bytes[] calldata params,
        uint256[] memory paramMapping
    )
        internal
    {
        bytes32[] memory returnValues = new bytes32[](actions.length);
        for (uint256 i = 0; i < actions.length; ++i) {
            returnValues[i] = _executeAction(params, paramMapping, i, returnValues);
        }
    }

    function _executeAction(
        bytes[] calldata _params,
        uint256[] memory _paramMapping,
        uint256 _index,
        bytes32[] memory _returnValues
    )
        internal
        returns (bytes32 response)
    {
        // address actionAddr = registry.getAddr(_currRecipe.actionIds[_index]);

        // response = IDSProxy(address(this)).execute(
        //     actionAddr,
        //     abi.encodeWithSignature(
        //         "executeAction(bytes,bytes32[],uint8[],bytes32[])",
        //         _currRecipe.callData[_index],
        //         _currRecipe.subData,
        //         _currRecipe.paramMapping[_index],
        //         _returnValues
        //     )
        // );
    }

    function _isFL(address _firstAction) internal pure returns (bool) {
        return ActionBase(_firstAction).actionType() == uint8(ActionBase.ActionType.FL_ACTION);
    }
}
