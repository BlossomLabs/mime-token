// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {AlreadyClaimed, InvalidProof, MimeToken, NonTransferable} from "../src/MimeToken.sol";
import {MimeTokenFactory} from "../src/MimeTokenFactory.sol";

import {BaseSetup} from "../script/BaseSetup.s.sol";

contract MimeTokenWithTimestampTest is Test, BaseSetup {
    MimeToken public mime;

    address owner = address(1);
    address notAuthorized = address(2);
    address anvilAcount1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address anvilAcount2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address anvilAcount3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    // merkle tree data
    bytes32 merkleRoot = 0x47c52ef48ec180964d648c3783e0b02202f16211392b986fbe2627f021657f2b; // using: https://gist.github.com/0xGabi/4ca04edae9753ec32ffed7dc0cffe31e
    bytes32 otherRoot = 0xdefa96435aec82d201dbd2e5f050fb4e1fef5edac90ce1e03953f916a5e1132d;
    uint256 index0 = 0;
    uint256 index2 = 2;
    uint256 index3 = 3;
    uint256 amount = 0x3635c9adc5dea00000;

    uint256 timestamp;
    uint256 duration = 604800; // 1 week

    event Claimed(uint256 indexed round, uint256 index, address account, uint256 amount);

    function setUp() public override {
        super.setUp();

        timestamp = block.timestamp;

        bytes memory initCall =
            abi.encodeCall(MimeToken.initialize, ("Mime Token", "MIME", merkleRoot, timestamp, duration));

        vm.prank(owner);
        mime = MimeToken(factory.createMimeToken(initCall));

        vm.label(address(mime), "mime");
        vm.label(owner, "owner");
        vm.label(notAuthorized, "notAuthorized");
        vm.label(anvilAcount1, "anvilAcount1");
        vm.label(anvilAcount2, "anvilAcount2");
        vm.label(anvilAcount3, "anvilAcount3");
    }

    function testNonTransfeable() public {
        vm.expectRevert(abi.encodeWithSelector(NonTransferable.selector));
        mime.transfer(address(1), 1);

        vm.expectRevert(abi.encodeWithSelector(NonTransferable.selector));
        mime.allowance(address(1), address(2));

        vm.expectRevert(abi.encodeWithSelector(NonTransferable.selector));
        mime.approve(address(1), 1);

        vm.expectRevert(abi.encodeWithSelector(NonTransferable.selector));
        mime.transferFrom(address(1), address(2), 1);
    }

    function testSetNewRound() public {
        assertEq(mime.round(), 0);
        assertEq(mime.merkleRoot(), merkleRoot);

        vm.prank(owner);
        mime.setNewRound(otherRoot);

        assertEq(mime.round(), 0);
        assertEq(mime.merkleRoot(), merkleRoot);

        vm.warp(timestamp + duration + 1);

        assertEq(mime.round(), 1);
        assertEq(mime.merkleRoot(), otherRoot);
    }

    function testNewRoundWhenNotOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(notAuthorized);
        mime.setNewRound(bytes32(0));
    }

    function testClaim() public {
        // we claim with default anvil addresses
        assertEq(mime.balanceOf(anvilAcount1), 0);
        assertEq(mime.balanceOf(anvilAcount2), 0);
        assertEq(mime.balanceOf(anvilAcount3), 0);
        assertEq(mime.totalSupply(), 0);

        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0x2da52479032a949acaa5138ddd9cf15898df48085ce832cb5fad7367f7bd3cac;
        proof[1] = 0x0627178dd800c957efbe02c61cf32bcab724b4e87b735d34f03e6766ca038c10;

        vm.expectEmit(true, false, false, true);
        emit Claimed(mime.round(), index3, anvilAcount1, amount);

        mime.claim(index3, anvilAcount1, amount, proof);

        assertEq(mime.balanceOf(anvilAcount1), 1000 ether);
        assertEq(mime.isClaimed(index3), true);

        proof[0] = 0x9224c4ad0c0d0ea48b770992025547eff95b06645c92f0c047c9d7c161de8091;

        vm.expectEmit(true, false, false, true);
        emit Claimed(mime.round(), index2, anvilAcount2, amount);

        mime.claim(index2, anvilAcount2, amount, proof);

        assertEq(mime.balanceOf(anvilAcount2), 1000 ether);
        assertEq(mime.isClaimed(index2), true);

        proof[0] = 0x11079118024000df209172a1af6eb7a9ea4e5b2bd6e2760481566ce6bee3e0cd;
        proof[1] = 0xf46478da86f39b5d4f0af753bbc54ab402404b5ed5369f359e8fb24268b12edc;

        vm.expectEmit(true, false, false, true);
        emit Claimed(mime.round(), index0, anvilAcount3, amount);
        mime.claim(index0, anvilAcount3, amount, proof);

        assertEq(mime.balanceOf(anvilAcount3), 1000 ether);
        assertEq(mime.isClaimed(index0), true);

        assertEq(mime.totalSupply(), 3000 ether);
    }

    function testClaimWithInvalidProof() public {
        // wrong proof
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0x2da52479032a949acaa5138ddd9cf15898df48085ce832cb5fad7367f7bd3cac;
        proof[1] = 0xf46478da86f39b5d4f0af753bbc54ab402404b5ed5369f359e8fb24268b12edc;

        vm.expectRevert(abi.encodeWithSelector(InvalidProof.selector));
        mime.claim(3, anvilAcount1, amount, proof);

        // wrong amount
        proof[1] = 0x0627178dd800c957efbe02c61cf32bcab724b4e87b735d34f03e6766ca038c10;
        vm.expectRevert(abi.encodeWithSelector(InvalidProof.selector));
        mime.claim(3, anvilAcount1, 100, proof);

        // wrong index
        vm.expectRevert(abi.encodeWithSelector(InvalidProof.selector));
        mime.claim(4, anvilAcount1, amount, proof);

        // wrong address
        vm.expectRevert(abi.encodeWithSelector(InvalidProof.selector));
        mime.claim(3, anvilAcount2, amount, proof);
    }

    function testClaimAlreadyClaimed() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0x2da52479032a949acaa5138ddd9cf15898df48085ce832cb5fad7367f7bd3cac;
        proof[1] = 0x0627178dd800c957efbe02c61cf32bcab724b4e87b735d34f03e6766ca038c10;

        mime.claim(3, anvilAcount1, amount, proof);

        vm.expectRevert(abi.encodeWithSelector(AlreadyClaimed.selector));
        mime.claim(3, anvilAcount1, amount, proof);
    }
}
