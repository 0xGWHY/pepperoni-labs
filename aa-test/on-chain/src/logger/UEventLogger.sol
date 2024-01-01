// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract UEventLogger {
    event ExecuteQueueEvent(
        address indexed caller,
        uint256 indexed queueId,
        uint256 indexed value
    );

    event ActionDirectEvent(
        address indexed caller,
        string indexed logName,
        bytes data
    );

    function logExecuteQueueEvent(
        uint256 _queueId,
        uint256 _value
    ) public {
        emit ExecuteQueueEvent(msg.sender, _queueId, _value);
    }

    function loglogActionDirectEventDirect(
        string memory _logName,
        bytes memory _data
    ) public {
        emit ActionDirectEvent(msg.sender, _logName, _data);
    }
}
