// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console2 } from "forge-std/Script.sol";
import { UAuth } from "../src/auth/UAuth.sol";
import { URegistry } from "../src/URegistry.sol";
import { UValidator } from "../src/aa-plugin/UValidator.sol";
import { UAuthorizedExecute } from "../src/aa-plugin/UAuthorizedExecute.sol";
import { QueueVault } from "../src/queue/QueueVault.sol";

contract DeployScript is Script {
    function setUp() public { }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("FREE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new UAuth();
        URegistry registry = new URegistry();
        new QueueVault(address(registry));
        new UValidator(address(registry));
        new UAuthorizedExecute();
        vm.stopBroadcast();
    }
}
