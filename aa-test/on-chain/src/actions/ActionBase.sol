// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { UAuth } from "../auth/UAuth.sol";

abstract contract ActionBase {
    enum ActionType {
        FL_ACTION,
        STANDARD_ACTION,
        FEE_ACTION,
        CHECK_ACTION,
        CUSTOM_ACTION
    }

    constructor() { }

    function actionType() public pure virtual returns (uint8);
}
