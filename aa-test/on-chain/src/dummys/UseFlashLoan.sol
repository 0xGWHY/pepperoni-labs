// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {FlashLoanSimpleReceiverBase} from "aave-v3-core/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";

contract UseFlashLoan is FlashLoanSimpleReceiverBase {
    string public user;

    function editor(string memory callMsg) public {
        user = callMsg;
    }
}