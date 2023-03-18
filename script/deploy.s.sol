// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {MimeTokenFactory} from "../src/MimeTokenFactory.sol";

import {SetupScript} from "./SetupScript.s.sol";

contract deploy is Script, SetupScript {
    address implementation;

    function setup() public {
        implementation = setUpContract("MimeToken");
    }

    function run() public {
        vm.startBroadcast();

        new MimeTokenFactory(implementation);

        vm.stopBroadcast();
    }
}
