// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "@oz/access/Ownable.sol";
import {MerkleProof} from "@oz/utils/cryptography/MerkleProof.sol";

import {IMimeToken} from "./IMimeToken.sol";

error AlreadyClaimed();
error InvalidProof();

contract MimeToken is Ownable, IMimeToken {
    uint256 private _currentRound;
    string private _name;
    string private _symbol;

    // round => merkle root.
    mapping(uint256 => bytes32) private _merkleRootAt;
    // round => total supply.
    mapping(uint256 => uint256) private _totalSupplyAt;
    // round => account => balance.
    mapping(uint256 => mapping(address => uint256)) private _balancesAt;
    // This is a packed array of booleans per round.
    mapping(uint256 => mapping(uint256 => uint256)) private _claimedBitMapAt;

    constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_) {
        _name = name_;
        _symbol = symbol_;
        _merkleRootAt[_currentRound] = merkleRoot_;
    }

    /* *************************************************************************************************************************************/
    /* ** Only Owner Functions                                                                                                           ***/
    /* *************************************************************************************************************************************/

    function setNewRound(bytes32 merkleRoot_) public onlyOwner returns (bool) {
        _currentRound += 1;
        _merkleRootAt[_currentRound] = merkleRoot_;
        return true;
    }

    /* *************************************************************************************************************************************/
    /* ** ERC20 Functions                                                                                                                ***/
    /* *************************************************************************************************************************************/

    function totalSupply() public view returns (uint256) {
        return _totalSupplyAt[_currentRound];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balancesAt[_currentRound][account];
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "MimeToken: mint to the zero address");

        _totalSupplyAt[_currentRound] += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balancesAt[_currentRound][account] += amount;
        }
        emit Mint(_currentRound, account, amount);
    }

    /* *************************************************************************************************************************************/
    /* ** Claim Functions                                                                                                                ***/
    /* *************************************************************************************************************************************/

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = _claimedBitMapAt[_currentRound][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        _claimedBitMapAt[_currentRound][claimedWordIndex] =
            _claimedBitMapAt[_currentRound][claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) public {
        if (isClaimed(index)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, _merkleRootAt[_currentRound], node)) revert InvalidProof();

        // Mark it claimed and mint tokens for current round.
        _setClaimed(index);
        _mint(account, amount);

        emit Claimed(_currentRound, index, account, amount);
    }

    /* *************************************************************************************************************************************/
    /* ** View Functions                                                                                                                 ***/
    /* *************************************************************************************************************************************/

    function round() public view returns (uint256) {
        return _currentRound;
    }

    function merkleRoot() public view returns (bytes32) {
        return _merkleRootAt[_currentRound];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
}
