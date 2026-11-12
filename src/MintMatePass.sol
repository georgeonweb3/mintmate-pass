// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "openzeppelin-contracts/token/common/ERC2981.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/utils/ReentrancyGuard.sol";

/**
 * @title MintMatePass
 * @notice ERC-721 access pass for MintMate (the Mint Terminal), Base mainnet (chain 8453).
 *
 *         Sale model (hard-coded, no admin mint, no proxy, no upgrade path):
 *         - Phase 1 "Founding": the first {FOUNDING_SUPPLY} tokens, free, one per wallet,
 *           claimed with a Merkle allowlist proof.
 *         - Phase 2 "Public": the remaining supply at {PUBLIC_PRICE} each, max
 *           {PUBLIC_MAX_PER_WALLET} per wallet. Opens only after Founding has ended
 *           (sold out, or closed early by the owner) AND the owner opens it.
 *         - Total supply is hard-capped at {MAX_SUPPLY}; token ids start at 1.
 *         - Founding-minted tokens are marked on-chain: see {isFounding}.
 *         - EIP-2981 default royalty of 5% to the owner wallet.
 *
 *         The contract owner is supplied as a constructor argument, so whoever
 *         deploys the contract is irrelevant: ownership and royalties belong to
 *         that address from the first block.
 */
