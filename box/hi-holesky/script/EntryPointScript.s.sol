// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import { Script, console2 } from "forge-std/Script.sol";
import { EntryPoint } from "../src/entry-point/core/EntryPoint.sol";

contract EntryPointScript is Script {
    function setUp() public { }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DYLAN_KEY");

        vm.startBroadcast(deployerPrivateKey);

        new EntryPoint();

        vm.stopBroadcast();
    }
}
