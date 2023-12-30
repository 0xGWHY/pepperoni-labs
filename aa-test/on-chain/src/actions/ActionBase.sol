// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { UAuth } from "../auth/UAuth.sol";
import { URegistry } from "../URegistry.sol";
import { UEventLogger } from "../logger/UEventLogger.sol";
import { UHelper } from "../utils/UHelper.sol";
import { IKernel } from "../../lib/kernel.git/src/interfaces/IKernel.sol";

abstract contract ActionBase is UHelper {
    event ActionEvent(string indexed logName, bytes data);

    URegistry public constant registry = URegistry(UREGISTRY_ADDRESS);

    UEventLogger public constant logger = UEventLogger(UEVENTLOGGER_ADDRESS);

    //Wrong return index value
    error ReturnIndexValueError();

    /// @dev Return params index range [1, 127]
    uint8 public constant RETURN_MIN_INDEX_VALUE = 1;
    uint8 public constant RETURN_MAX_INDEX_VALUE = 127;

    /// @dev If the input value should not be replaced
    uint8 public constant NO_PARAM_MAPPING = 0;

    /// @dev We need to parse Flash loan actions in a different way
    enum ActionType {
        FL_ACTION,
        STANDARD_ACTION,
        FEE_ACTION,
        CHECK_ACTION,
        CUSTOM_ACTION
    }

    function executeAction(
        bytes memory _callData,
        uint8[][] memory _paramMapping,
        bytes32[] memory _returnValues
    )
        public
        payable
        virtual
        returns (bytes32);

    function executeActionDirect(bytes memory _callData) public payable virtual;

    function actionType() public pure virtual returns (uint8);

    //////////////////////////// HELPER METHODS ////////////////////////////

    /// @notice Given an uint256 input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamUint(
        uint256 _param,
        uint8 _mapType,
        bytes32[] memory _returnValues
    )
        internal
        pure
        returns (uint256)
    {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = uint256(_returnValues[getReturnIndex(_mapType)]);
            }
        }

        return _param;
    }

    /// @notice Given an addr input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamAddr(
        address _param,
        uint8 _mapType,
        bytes32[] memory _returnValues
    )
        internal
        pure
        returns (address)
    {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = address(bytes20((_returnValues[getReturnIndex(_mapType)])));
            }
        }

        return _param;
    }

    /// @notice Given an bytes32 input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamABytes32(
        bytes32 _param,
        uint8 _mapType,
        bytes32[] memory _returnValues
    )
        internal
        pure
        returns (bytes32)
    {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = (_returnValues[getReturnIndex(_mapType)]);
            }
        }

        return _param;
    }

    /// @notice Checks if the paramMapping value indicated that we need to inject values
    /// @param _type Indicated the type of the input
    function isReplaceable(uint8 _type) internal pure returns (bool) {
        return _type != NO_PARAM_MAPPING;
    }

    /// @notice Checks if the paramMapping value is in the return value range
    /// @param _type Indicated the type of the input
    function isReturnInjection(uint8 _type) internal pure returns (bool) {
        return (_type >= RETURN_MIN_INDEX_VALUE) && (_type <= RETURN_MAX_INDEX_VALUE);
    }

    /// @notice Transforms the paramMapping value to the index in return array value
    /// @param _type Indicated the type of the input
    function getReturnIndex(uint8 _type) internal pure returns (uint8) {
        if (!(isReturnInjection(_type))) {
            revert ReturnIndexValueError();
        }

        return (_type - RETURN_MIN_INDEX_VALUE);
    }
}
