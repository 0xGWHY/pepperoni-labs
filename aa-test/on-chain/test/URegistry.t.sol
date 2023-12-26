// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {URegistry} from "../src/URegistry.sol";
import {UAuth} from "../src/auth/UAuth.sol";

contract URegistryTest is Test, UAuth {
    URegistry public uRegistry;
    address public stranger;
    address entry;
    address thirdPartyEntry;
    address randomContract;

    function setUp() public {
        uRegistry = new URegistry();
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

    function test_ChangeContractAddress() public {
        bytes4 id = bytes4(keccak256(abi.encodePacked("changeTest")));
        address existingAddress =
            address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, "existingAddress")))));
        uRegistry.addNewContract(id, existingAddress, 2);
        address newAddress =
            address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, "newAddress")))));

        uRegistry.startContractChange(id, newAddress); // Start contract change
        (,,, bool inContractChange,,) = uRegistry.getEntry(id); // Get the updated entry
        assertTrue(inContractChange, "contract change fail"); // Check if inContractChange is true

        try uRegistry.approveContractChange(id) {
            assert(false); // This should fail
        } catch {}
        (, uint256 waitPeriod,,,,) = uRegistry.getEntry(id); // Get the updated entry

        vm.warp(block.timestamp + waitPeriod); // Advance time
        uRegistry.approveContractChange(id); // Approve contract change
        (address contractAddr,,,,,) = uRegistry.getEntry(id);
        assertEq(contractAddr, newAddress); // Check if contract address has been changed
        (,,, bool inContractChange2,,) = uRegistry.getEntry(id); // Get the updated entry
        assertFalse(inContractChange2); // Check if inContractChange is false
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
        assertEq(uRegistry.getAddr(thirdId), third); // Check if getAddr retrieves the correct address for third party
        assertTrue(uRegistry.isRegistered(thirdId)); // Check if isRegistered returns true for third party

        assertTrue(uRegistry.isVerifiedContract(id));
        assertFalse(uRegistry.isVerifiedContract(thirdId));
    }
}
