// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ActionBase} from "../ActionBase.sol";
import {TokenUtils} from "../../utils/TokenUtils.sol";

contract RepayFlashLoan is ActionBase {
    using TokenUtils for address;

    error NotImplemented(string);

    struct Params {
        address receiver;
        address[] tokens;
        uint256[] amounts;
    }

    function executeAction(
        uint256 _recipeId,
        bytes memory _params,
        uint8[] memory,
        /**
         * _paramMapping
         */
        bytes32[] memory
    )
        public
        payable
        override
        returns (
            /**
             * _returnValues
             */
            bytes32 result
        )
    {
        Params memory params = parseInputs(_params);

        _sendTokens(params.receiver, params.tokens, params.amounts);

        result = bytes32(0);

        bytes memory logData = abi.encode(_recipeId, result);

        emit ActionEvent("RepayFlashLoan", logData);
    }

    function executeActionDirect(bytes memory) public payable override /**
     * _params
     */
    {
        revert NotImplemented("RepayFlashLoan");
    }

    function actionType() public pure override returns (uint8) {
        return uint8(ActionType.REPAY_FL_ACTION);
    }

    function parseInputs(
        bytes memory _params
    ) public pure returns (Params memory params) {
        params = abi.decode(_params, (Params));
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    function _sendTokens(
        address _receiver,
        address[] memory _tokens,
        uint256[] memory _amounts
    ) internal {
        for (uint256 i = 0; i < _tokens.length; ) {
            _tokens[i].withdrawTokens(_receiver, _amounts[i]);

            unchecked {
                ++i;
            }
        }
    }
}