contract MintMatePass is ERC721, ERC2981, Ownable, ReentrancyGuard {
    /// @notice Hard cap on total supply across both phases.
    uint256 public constant MAX_SUPPLY = 1000;
    /// @notice Number of tokens reserved for the free Founding phase.
    uint256 public constant FOUNDING_SUPPLY = 200;
    /// @notice Public phase price per token.
    uint256 public constant PUBLIC_PRICE = 0.005 ether;
    /// @notice Max public-phase tokens per wallet (Founding claim is separate).
    uint256 public constant PUBLIC_MAX_PER_WALLET = 3;
    /// @notice EIP-2981 royalty: 500 / 10_000 = 5%.
    uint96 public constant ROYALTY_FEE_NUMERATOR = 500;

    /// @notice Merkle root of the Founding allowlist. Leaf for address `a` is
    ///         keccak256(bytes.concat(keccak256(abi.encode(a)))).
    bytes32 public foundingMerkleRoot;
    /// @notice True once the owner has closed the Founding phase early (one-way).
    bool public foundingClosed;
    /// @notice True once the owner has opened the public phase (one-way).
    bool public publicSaleOpen;
    /// @notice Metadata base URI. Settable by the owner until the first token
    ///         is minted, then locked ("pinned") forever.
    string public baseURI;

    /// @notice Whether a wallet has used its one Founding claim.
    mapping(address => bool) public foundingClaimed;
    /// @notice How many public-phase tokens a wallet has minted.
    mapping(address => uint256) public publicMintCount;
    /// @notice True for tokens minted through the Founding phase.
    mapping(uint256 => bool) public isFounding;

    uint256 private _totalMinted;

    event FoundingRootSet(bytes32 root);
    event FoundingClosedEarly(uint256 mintedAtClose);
    event PublicSaleOpened();
    event FoundingClaimed(address indexed claimer, uint256 indexed tokenId);
    event PublicMinted(address indexed buyer, uint256 quantity, uint256 firstTokenId);
    event BaseURISet(string baseURI);
    event Withdrawn(address indexed to, uint256 amount);

    error FoundingAlreadyClosed();
    error FoundingIsClosed();
    error FoundingSoldOut();
    error AlreadyClaimed();
    error NotAllowlisted();
    error FoundingStillOpen();
    error PublicSaleAlreadyOpen();
    error PublicSaleNotOpen();
    error ZeroQuantity();
    error IncorrectPayment(uint256 expected, uint256 received);
    error PublicLimitExceeded();
    error SoldOut();
    error BaseURILocked();
    error WithdrawFailed();

    /// @param owner_ The contract owner and royalty receiver (George's main wallet).
    ///               Passed in explicitly so the deploying account does not matter.
    constructor(address owner_) ERC721("MintMate Pass", "MMPASS") Ownable(owner_) {
        _setDefaultRoyalty(owner_, ROYALTY_FEE_NUMERATOR);
    }

    // ------------------------------------------------------------------
    // Founding phase
    // ------------------------------------------------------------------

    /// @notice Claim the one free Founding pass for an allowlisted wallet.
    /// @param proof Merkle proof for the caller's allowlist leaf.
    function foundingClaim(bytes32[] calldata proof) external nonReentrant {
        if (foundingClosed) revert FoundingIsClosed();
        if (_totalMinted >= FOUNDING_SUPPLY) revert FoundingSoldOut();
        if (foundingClaimed[msg.sender]) revert AlreadyClaimed();
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender))));
        if (!MerkleProof.verifyCalldata(proof, foundingMerkleRoot, leaf)) revert NotAllowlisted();

        foundingClaimed[msg.sender] = true;
        uint256 tokenId = ++_totalMinted;
        isFounding[tokenId] = true;
        emit FoundingClaimed(msg.sender, tokenId);
        _safeMint(msg.sender, tokenId);
    }

    // ------------------------------------------------------------------
    // Public phase
    // ------------------------------------------------------------------

    /// @notice Mint public-phase passes. Payment must be exact: PUBLIC_PRICE * quantity.
    function publicMint(uint256 quantity) external payable nonReentrant {
        if (!publicSaleOpen) revert PublicSaleNotOpen();
        if (quantity == 0) revert ZeroQuantity();
        uint256 expected = PUBLIC_PRICE * quantity;
        if (msg.value != expected) revert IncorrectPayment(expected, msg.value);
        uint256 mintedBy = publicMintCount[msg.sender];
        if (mintedBy + quantity > PUBLIC_MAX_PER_WALLET) revert PublicLimitExceeded();
        uint256 supply = _totalMinted;
        if (supply + quantity > MAX_SUPPLY) revert SoldOut();

        publicMintCount[msg.sender] = mintedBy + quantity;
        _totalMinted = supply + quantity;
        uint256 firstTokenId = supply + 1;
        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(msg.sender, firstTokenId + i);
        }
        emit PublicMinted(msg.sender, quantity, firstTokenId);
    }

    // ------------------------------------------------------------------
    // Owner controls
    // ------------------------------------------------------------------

    /// @notice Set (or rotate, before claims begin) the Founding allowlist root.
    function setFoundingMerkleRoot(bytes32 root) external onlyOwner {
        foundingMerkleRoot = root;
        emit FoundingRootSet(root);
    }

    /// @notice Close the Founding phase early, forfeiting its remaining slots
    ///         to the public phase. One-way. Public tokens minted into the
    ///         first 200 ids this way are NOT Founding tokens ({isFounding}).
    function closeFounding() external onlyOwner {
        if (foundingClosed) revert FoundingAlreadyClosed();
        foundingClosed = true;
        emit FoundingClosedEarly(_totalMinted);
    }

    /// @notice Open the public phase. Only possible once Founding has ended:
    ///         sold out or closed early by the owner.
    function openPublicSale() external onlyOwner {
        if (publicSaleOpen) revert PublicSaleAlreadyOpen();
        if (!foundingClosed && _totalMinted < FOUNDING_SUPPLY) revert FoundingStillOpen();
        publicSaleOpen = true;
        emit PublicSaleOpened();
    }

    /// @notice Set the metadata base URI. Locked forever once the first
    ///         token is minted, so set and verify it before opening claims.
    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        if (_totalMinted > 0) revert BaseURILocked();
        baseURI = newBaseURI;
        emit BaseURISet(newBaseURI);
    }

    /// @notice Withdraw the full contract balance (public-sale proceeds) to the owner.
    function withdraw() external onlyOwner nonReentrant {
        uint256 amount = address(this).balance;
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert WithdrawFailed();
        emit Withdrawn(msg.sender, amount);
    }

    // ------------------------------------------------------------------
    // Views
    // ------------------------------------------------------------------

    /// @notice Total tokens minted so far across both phases.
    function totalMinted() external view returns (uint256) {
        return _totalMinted;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
