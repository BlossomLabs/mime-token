// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {MimeToken} from "./MimeToken.sol";
import {MimeTokenWithTimestamp} from "./MimeTokenWithTimestamp.sol";

contract MimeTokenFactory {
    mapping(address => bool) public isMimeToken;

    event MimeTokenCreated(address token);

    function createMimeToken(string calldata name, string calldata symbol, bytes32 merkleRoot)
        public
        returns (MimeToken)
    {
        MimeToken token = new MimeToken(
            name,
            symbol,
            merkleRoot
        );
        token.transferOwnership(msg.sender);

        isMimeToken[address(token)] = true;

        emit MimeTokenCreated(address(token));

        return token;
    }

    function createMimeTokenWithTimestamp(
        string calldata name,
        string calldata symbol,
        bytes32 merkleRoot,
        uint256 timestamp,
        uint256 roundDuration
    ) public returns (MimeTokenWithTimestamp) {
        MimeTokenWithTimestamp token = new MimeTokenWithTimestamp(
            name,
            symbol,
            merkleRoot,
            timestamp,
            roundDuration
        );
        token.transferOwnership(msg.sender);

        isMimeToken[address(token)] = true;

        emit MimeTokenCreated(address(token));

        return token;
    }
}
