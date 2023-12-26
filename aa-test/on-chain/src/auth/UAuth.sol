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
}