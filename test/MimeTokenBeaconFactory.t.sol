// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MimeTokenUpgradeable} from "../src/MimeTokenUpgradeable.sol";
import {MimeTokenWithTimestampUpgradeable} from "../src/MimeTokenWithTimestampUpgradeable.sol";

import {BaseSetup} from "../script/BaseSetup.s.sol";

contract MimeTokenBeaconFactoryTest is Test, BaseSetup {
    MimeTokenUpgradeable mimeToken;
    MimeTokenWithTimestampUpgradeable mimeTokenWithTimestamp;

    address owner = address(1);

    function setUp() public override {
        super.setUp();

        vm.label(owner, "owner");
    }

    function testCreateMimeToken() public {
        bytes memory initCall = abi.encodeCall(MimeTokenUpgradeable.initialize, ("Mime Token", "MIME", merkleRoot));

        vm.prank(owner);
        mimeToken = MimeTokenUpgradeable(mimeTokenFactory.createMimeToken(initCall));

        assertEq(mimeToken.owner(), owner, "Token: owner mismatch");
        assertEq(mimeToken.name(), "Mime Token", "Token: name mismatch");
        assertEq(mimeToken.symbol(), "MIME", "Token: symbol mismatch");
        assertEq(mimeToken.merkleRoot(), merkleRoot, "Token: merkle root mismatch");
    }

    function testCreateMimeTokenWithTimestamp() public {
        uint256 timestamp = block.timestamp;

        bytes memory initCall = abi.encodeCall(
            MimeTokenWithTimestampUpgradeable.initialize, ("Mime Token", "MIME", merkleRoot, timestamp, 1)
        );

        vm.prank(owner);
        mimeTokenWithTimestamp =
            MimeTokenWithTimestampUpgradeable(mimeTokenWithTimestampFactory.createMimeToken(initCall));

        assertEq(mimeTokenWithTimestamp.owner(), owner, "Token: owner mismatch");
        assertEq(mimeTokenWithTimestamp.name(), "Mime Token", "Token: name mismatch");
        assertEq(mimeTokenWithTimestamp.symbol(), "MIME", "Token: symbol mismatch");
        assertEq(mimeTokenWithTimestamp.merkleRoot(), merkleRoot, "Token: merkle root mismatch");
        assertEq(mimeTokenWithTimestamp.timestamp(), timestamp, "Token: timestamp mismatch");
        assertEq(mimeTokenWithTimestamp.roundDuration(), 1, "Token: duration mismatch");
    }
}
