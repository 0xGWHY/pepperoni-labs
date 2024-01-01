// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../URegistry.sol";

contract QueueVault {
    URegistry uRegistry;

    modifier onlyManager(uint256 _queueId) {
        require(queues[_queueId].queueId != 0, "Queue does not exist");
        require(msg.sender == queues[_queueId].manager, "Only the manager can perform this operation");
        _;
    }

    constructor(address registryAddress) {
        uRegistry = URegistry(registryAddress);
    }

    enum QueueType {
        PUBLIC_QUEUE, // 0
        PRIVATE_QUEUE // 1

    }

    struct Queue {
        uint256 queueId;
        address manager;
        mapping(address => bool) whitelist;
        QueueType queueType;
        bytes4[] actions;
        uint8[][] paramMapping;
        uint256 fee;
        bool available;
        bool isVerified;
    }

    mapping(uint256 => Queue) queues;

    uint256 public queueCount = 1;

    function createQueue(
        address _manager,
        bytes4[] calldata _actions,
        uint8[][] calldata _paramMapping,
        uint256 _fee,
        address[] calldata _whitelist
    )
        public
        payable
    {
        bool verified = true;

        for (uint256 i = 0; i < _actions.length; i++) {
            if (!uRegistry.isVerifiedContract(_actions[i])) {
                verified = false;
                break;
            }
        }

        Queue storage newQueue = queues[queueCount];
        newQueue.queueId = queueCount;
        newQueue.manager = _manager;
        newQueue.actions = _actions;
        newQueue.paramMapping = _paramMapping;
        newQueue.fee = _fee;
        newQueue.available = true;
        newQueue.isVerified = verified;

        for (uint256 i = 0; i < _whitelist.length; i++) {
            newQueue.whitelist[_whitelist[i]] = true;
        }

        queueCount++;
    }

    function getFirstAction(uint256 _queueId) public view returns (address) {
        Queue storage queue = queues[_queueId];
        return uRegistry.getAddr(queue.actions[0]);
    }

    function getActions(uint256 _queueId) public view returns (address[] memory, uint8[][] memory) {
        Queue storage queue = queues[_queueId];
        address[] memory actions = new address[](queue.actions.length);
        uint8[][] memory paramMapping = new uint8[][](queue.paramMapping.length);
        for (uint256 i = 0; i < queue.actions.length; i++) {
            actions[i] = uRegistry.getAddr(queue.actions[i]);
            paramMapping[i] = queue.paramMapping[i];
        }
        return (actions, paramMapping);
    }

    function queueAccessCheck(uint256 queueId) public view {
        require(queues[queueId].queueId != 0, "Invalid queue id");
        require(queues[queueId].available, "This queue has been deactivated by the manager");
        if (queues[queueId].queueType == QueueType.PRIVATE_QUEUE) {
            require(queues[queueId].whitelist[msg.sender], "You do not have access to this Queue");
        }
    }

    /*
    Only manager functions
        1. setQueueHash
        2. setQueueFee
        3. setQueueWhitelist
        4. setQueueType
        5. setQueueManager
        6. setQueueAvailable
        7. setQueueVerified
    */

    function setQueueActions(
        uint256 _queueId,
        bytes4[] calldata _actions,
        uint8[][] calldata _paramMapping
    )
        public
        onlyManager(_queueId)
    {
        if (_actions.length > 0) {
            Queue storage queue = queues[_queueId];
            queue.actions = _actions;
            queue.paramMapping = _paramMapping;
            verificationCheck(_queueId);
        }
    }

    function setQueueFee(uint256 _queueId, uint256 _fee) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        queue.fee = _fee;
    }

    function setQueueWhitelist(uint256 _queueId, address[] calldata _whitelist) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        for (uint256 i = 0; i < _whitelist.length; i++) {
            queue.whitelist[_whitelist[i]] = true;
        }
    }

    function setQueueType(uint256 _queueId, QueueType _queueType) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        queue.queueType = _queueType;
    }

    function setQueueManager(uint256 _queueId, address _manager) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        queue.manager = _manager;
    }

    function setQueueAvailable(uint256 _queueId, bool _available) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        queue.available = _available;
    }

    function verificationCheck(uint256 _queueId) public {
        Queue storage queue = queues[_queueId];

        bytes4[] memory acts = queue.actions;

        bool verified = true;

        for (uint256 i = 0; i < acts.length; i++) {
            if (!uRegistry.isVerifiedContract(acts[i])) {
                verified = false;
                break;
            }
        }

        queue.isVerified = verified;
    }
}
