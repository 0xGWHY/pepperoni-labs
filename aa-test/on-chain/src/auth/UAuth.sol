// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract UAuth {
    address private _owner;

    struct Writer {
        address writer;
        address contractAddress;
        bool exists;
    }

    mapping(bytes4 => Writer) writers;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event thirdPartyWriterwnershipTransferred(bytes4 contractId, address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "UAuth: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "UAuth: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /*
    Third party functions
    */
    modifier onlyWriter(bytes4 _contractId) {
        require(isWriter(_contractId), "UAuth: caller is not writer");
        _;
    }
    function addWriter(address _contractAddress ) public {
        bytes4 _id = bytes4(keccak256(abi.encodePacked(msg.sender, _contractAddress)));
        writers[_id].contractAddress = _contractAddress;
        writers[_id].exists = true;
    }
    function isWriter(bytes4 _contractId) public view returns (bool) {
        return msg.sender == writers[_contractId].writer;
    }
    function setWriter(bytes4 _contractId, address newOwner) public onlyWriter(_contractId) {
        require(newOwner != address(0), "UAuth: new owner is the zero address");
        require(writers[_contractId].exists, "Invalid _contractId");
        emit thirdPartyWriterwnershipTransferred(_contractId, _owner, newOwner);
        writers[_contractId].writer = newOwner;
    }
}