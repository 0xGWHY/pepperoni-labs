// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { ActionBase } from "../../ActionBase.sol";
import { TokenUtils } from "../../../utils/TokenUtils.sol";
import { Constants } from "../../../utils/Constants.sol";

contract UniswapV2ExactIn is ActionBase,Constants {
    using TokenUtils for address;

    struct Params {
        uint256 amountIn;
        uint256 amountOutMin;
        address to;
        address[] path;
        uint256 deadline;
    }

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
    {
        Params memory params = parseInputs(_params);
        bool eth;

        if(address(params.path[0]) == WETH_ADDRESS){
            TokenUtils.ensureETHAndWETH(WETH_ADDRESS, amountIn);
        } else {
            require(params.path[0].balanceOf(address(this)) >= params.amountIn, "Not enough TokenB");
        }

        if (params.path[params.path.length - 1] == ETH_ADDRESS) {
            params.path[params.path.length - 1] = WETH_ADDRESS;
            eth = true;
        }

        params.amountIn = _parseParamUint(params.amountIn, _paramMapping[0], _returnValues);
        params.amoutOutMin = _parseParamUint(params.amoutOutMin, _paramMapping[1], _returnValues);
        params.to = _parseParamAddr(params.to, _paramMapping[2], _returnValues);

        uint256 amount = _swapExactTokensForTokens(params);

        if(eth){
            TokenUtils.withdrawWeth(amount);
        }

        result = bytes32(amount);

        bytes memory logData = abi.encode(_queueId, _params.path[0], _params.path[_params.path.length - 1], params.amountIn,amount);
        emit ActionEvent("UniswapV2ExactIn", logData);
    }

    function executeActionDirect(bytes memory _params) public payable override {
        Params memory params = parseInputs(_params);
        bool eth;

        if(address(params.path[0]) == WETH_ADDRESS){
            TokenUtils.ensureETHAndWETH(WETH_ADDRESS, amountIn);
        } else {
            require(params.path[0].balanceOf(address(this)) >= params.amountIn, "Not enough TokenB");
        }

        if (params.path[params.path.length - 1] == ETH_ADDRESS) {
            params.path[params.path.length - 1] = WETH_ADDRESS;
            eth = true;
        }

        uint256 amount = _swapExactTokensForTokens(params);

        if(eth){
            TokenUtils.withdrawWeth(amount);
        }

        bytes memory logData = abi.encode(_params.path[0], _params.path[_params.path.length - 1], params.amountIn, amount);
        logger.logActionDirectEvent("UniswapV2ExactIn", logData);

        emit ActionEvent("UniswapV2ExactIn", logData);
    }

    function actionType() public pure override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    function parseInputs(bytes memory _params) public pure returns (Params memory params) {
        params = abi.decode(_params, (Params));
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    function _swapExactTokensForTokens(Params _params) internal returns (uint256 amount) {
        
        _params.path[0].approveToken(address(router), _params.amountIn);

        (address[] amounts) = router.swapExactTokensForTokens(
            _params.amountIn,
            _params.amountOutMin,
            _params.path,
            _params.to,
            _params.deadline
        );

        amount = amounts[amounts.length - 1];

        _params.path[0].revokeToken(address(router));
    }
    
}
