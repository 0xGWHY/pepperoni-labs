// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract UAuthorizedExecute {
    function uExecuteDelegateCall(address to, bytes memory data) external payable {
        assembly {
            let success := delegatecall(gas(), to, add(data, 0x20), mload(data), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
