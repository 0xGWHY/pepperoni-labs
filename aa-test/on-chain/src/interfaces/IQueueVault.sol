// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IQueueVault {

    enum QueueType {
        PUBLIC_QUEUE, // 0
        PRIVATE_QUEUE // 1
    }

    function createQueue(
        address _manager,
        bytes4[] calldata _actions,
        uint8[][] calldata _paramMapping,
        uint256 _fee,
        address[] calldata _whitelist
    ) external payable;

    function getFirstAction(uint256 _queueId) external view returns (address);

    function getActions(uint256 _queueId) external view returns (address[] memory, uint8[][] memory);

    function queueAccessCheck(uint256 queueId) external view;

    function setQueueActions(
        uint256 _queueId,
        bytes4[] calldata _actions,
        uint8[][] calldata _paramMapping
    ) external;

    function setQueueFee(uint256 _queueId, uint256 _fee) external;

    function setQueueWhitelist(uint256 _queueId, address[] calldata _whitelist) external;

    function setQueueType(uint256 _queueId, QueueType _queueType) external;

    function setQueueManager(uint256 _queueId, address _manager) external;

    function setQueueAvailable(uint256 _queueId, bool _available) external;

    function verificationCheck(uint256 _queueId) external;
}