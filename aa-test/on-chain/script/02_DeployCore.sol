// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console2 } from "forge-std/Script.sol";
import { UAuth } from "../src/auth/UAuth.sol";
import { URegistry } from "../src/URegistry.sol";
import { UValidator } from "../src/aa-plugin/UValidator.sol";
import { UAuthorizedExecute } from "../src/aa-plugin/UAuthorizedExecute.sol";
import { QueueVault } from "../src/queue/QueueVault.sol";
import {Constants} from "../src/utils/Constants.sol";

contract DeployCore is Script, Constants {

    string[] contractNames = [
        "QueueVault",
        "UValidator",
        "UAuthorizedExecute"
    ];

    address[] contractAddresses;

    bytes4[] contractIds;

    URegistry registry = URegistry(UREGISTRY_ADDRESS);

    function setUp() internal { 
        for (uint i = 0; i < contractNames.length; i++) {
            contractIds.push(bytes4(keccak256(bytes(contractNames[i]))));
        }
    }

    function addContractIds() internal {
        require(contractAddresses.length == contractIds.length, 'something wrong');
        for (uint i = 0; i < contractIds.length; i++) {
            registry.addNewContract(contractIds[i], contractAddresses[i], 0);
        }
    }

    function run() public {

        setUp();

        uint256 deployerPrivateKey = vm.envUint("FREE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        QueueVault queueVault = new QueueVault(address(registry));
        contractAddresses.push(address(queueVault));

        UValidator validator = new UValidator(address(registry));
        contractAddresses.push(address(validator));

        UAuthorizedExecute authorizedExecutor = new UAuthorizedExecute();
        contractAddresses.push(address(authorizedExecutor));

        addContractIds();

        vm.stopBroadcast();
        
    }
}
