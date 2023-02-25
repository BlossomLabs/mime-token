// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {MimeToken} from "./MimeToken.sol";

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
}
