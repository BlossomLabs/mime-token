// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MimeToken} from "../src/MimeToken.sol";
import {MimeTokenWithTimestamp} from "../src/MimeTokenWithTimestamp.sol";
import {MimeTokenFactory} from "../src/MimeTokenFactory.sol";

contract MimeTokenFactoryTest is Test {
    MimeTokenFactory public factory;

    address owner = address(1);

    uint256 timestamp;
    uint256 duration = 604800; // 1 week

    function setUp() public {
        factory = new MimeTokenFactory();

        vm.label(address(factory), "factory");
        vm.label(owner, "owner");
    }

    function testCreateMimeToken() public {
        vm.prank(owner);
        MimeToken mime = factory.createMimeToken("Mime Token", "MIME", bytes32(0));

        assertEq(mime.owner(), owner);
        assertEq(factory.isMimeToken(address(mime)), true);
    }

    function testCreateMimeTokenWithTimestamp() public {
        vm.prank(owner);
        MimeTokenWithTimestamp mime =
            factory.createMimeTokenWithTimestamp("Mime Token", "MIME", bytes32(0), block.timestamp, duration);

        assertEq(mime.owner(), owner);
        assertEq(factory.isMimeToken(address(mime)), true);
    }
}
