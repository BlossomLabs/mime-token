// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {UpgradeableBeacon} from "@oz/proxy/beacon/UpgradeableBeacon.sol";

import {MimeTokenUpgradeable} from "../src/MimeTokenUpgradeable.sol";
import {MimeTokenWithTimestampUpgradeable} from "../src/MimeTokenWithTimestampUpgradeable.sol";
import {MimeTokenBeaconFactory} from "../src/MimeTokenBeaconFactory.sol";

import {SetupScript} from "./SetupScript.s.sol";

contract BaseSetup is SetupScript {
    MimeTokenBeaconFactory mimeTokenFactory;
    MimeTokenBeaconFactory mimeTokenWithTimestampFactory;

    // env
    address deployer = address(this);
    address notAuthorized = address(200);

    bytes32 merkleRoot = 0x47c52ef48ec180964d648c3783e0b02202f16211392b986fbe2627f021657f2b;

    function setUp() public virtual {
        // labels
        vm.label(deployer, "deployer");
        vm.label(notAuthorized, "notAuthorized");

        address mimeImplementation = setUpContract("MimeTokenUpgradeable");
        mimeTokenFactory = new MimeTokenBeaconFactory(mimeImplementation);

        address mimeWithTimestampImplementation = setUpContract("MimeTokenWithTimestampUpgradeable");
        mimeTokenWithTimestampFactory = new MimeTokenBeaconFactory(mimeWithTimestampImplementation);

        vm.label(address(mimeTokenFactory), "factory");
        vm.label(address(mimeTokenWithTimestampFactory), "factoryWithTimestamp");
    }
}
