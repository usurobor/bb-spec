// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {CertifierRegistry} from "../src/CertifierRegistry.sol";
import {StandardsRegistry} from "../src/StandardsRegistry.sol";
import {PoPW} from "../src/PoPW.sol";
import {BBT} from "../src/BBT.sol";
import {EC} from "../src/EC.sol";

contract DeployScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address treasury = vm.envAddress("TREASURY_ADDRESS");
        address[] memory genesisKeys = _getGenesisKeys();

        vm.startBroadcast(deployerPrivateKey);

        // Deploy core contracts
        CertifierRegistry certifierRegistry = new CertifierRegistry();
        console.log("CertifierRegistry:", address(certifierRegistry));

        StandardsRegistry standardsRegistry = new StandardsRegistry();
        console.log("StandardsRegistry:", address(standardsRegistry));

        EC ec = new EC(treasury);
        console.log("EC Token:", address(ec));

        BBT bbt = new BBT();
        console.log("BBT:", address(bbt));

        PoPW popw = new PoPW(
            address(certifierRegistry),
            address(standardsRegistry),
            address(bbt),
            address(ec),
            treasury
        );
        console.log("PoPW:", address(popw));

        // Configure
        bbt.setPoPW(address(popw));
        console.log("BBT configured with PoPW");

        // Initialize genesis certifiers
        if (genesisKeys.length > 0) {
            certifierRegistry.initializeGenesis(genesisKeys);
            console.log("Genesis certifiers initialized:", genesisKeys.length);
        }

        vm.stopBroadcast();

        // Log summary
        console.log("\n=== Deployment Summary ===");
        console.log("CertifierRegistry:", address(certifierRegistry));
        console.log("StandardsRegistry:", address(standardsRegistry));
        console.log("EC Token:", address(ec));
        console.log("BBT:", address(bbt));
        console.log("PoPW:", address(popw));
        console.log("Treasury:", treasury);
    }

    function _getGenesisKeys() internal view returns (address[] memory) {
        // Try to load from environment, return empty if not set
        try vm.envAddress("GENESIS_KEY_1") returns (address key1) {
            address[] memory keys = new address[](1);
            keys[0] = key1;
            return keys;
        } catch {
            return new address[](0);
        }
    }
}
