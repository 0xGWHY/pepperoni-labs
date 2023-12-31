// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ActionBase} from "../../ActionBase.sol";
// input이 ETH라면 먼저 WETH로 wrap
// https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02#addliquidity

contract UniswapV2AddLiquidity is ActionBase {
    function executeAction(
        bytes memory _params,
        uint8[][] memory _paramMapping,
        bytes32[] memory _returnValues
    )
        public
        payable
        override
        returns (bytes32){}

    function executeAction(
        uint256 _queueId,
        bytes[] calldata _params
    )
        public
        payable
        override
        returns (bytes32){}

    function executeActionDirect(bytes memory _params) public payable override{}

    function actionType() public pure override returns (uint8){}
}