// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {MimeTokenFactory} from "../src/MimeTokenFactory.sol";

import {SetupScript} from "./SetupScript.s.sol";

contract deploy is Script, SetupScript {
    function run() public {
        vm.startBroadcast();

        address implementation = setUpContract("MimeToken");
        new MimeTokenFactory(implementation);

        vm.stopBroadcast();
    }
}
