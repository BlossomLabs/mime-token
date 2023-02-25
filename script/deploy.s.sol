// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {MimeTokenFactory} from "../src/MimeTokenFactory.sol";

contract deploy is Script {
    function run() public {
        vm.startBroadcast();

        new MimeTokenFactory();

        vm.stopBroadcast();
    }
}
