// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMimeToken {
    event Mint(uint256 indexed round, address indexed to, uint256 value);

    event Claimed(uint256 indexed round, uint256 index, address account, uint256 amount);

    function setNewRound(bytes32 merkleRoot_) external returns (bool);

    // Returns the amount of tokens in existence at current round.
    function totalSupply() external view returns (uint256);

    // Returns the amount of tokens owned by `account` at current round.
    function balanceOf(address account) external view returns (uint256);

    // Returns true if the index has been marked claimed.
    function isClaimed(uint256 index) external view returns (bool);

    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;

    function round() external view returns (uint256);

    // Returns the merkle root of the merkle tree containing account balances available to claim.
    function merkleRoot() external view returns (bytes32);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
