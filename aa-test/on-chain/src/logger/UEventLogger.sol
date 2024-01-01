// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract UEventLogger {
    event ExecuteQueueEvent(
        address indexed caller,
        uint256 indexed queueId
    );

    event ActionDirectEvent(
        address indexed caller,
        string indexed logName,
        bytes data
    );

    function logExecuteQueueEvent(
        uint256 _queueId
    ) public {
        emit ExecuteQueueEvent(msg.sender, _queueId);
    }

    function loglogActionDirectEventDirect(
        string memory _logName,
        bytes memory _data
    ) public {
        emit ActionDirectEvent(msg.sender, _logName, _data);
    }
}
