// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console2 } from "forge-std/Script.sol";
import { UAuth } from "../src/auth/UAuth.sol";
import { URegistry } from "../src/URegistry.sol";
import {Constants} from "../src/utils/Constants.sol";

contract DeploySetUp is Script {
    
    function run() public {

        uint256 deployerPrivateKey = vm.envUint("FREE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        UAuth auth = new UAuth();
        new URegistry(address(auth));
        new Constants();

        vm.stopBroadcast();
    }
}
