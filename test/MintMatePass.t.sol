// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MintMatePass} from "../src/MintMatePass.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract MintMatePassTest is Test {
    /// @dev George's main wallet — the owner / royalty receiver from the spec.
    address internal constant GEORGE = 0xfFDd2f83555c64d1CaA17f5646C08b80013ED38b;

    uint256 internal constant FOUNDING_TREE_SIZE = 256;

    MintMatePass internal pass;
    bytes32[][] internal levels;
    bytes32 internal root;

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------

    function foundingUser(uint256 i) internal pure returns (address) {
        return address(uint160(0xF0000 + i));
    }

    function publicBuyer(uint256 i) internal pure returns (address) {
        return address(uint160(0xB0000 + i));
    }

    /// @dev Must match the leaf derivation in MintMatePass.foundingClaim.
    function _leaf(address a) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(abi.encode(a))));
    }

    /// @dev Sorted-pair hashing, matching OpenZeppelin MerkleProof.
    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }

    function _buildLevels(bytes32[] memory leaves) internal pure returns (bytes32[][] memory lv) {
        uint256 depth = 0;
        for (uint256 n = leaves.length; n > 1; n >>= 1) depth++;
        lv = new bytes32[][](depth + 1);
        lv[0] = leaves;
        for (uint256 l = 1; l <= depth; l++) {
            uint256 half = lv[l - 1].length / 2;
            lv[l] = new bytes32[](half);
            for (uint256 i = 0; i < half; i++) {
                lv[l][i] = _hashPair(lv[l - 1][2 * i], lv[l - 1][2 * i + 1]);
            }
        }
    }

    function _proofFor(uint256 index) internal view returns (bytes32[] memory) {
        uint256 depth = levels.length - 1;
        bytes32[] memory proof = new bytes32[](depth);
        uint256 idx = index;
        for (uint256 l = 0; l < depth; l++) {
            proof[l] = levels[l][idx ^ 1];
            idx >>= 1;
        }
        return proof;
    }

    function _claim(uint256 i) internal {
        vm.prank(foundingUser(i));
        pass.foundingClaim(_proofFor(i));
    }

    /// @dev Fast-forward: close Founding early and open the public phase.
    function _openPublic() internal {
        vm.startPrank(GEORGE);
        if (!pass.foundingClosed() && pass.totalMinted() < pass.FOUNDING_SUPPLY()) {
            pass.closeFounding();
        }
        pass.openPublicSale();
        vm.stopPrank();
    }

    function setUp() public {
        pass = new MintMatePass(GEORGE);
        bytes32[] memory leaves = new bytes32[](FOUNDING_TREE_SIZE);
        for (uint256 i = 0; i < FOUNDING_TREE_SIZE; i++) {
            leaves[i] = _leaf(foundingUser(i));
        }
        levels = _buildLevels(leaves);
        root = levels[levels.length - 1][0];
        vm.prank(GEORGE);
        pass.setFoundingMerkleRoot(root);
    }

    // ---------------------------------------------------------------
    // Metadata / ownership
    // ---------------------------------------------------------------

    function test_MetadataAndOwner() public view {
        assertEq(pass.name(), "MintMate Pass");
        assertEq(pass.symbol(), "MMPASS");
        assertEq(pass.owner(), GEORGE);
        assertEq(pass.MAX_SUPPLY(), 1000);
        assertEq(pass.FOUNDING_SUPPLY(), 200);
        assertEq(pass.PUBLIC_PRICE(), 0.005 ether);
        assertEq(pass.PUBLIC_MAX_PER_WALLET(), 3);
        assertEq(pass.totalMinted(), 0);
    }

    function test_DeployGas() public {
        uint256 g0 = gasleft();
        MintMatePass p = new MintMatePass(GEORGE);
        uint256 used = g0 - gasleft();
        emit log_named_uint("MintMatePass deployment gas", used);
        assertTrue(address(p) != address(0));
    }

    // ---------------------------------------------------------------
    // Founding phase
    // ---------------------------------------------------------------

    function test_FoundingClaimHappyPath() public {
        _claim(0);
        address claimer = foundingUser(0);
        assertEq(pass.balanceOf(claimer), 1);
        assertEq(pass.ownerOf(1), claimer);
        assertTrue(pass.isFounding(1));
        assertTrue(pass.foundingClaimed(claimer));
        assertEq(pass.totalMinted(), 1);
        assertEq(address(pass).balance, 0, "founding claim must be free");
    }

    function test_FoundingClaimRejectsPayment() public {
        // foundingClaim is non-payable: sending ETH must fail.
        (bool ok,) = address(pass).call{value: 0.001 ether}(
            abi.encodeCall(MintMatePass.foundingClaim, (_proofFor(0)))
        );
        assertFalse(ok);
        assertEq(pass.totalMinted(), 0);
    }

    function test_FoundingDoubleClaimReverts() public {
        _claim(0);
        vm.prank(foundingUser(0));
        vm.expectRevert(MintMatePass.AlreadyClaimed.selector);
        pass.foundingClaim(_proofFor(0));
    }

    function test_FoundingNonAllowlistedReverts() public {
        address eve = makeAddr("eve");
        vm.prank(eve);
        vm.expectRevert(MintMatePass.NotAllowlisted.selector);
        pass.foundingClaim(new bytes32[](0));
    }

    function test_FoundingWrongProofReverts() public {
        // foundingUser(1) presenting foundingUser(0)'s proof must fail.
        vm.prank(foundingUser(1));
        vm.expectRevert(MintMatePass.NotAllowlisted.selector);
        pass.foundingClaim(_proofFor(0));
    }

    function test_OwnerCannotClaimWithoutAllowlist() public {
        // No hidden admin mint: even the owner needs an allowlist spot.
        vm.prank(GEORGE);
        vm.expectRevert(MintMatePass.NotAllowlisted.selector);
        pass.foundingClaim(new bytes32[](0));
    }

    function test_FoundingBoundary_Token200Last_201IsPublic() public {
        for (uint256 i = 0; i < 200; i++) {
            _claim(i);
        }
        assertEq(pass.totalMinted(), 200);
        assertTrue(pass.isFounding(200), "token 200 is the last Founding token");
        assertEq(pass.ownerOf(200), foundingUser(199));

        // Founding is exhausted: user 200 (allowlisted) cannot claim.
        vm.prank(foundingUser(200));
        vm.expectRevert(MintMatePass.FoundingSoldOut.selector);
        pass.foundingClaim(_proofFor(200));

        // Public opens on the sold-out path (no early close needed).
        vm.prank(GEORGE);
        pass.openPublicSale();

        address buyer = publicBuyer(0);
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        pass.publicMint{value: 0.005 ether}(1);
        assertEq(pass.ownerOf(201), buyer);
        assertFalse(pass.isFounding(201), "token 201 must not be a Founding token");
    }

    // ---------------------------------------------------------------
    // Phase gating
    // ---------------------------------------------------------------

    function test_PublicMintClosedUntilOpened() public {
        address buyer = publicBuyer(0);
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        vm.expectRevert(MintMatePass.PublicSaleNotOpen.selector);
        pass.publicMint{value: 0.005 ether}(1);
    }

    function test_OpenPublicTooEarlyReverts() public {
        // Founding still in progress and not closed: cannot open public.
        vm.prank(GEORGE);
        vm.expectRevert(MintMatePass.FoundingStillOpen.selector);
        pass.openPublicSale();
    }

    function test_PhaseControlsAreOwnerOnly() public {
        address rando = makeAddr("rando");
        vm.prank(rando);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, rando));
        pass.closeFounding();

        vm.prank(rando);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, rando));
        pass.openPublicSale();

        vm.prank(rando);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, rando));
        pass.setFoundingMerkleRoot(bytes32(uint256(1)));
    }

    function test_CloseFoundingThenOpenPublic() public {
        _claim(0); // one founding mint, then owner closes early
        vm.startPrank(GEORGE);
        pass.closeFounding();
        pass.openPublicSale();
        vm.stopPrank();
        assertTrue(pass.publicSaleOpen());

        // Founding claims are over, even for allowlisted wallets.
        vm.prank(foundingUser(1));
        vm.expectRevert(MintMatePass.FoundingIsClosed.selector);
        pass.foundingClaim(_proofFor(1));

        // A public mint into the "founding id range" is NOT a Founding token.
        address buyer = publicBuyer(0);
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        pass.publicMint{value: 0.005 ether}(1);
        assertEq(pass.ownerOf(2), buyer);
        assertFalse(pass.isFounding(2));
        assertTrue(pass.isFounding(1));
    }

    function test_CloseFoundingTwiceReverts() public {
        vm.startPrank(GEORGE);
        pass.closeFounding();
        vm.expectRevert(MintMatePass.FoundingAlreadyClosed.selector);
        pass.closeFounding();
        vm.stopPrank();
    }

    // ---------------------------------------------------------------
    // Public phase
    // ---------------------------------------------------------------

    function test_PublicPriceExactness() public {
        _openPublic();
        address buyer = publicBuyer(0);
        vm.deal(buyer, 1 ether);

        // Underpay by 1 wei.
        vm.prank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(MintMatePass.IncorrectPayment.selector, 0.005 ether, 0.005 ether - 1)
        );
        pass.publicMint{value: 0.005 ether - 1}(1);

        // Overpay by 1 wei.
        vm.prank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(MintMatePass.IncorrectPayment.selector, 0.005 ether, 0.005 ether + 1)
        );
        pass.publicMint{value: 0.005 ether + 1}(1);

        // Wrong total for quantity 3.
        vm.prank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(MintMatePass.IncorrectPayment.selector, 0.015 ether, 0.005 ether)
        );
        pass.publicMint{value: 0.005 ether}(3);

        // Exact payment works.
        vm.prank(buyer);
        pass.publicMint{value: 0.015 ether}(3);
        assertEq(pass.balanceOf(buyer), 3);
        assertEq(address(pass).balance, 0.015 ether);
    }

    function test_PublicZeroQuantityReverts() public {
        _openPublic();
        address buyer = publicBuyer(0);
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        vm.expectRevert(MintMatePass.ZeroQuantity.selector);
        pass.publicMint{value: 0}(0);
    }

    function test_PublicPerWalletLimit() public {
        _openPublic();
        address buyer = publicBuyer(0);
        vm.deal(buyer, 1 ether);

        // 2 + 1 across two transactions is fine.
        vm.prank(buyer);
        pass.publicMint{value: 0.01 ether}(2);
        vm.prank(buyer);
        pass.publicMint{value: 0.005 ether}(1);
        assertEq(pass.balanceOf(buyer), 3);
        assertEq(pass.publicMintCount(buyer), 3);

        // The 4th token reverts.
        vm.prank(buyer);
        vm.expectRevert(MintMatePass.PublicLimitExceeded.selector);
        pass.publicMint{value: 0.005 ether}(1);

        // A single transaction of 4 reverts for a fresh wallet too.
        address buyer2 = publicBuyer(1);
        vm.deal(buyer2, 1 ether);
        vm.prank(buyer2);
        vm.expectRevert(MintMatePass.PublicLimitExceeded.selector);
        pass.publicMint{value: 0.02 ether}(4);
    }

    function test_FoundingClaimDoesNotConsumePublicAllowance() public {
        _claim(0);
        _openPublic();
        address claimer = foundingUser(0);
        vm.deal(claimer, 1 ether);
        vm.prank(claimer);
        pass.publicMint{value: 0.015 ether}(3);
        assertEq(pass.balanceOf(claimer), 4); // 1 founding + 3 public
    }

    // ---------------------------------------------------------------
    // Royalty (EIP-2981)
    // ---------------------------------------------------------------

    function test_RoyaltyInfo() public {
        _claim(0);
        (address receiver, uint256 amount) = pass.royaltyInfo(1, 1 ether);
        assertEq(receiver, GEORGE);
        assertEq(amount, 0.05 ether, "5% of 1 ETH");
        (, uint256 amount2) = pass.royaltyInfo(1, 0.005 ether);
        assertEq(amount2, 0.00025 ether, "5% of the public price");
        assertTrue(pass.supportsInterface(0x2a55205a), "ERC2981 interface id");
        assertTrue(pass.supportsInterface(0x80ac58cd), "ERC721 interface id");
    }

    // ---------------------------------------------------------------
    // Withdraw
    // ---------------------------------------------------------------

    function test_WithdrawOnlyOwner() public {
        _openPublic();
        address buyer = publicBuyer(0);
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        pass.publicMint{value: 0.015 ether}(3);
        assertEq(address(pass).balance, 0.015 ether);

        address rando = makeAddr("rando");
        vm.prank(rando);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, rando));
        pass.withdraw();

        vm.deal(GEORGE, 0);
        vm.prank(GEORGE);
        pass.withdraw();
        assertEq(address(pass).balance, 0);
        assertEq(GEORGE.balance, 0.015 ether);
    }

    // ---------------------------------------------------------------
    // Supply cap
    // ---------------------------------------------------------------

    function test_CapEnforcement_1000() public {
        for (uint256 i = 0; i < 200; i++) {
            _claim(i);
        }
        vm.prank(GEORGE);
        pass.openPublicSale();

        // 266 buyers x 3 = 798 -> total 998
        for (uint256 j = 0; j < 266; j++) {
            address buyer = publicBuyer(j);
            vm.deal(buyer, 1 ether);
            vm.prank(buyer);
            pass.publicMint{value: 0.015 ether}(3);
        }
        assertEq(pass.totalMinted(), 998);

        // Buyer 267 mints the last 2 -> exactly 1000.
        address last = publicBuyer(266);
        vm.deal(last, 1 ether);
        vm.prank(last);
        pass.publicMint{value: 0.01 ether}(2);
        assertEq(pass.totalMinted(), 1000);
        assertEq(pass.totalMinted(), pass.MAX_SUPPLY());

        // Nothing can be minted past the cap.
        address extra = publicBuyer(267);
        vm.deal(extra, 1 ether);
        vm.prank(extra);
        vm.expectRevert(MintMatePass.SoldOut.selector);
        pass.publicMint{value: 0.005 ether}(1);
    }

    // ---------------------------------------------------------------
    // Base URI
    // ---------------------------------------------------------------

    function test_BaseURISettableBeforeLaunchThenLocked() public {
        vm.prank(GEORGE);
        pass.setBaseURI("ipfs://mintmate-pass/");
        assertEq(pass.baseURI(), "ipfs://mintmate-pass/");

        _claim(0);
        assertEq(pass.tokenURI(1), "ipfs://mintmate-pass/1");

        vm.prank(GEORGE);
        vm.expectRevert(MintMatePass.BaseURILocked.selector);
        pass.setBaseURI("ipfs://something-else/");
    }

    function test_BaseURIOnlyOwner() public {
        address rando = makeAddr("rando");
        vm.prank(rando);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, rando));
        pass.setBaseURI("ipfs://nope/");
    }
}
