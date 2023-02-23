// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@oz/token/ERC20/IERC20.sol";

// Allows anyone to claim the token balance if they exist in a merkle root at each round.
interface IMimeToken is IERC20 {
    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 indexed round, uint256 index, address account, uint256 amount);

    // Returns the current round of distribution.
    function round() external view returns (uint256);
    // Sets a new merkle root for current round. Only callable by owner.
    function setNewRound(bytes32 merkleRoot_) external returns (bool);
    // Returns the merkle root of the merkle tree containing account balances available to claim for current round.
    function merkleRoot() external view returns (bytes32);
    // Returns true if the index has been marked claimed on current round.
    function isClaimed(uint256 index) external view returns (bool);
    // Claim the given amount of the token to the given address on current round. Reverts if the inputs are invalid.
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;
}
