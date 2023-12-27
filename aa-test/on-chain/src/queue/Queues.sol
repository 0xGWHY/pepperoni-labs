// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../URegistry.sol";
import {UAuth} from "../auth/UAuth.sol";

contract Queues is UAuth {
    URegistry uRegistry;

    modifier onlyManager(uint _queueId) {
        require(queues[_queueId].queueId != 0, "Queue does not exist");
        require(msg.sender == queues[_queueId].manager, "Only the manager can perform this operation");
        _;
    }

    constructor(address registryAddress) {
        uRegistry = URegistry(registryAddress);
    }

    enum QueueType {
        PUBLIC_QUEUE,  // 0
        PRIVATE_QUEUE  // 1
    }

    struct Queue {
        uint queueId;
        address manager;
        mapping(address => bool) whitelist;
        QueueType queueType;
        bytes4[] actions;
        uint256 fee;
        bool available;
        bool isVerified;
    }

    mapping(uint => Queue) queues;

    uint public queueCount = 1;
    
    function createQueue(address _manager, bytes4[] calldata _actions, uint256 _fee, address[] calldata _whitelist) public payable {

        bool verified = true;

        for (uint i = 0; i < _actions.length; i++) {
            if (!uRegistry.isVerifiedContract(_actions[i])) {
                verified = false;
                break;
            }
        }

        Queue storage newQueue = queues[queueCount];
        newQueue.queueId = queueCount;
        newQueue.manager = _manager;
        newQueue.actions = _actions;
        newQueue.fee = _fee;
        newQueue.available = true;
        newQueue.isVerified = verified;

        for (uint i = 0; i < _whitelist.length; i++) {
            newQueue.whitelist[_whitelist[i]] = true;
        }

        queueCount++;
    }

    function getQueue(uint _queueId) public view returns (uint, address, QueueType, bytes4[] memory, uint256, bool, bool) {
        Queue storage queue = queues[_queueId];
        return (queue.queueId, queue.manager, queue.queueType, queue.actions, queue.fee, queue.available, queue.isVerified);
    }

    function queueAccessCheck(uint queueId, address user) public view {
        require(queues[queueId].queueId != 0, "Invalid queue id");
        require(queues[queueId].available, "This queue has been deactivated by the manager");
        if(queues[queueId].queueType == QueueType.PRIVATE_QUEUE){
            require(queues[queueId].whitelist[user], "You do not have access to this Queue");
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

    function setQueueActions(uint _queueId, bytes4[] calldata _actions) public onlyManager(_queueId) {
        if(_actions.length > 0){
            Queue storage queue = queues[_queueId];
            queue.actions = _actions;
            verificationCheck(_queueId);
        }
    }

    function setQueueFee(uint _queueId, uint256 _fee) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        queue.fee = _fee;
    }

    function setQueueWhitelist(uint _queueId, address[] calldata _whitelist) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        for (uint i = 0; i < _whitelist.length; i++) {
            queue.whitelist[_whitelist[i]] = true;
        }
    }

    function setQueueType(uint _queueId, QueueType _queueType) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        queue.queueType = _queueType;
    }

    function setQueueManager(uint _queueId, address _manager) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        queue.manager = _manager;
    }

    function setQueueAvailable(uint _queueId, bool _available) public onlyManager(_queueId) {
        Queue storage queue = queues[_queueId];
        queue.available = _available;
    }

    function verificationCheck(uint _queueId) public {
        Queue storage queue = queues[_queueId];

        bytes4[] memory acts = queue.actions;
        
        bool verified = true;

        for (uint i = 0; i < acts.length; i++) {
            if (!uRegistry.isVerifiedContract(acts[i])) {
                verified = false;
                break;
            }
        }

        queue.isVerified = verified;
    }
}