// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "@oz/token/ERC20/ERC20.sol";
import {Ownable} from "@oz/access/Ownable.sol";
import {MerkleProof} from "@oz/utils/cryptography/MerkleProof.sol";

error AlreadyClaimed();
error InvalidProof();

contract MimeToken is ERC20, Ownable {
    uint256 private _currentRound;

    // round => merkle root.
    mapping(uint256 => bytes32) private _merkleRootAt;
    // round => total supply.
    mapping(uint256 => uint256) private _totalSupplyAt;
    // round => account => balance.
    mapping(uint256 => mapping(address => uint256)) private _balancesAt;
    // This is a packed array of booleans per round.
    mapping(uint256 => mapping(uint256 => uint256)) private _claimedBitMapAt;

    event Claimed(uint256 index, address account, uint256 amount, uint256 round);
    event Transfer(address indexed from, address indexed to, uint256 value, uint256 round);

    constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_) ERC20(name_, symbol_) {
        _merkleRootAt[_currentRound] = merkleRoot_;
    }

    /* *************************************************************************************************************************************/
    /* ** Only Owner Functions                                                                                                                ***/
    /* *************************************************************************************************************************************/

    function setNewRound(bytes32 merkleRoot_) public onlyOwner {
        _currentRound += 1;
        _merkleRootAt[_currentRound] = merkleRoot_;
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

        emit Claimed(index, account, amount, _currentRound);
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

    /* *************************************************************************************************************************************/
    /* ** ERC20 Interface                                                                                                                ***/
    /* *************************************************************************************************************************************/

    function totalSupply() public view override returns (uint256) {
        return _totalSupplyAt[_currentRound];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balancesAt[_currentRound][account];
    }

    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupplyAt[_currentRound] += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balancesAt[_currentRound][account] += amount;
        }
        emit Transfer(address(0), account, amount, _currentRound);

        _afterTokenTransfer(address(0), account, amount);
    }

    /* *************************************************************************************************************************************/
    /* ** ERC20 Interface Non Transferable Override                                                                                      ***/
    /* *************************************************************************************************************************************/

    function transfer(address to, uint256 amount) public override returns (bool) {
        return false;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return 0;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        return false;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        return false;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        return false;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        return false;
    }
}
