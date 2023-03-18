// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MimeToken} from "../src/MimeToken.sol";

import {BaseSetup} from "../script/BaseSetup.s.sol";

contract MimeTokenFactoryTest is Test, BaseSetup {
    MimeToken mime;

    address owner = address(1);

    function setUp() public override {
        super.setUp();

        vm.label(owner, "owner");
    }

    function testInitialState() public {
        assertEq(factory.beacon().implementation(), implementation, "Beacon: mime implementation mismatch");
        assertEq(factory.beacon().owner(), deployer, "Beacon: owner mismatch");
    }

    function testBeaconUpgradability() public {
        address newImplementation = setUpContract("MimeToken");

        vm.prank(deployer);
        factory.beacon().upgradeTo(newImplementation);

        assertEq(factory.beacon().implementation(), newImplementation, "Beacon: implementation mismatch");
    }

    function testCreateMimeToken() public {
        uint256 timestamp = block.timestamp;
        bytes32 root = 0xdefa96435aec82d201dbd2e5f050fb4e1fef5edac90ce1e03953f916a5e1132d;

        bytes memory initCall = abi.encodeCall(MimeToken.initialize, ("Mime Token", "MIME", root, timestamp, 1));

        vm.prank(owner);
        mime = MimeToken(factory.createMimeToken(initCall));

        assertEq(mime.owner(), owner, "Token: owner mismatch");
        assertEq(mime.round(), 0, "Token: round mismatch");
        assertEq(mime.merkleRoot(), root, "Token: merkle root mismatch");
        assertEq(mime.name(), "Mime Token", "Token: name mismatch");
        assertEq(mime.symbol(), "MIME", "Token: symbol mismatch");
        assertEq(mime.decimals(), 18, "Token: decimals mismatch");
        assertEq(mime.timestamp(), timestamp, "Token: timestamp mismatch");
        assertEq(mime.roundDuration(), 1, "Token: duration mismatch");

        assertEq(factory.isMimeToken(address(mime)), true, "Factory: address is not a mime token");
    }
}
