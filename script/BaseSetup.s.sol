// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {UpgradeableBeacon} from "@oz/proxy/beacon/UpgradeableBeacon.sol";

import {MimeToken} from "../src/MimeToken.sol";
import {MimeTokenFactory} from "../src/MimeTokenFactory.sol";

import {SetupScript} from "./SetupScript.s.sol";

contract BaseSetup is SetupScript {
    MimeTokenFactory factory;
    address implementation;

    address deployer = address(this);

    function setUp() public virtual {
        // labels
        vm.label(deployer, "deployer");

        implementation = setUpContract("MimeToken");
        factory = new MimeTokenFactory(implementation);

        vm.label(address(factory), "factory");
    }
}
