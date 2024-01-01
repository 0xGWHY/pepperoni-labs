// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { ActionBase } from "../../ActionBase.sol";
import { TokenUtils } from "../../../utils/TokenUtils.sol";
// Out이 ETH라면 로직 완료 후 Unwrap
// https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02#swaptokensforexacttokens

contract UniswapV2ExactOut is ActionBase {
    using TokenUtils for address;

    struct Params { }

    function executeAction(
        uint256 _queueId,
        bytes memory _params,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    )
        public
        payable
        override
        returns (bytes32 result)
    { }

    function executeActionDirect(bytes memory _params) public payable override { }

    function actionType() public pure override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    function parseInputs(bytes memory _params) public pure returns (Params memory params) {
        params = abi.decode(_params, (Params));
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////
}
