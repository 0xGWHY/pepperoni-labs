// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { URegistry } from "../src/URegistry.sol";
import { UAuth } from "../src/auth/UAuth.sol";

contract URegistryTest is Test {
    URegistry public uRegistry;
    UAuth public uAuth;
    address public stranger;
    address entry;
    address thirdPartyEntry;
    address randomContract;

    function setUp() public {
        uAuth = new UAuth();
        uRegistry = new URegistry(address(uAuth));
        stranger = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, "stranger")))));
        entry = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, "entry")))));
        thirdPartyEntry =
            address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, "thirdPartyEntry")))));
        randomContract =
            address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, "randomContract")))));
    }

    function testFail_NonOwner() public {
        vm.prank(stranger); // Change identity to non-owner
        uRegistry.addNewContract(bytes4("test"), address(this), 0); // This should fail
    }

    function test_Owner() public {
        uRegistry.addNewContract(bytes4("test"), address(this), 0); // This should pass
    }

    function test_AddNewThirdPartyContract() public {
        uRegistry.addNewThirdPartyContract(address(this)); // Add current contract
    }

    function test_GetAddrAndIsRegistered() public {
        address getTest = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, "getTest")))));
        address third = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, "third")))));
        bytes4 id = bytes4(keccak256(abi.encodePacked("getTest")));
        uRegistry.addNewContract(id, getTest, 0);
        assertEq(uRegistry.getAddr(id), getTest); // Check if getAddr retrieves the correct address
        assertTrue(uRegistry.isRegistered(id)); // Check if isRegistered returns true

        bytes4 thirdId = uRegistry.addNewThirdPartyContract(third);
        assertEq(uRegistry.getAddr(thirdId), third); // Check if getAddr retrieves the correct
            // address for third party
        assertTrue(uRegistry.isRegistered(thirdId)); // Check if isRegistered returns true for third
            // party

        assertTrue(uRegistry.isVerifiedContract(id));
        assertFalse(uRegistry.isVerifiedContract(thirdId));
    }
}
