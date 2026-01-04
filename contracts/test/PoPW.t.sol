// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CertifierRegistry} from "../src/CertifierRegistry.sol";
import {StandardsRegistry} from "../src/StandardsRegistry.sol";
import {PoPW} from "../src/PoPW.sol";
import {BBT} from "../src/BBT.sol";
import {EC} from "../src/EC.sol";
import {Attestation} from "../src/Attestation.sol";

contract PoPWTest is Test {
    CertifierRegistry public certifierRegistry;
    StandardsRegistry public standardsRegistry;
    PoPW public popw;
    BBT public bbt;
    EC public ec;

    address public owner = address(this);
    address public treasury = address(0x1);
    address public certifier1 = address(0x2);
    address public certifier2 = address(0x3);
    address public certifier3 = address(0x4);
    address public prover = address(0x5);

    uint256 public certifier1Key = 0x1;
    uint256 public proverKey = 0x5;

    function setUp() public {
        // Deploy contracts
        certifierRegistry = new CertifierRegistry();
        standardsRegistry = new StandardsRegistry();
        ec = new EC(treasury);
        bbt = new BBT();
        popw = new PoPW(
            address(certifierRegistry),
            address(standardsRegistry),
            address(bbt),
            address(ec),
            treasury
        );

        // Configure BBT
        bbt.setPoPW(address(popw));

        // Initialize genesis certifiers
        address[] memory genesis = new address[](1);
        genesis[0] = certifier1;
        certifierRegistry.initializeGenesis(genesis);
    }

    function test_CertifierRegistryGenesis() public view {
        assertTrue(certifierRegistry.isCertifier(certifier1));
        assertTrue(certifierRegistry.isGenesisKey(certifier1));
        assertEq(certifierRegistry.certifierCount(), 1);
    }

    function test_CertifierVouching() public {
        // Need 3 vouches - create more genesis keys for testing
        address[] memory moreGenesis = new address[](2);
        moreGenesis[0] = certifier2;
        moreGenesis[1] = certifier3;
        certifierRegistry.initializeGenesis(moreGenesis);

        address candidate = address(0x100);

        // First vouch
        vm.prank(certifier1);
        certifierRegistry.vouch(candidate);
        assertEq(certifierRegistry.getVouchCount(candidate), 1);
        assertFalse(certifierRegistry.isCertifier(candidate));

        // Second vouch
        vm.prank(certifier2);
        certifierRegistry.vouch(candidate);
        assertEq(certifierRegistry.getVouchCount(candidate), 2);
        assertFalse(certifierRegistry.isCertifier(candidate));

        // Third vouch - should trigger admission
        vm.prank(certifier3);
        certifierRegistry.vouch(candidate);
        assertEq(certifierRegistry.getVouchCount(candidate), 3);
        assertTrue(certifierRegistry.isCertifier(candidate));
    }

    function test_CreateStandard() public {
        bytes32 standardId = standardsRegistry.createStandard(
            "ipfs://QmTest",
            2000, // 20% royalty
            100 ether // 100 EC base fee
        );

        StandardsRegistry.Standard memory std = standardsRegistry.getStandard(standardId);
        assertEq(std.creator, address(this));
        assertEq(std.royaltyBps, 2000);
        assertEq(std.baseFee, 100 ether);
        assertTrue(std.active);
    }

    function test_BBTNonTransferable() public {
        // Create a standard
        bytes32 standardId = standardsRegistry.createStandard("ipfs://QmTest", 2000, 0);

        // Mint via PoPW simulation (use setPoPW to allow this test to mint)
        bbt.setPoPW(address(this));
        uint256 tokenId = bbt.mint(prover, standardId, certifier1, bytes32(0), 100);

        // Try to transfer - should fail
        vm.prank(prover);
        vm.expectRevert(BBT.TransferNotAllowed.selector);
        bbt.transferFrom(prover, address(0x999), tokenId);
    }

    function test_BBTBurn() public {
        bytes32 standardId = standardsRegistry.createStandard("ipfs://QmTest", 2000, 0);

        bbt.setPoPW(address(this));
        uint256 tokenId = bbt.mint(prover, standardId, certifier1, bytes32(0), 100);

        assertEq(bbt.balanceOf(prover), 1);

        vm.prank(prover);
        bbt.burn(tokenId);

        assertEq(bbt.balanceOf(prover), 0);
    }

    function test_ECInitialSupply() public view {
        assertEq(ec.totalSupply(), 1_000_000_000 ether);
        assertEq(ec.balanceOf(treasury), 1_000_000_000 ether);
    }
}
