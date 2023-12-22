// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("FREE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Counter counter = new Counter();
        vm.stopBroadcast();
    }
}