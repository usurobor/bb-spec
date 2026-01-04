// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Attestation} from "./Attestation.sol";
import {CertifierRegistry} from "./CertifierRegistry.sol";
import {StandardsRegistry} from "./StandardsRegistry.sol";
import {BBT} from "./BBT.sol";

/// @title PoPW (Proof of Physical Work)
/// @notice Core attestation and minting contract for Embodied Coherence
/// @dev Verifies 2-of-2 signatures, tracks nonces, enforces deadlines, mints BBT on PASS
contract PoPW is EIP712, Ownable {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    CertifierRegistry public immutable certifierRegistry;
    StandardsRegistry public immutable standardsRegistry;
    BBT public immutable bbt;
    IERC20 public immutable ecToken;

    address public treasury;
    uint256 public treasuryBps = 1500; // 15% default

    /// @notice Nonce per prover (for replay protection)
    mapping(address => uint64) public nonces;

    /// @notice Track used attestation hashes
    mapping(bytes32 => bool) public usedAttestations;

    /// @notice Track if prover has PASS for (standardId, version)
    /// @dev Key: keccak256(prover, standardId, version)
    mapping(bytes32 => bool) public hasPass;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event AttestationRecorded(
        bytes32 indexed attestationHash,
        address indexed prover,
        address indexed certifier,
        bytes32 standardId,
        uint32 version,
        uint8 result,
        uint256 tokenId // 0 if NO_PASS
    );

    event TreasuryUpdated(address indexed newTreasury);
    event TreasuryBpsUpdated(uint256 newBps);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error InvalidProverSignature();
    error InvalidCertifierSignature();
    error CertifierNotAuthorized();
    error AttestationAlreadyUsed();
    error VersionNotFound();
    error InvalidTimestamp();
    error ProverCertifierSame();
    error DeadlineExpired();
    error InvalidNonce();
    error AlreadyHasPass();
    error InvalidResult();

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _certifierRegistry,
        address _standardsRegistry,
        address _bbt,
        address _ecToken,
        address _treasury
    ) EIP712("PoPW", "1") Ownable(msg.sender) {
        certifierRegistry = CertifierRegistry(_certifierRegistry);
        standardsRegistry = StandardsRegistry(_standardsRegistry);
        bbt = BBT(_bbt);
        ecToken = IERC20(_ecToken);
        treasury = _treasury;
    }

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Submit an attestation
    /// @param attestation The attestation data
    /// @param proverSig Prover's EIP-712 signature
    /// @param certifierSig Certifier's EIP-712 signature
    /// @return tokenId The minted BBT token ID (0 if NO_PASS)
    function attest(
        Attestation.Data calldata attestation,
        bytes calldata proverSig,
        bytes calldata certifierSig
    ) external returns (uint256 tokenId) {
        // Validate attestation
        _validateAttestation(attestation);

        // Get attestation hash
        bytes32 attestationHash = _getAttestationDigest(attestation);

        // Check not already used
        if (usedAttestations[attestationHash]) revert AttestationAlreadyUsed();

        // Verify signatures
        _verifySignatures(attestation, attestationHash, proverSig, certifierSig);

        // Validate and consume nonce
        if (attestation.nonce != nonces[attestation.prover]) revert InvalidNonce();
        nonces[attestation.prover]++;

        // Mark as used
        usedAttestations[attestationHash] = true;

        // Record in certifier registry (rate limiting)
        certifierRegistry.recordAttestation(attestation.certifier, attestation.standardId);

        // Handle fees (certifier always gets fee, creator only on PASS)
        _handleFees(attestation);

        // If PASS, mint BBT
        if (Attestation.isPassed(attestation)) {
            // Check one PASS per (prover, standardId, version)
            bytes32 passKey = keccak256(
                abi.encodePacked(attestation.prover, attestation.standardId, attestation.version)
            );
            if (hasPass[passKey]) revert AlreadyHasPass();
            hasPass[passKey] = true;

            tokenId = bbt.mint(
                attestation.prover,
                attestation.standardId,
                attestation.certifier,
                attestation.evidenceHash,
                uint256(attestation.version)
            );
        }

        emit AttestationRecorded(
            attestationHash,
            attestation.prover,
            attestation.certifier,
            attestation.standardId,
            attestation.version,
            attestation.result,
            tokenId
        );
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Update treasury address
    /// @param newTreasury New treasury address
    function setTreasury(address newTreasury) external onlyOwner {
        treasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    /// @notice Update treasury fee percentage
    /// @param newBps New basis points (max 2000 = 20%)
    function setTreasuryBps(uint256 newBps) external onlyOwner {
        require(newBps <= 2000, "Max 20%");
        treasuryBps = newBps;
        emit TreasuryBpsUpdated(newBps);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the EIP-712 digest for an attestation
    /// @param attestation The attestation data
    /// @return The typed data hash
    function getAttestationDigest(Attestation.Data calldata attestation)
        external
        view
        returns (bytes32)
    {
        return _getAttestationDigest(attestation);
    }

    /// @notice Get current nonce for a prover
    /// @param prover Prover address
    /// @return Current nonce
    function getNonce(address prover) external view returns (uint64) {
        return nonces[prover];
    }

    /// @notice Check if prover has PASS for a standard version
    /// @param prover Prover address
    /// @param standardId Standard ID
    /// @param version Version number
    /// @return True if has PASS
    function hasPassFor(
        address prover,
        bytes32 standardId,
        uint32 version
    ) external view returns (bool) {
        bytes32 passKey = keccak256(abi.encodePacked(prover, standardId, version));
        return hasPass[passKey];
    }

    /// @notice Verify signatures without submitting
    /// @param attestation The attestation data
    /// @param proverSig Prover's signature
    /// @param certifierSig Certifier's signature
    /// @return valid True if both signatures are valid
    function verifySignatures(
        Attestation.Data calldata attestation,
        bytes calldata proverSig,
        bytes calldata certifierSig
    ) external view returns (bool valid) {
        bytes32 digest = _getAttestationDigest(attestation);

        address recoveredProver = digest.recover(proverSig);
        address recoveredCertifier = digest.recover(certifierSig);

        return recoveredProver == attestation.prover && recoveredCertifier == attestation.certifier;
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _validateAttestation(Attestation.Data calldata attestation) internal view {
        // Prover and certifier must be different
        if (attestation.prover == attestation.certifier) revert ProverCertifierSame();

        // Result must be valid (0 or 1)
        if (attestation.result > Attestation.PASS) revert InvalidResult();

        // Deadline must not be expired
        if (block.timestamp > attestation.deadline) revert DeadlineExpired();

        // Certifier must be authorized (checked at submission time per spec)
        if (!certifierRegistry.isCertifier(attestation.certifier)) {
            revert CertifierNotAuthorized();
        }

        // Version must exist
        if (!standardsRegistry.isValidVersion(attestation.standardId, attestation.version)) {
            revert VersionNotFound();
        }

        // Timestamp must be reasonable (not in future, not too old)
        if (attestation.timestamp > block.timestamp) revert InvalidTimestamp();
        if (attestation.timestamp < block.timestamp - 30 days) revert InvalidTimestamp();
    }

    function _verifySignatures(
        Attestation.Data calldata attestation,
        bytes32 digest,
        bytes calldata proverSig,
        bytes calldata certifierSig
    ) internal pure {
        // Recover prover
        address recoveredProver = digest.recover(proverSig);
        if (recoveredProver != attestation.prover) revert InvalidProverSignature();

        // Recover certifier
        address recoveredCertifier = digest.recover(certifierSig);
        if (recoveredCertifier != attestation.certifier) revert InvalidCertifierSignature();
    }

    function _getAttestationDigest(Attestation.Data calldata attestation)
        internal
        view
        returns (bytes32)
    {
        return _hashTypedDataV4(Attestation.hash(attestation));
    }

    function _handleFees(Attestation.Data calldata attestation) internal {
        StandardsRegistry.StandardVersion memory std = standardsRegistry.getVersion(
            attestation.standardId,
            attestation.version
        );

        if (std.baseFee == 0) return;

        // Transfer fee from caller
        ecToken.safeTransferFrom(msg.sender, address(this), std.baseFee);

        // Calculate splits
        // Creator royalty only on PASS
        uint256 creatorShare = Attestation.isPassed(attestation)
            ? (std.baseFee * std.royaltyBps) / 10000
            : 0;
        uint256 treasuryShare = (std.baseFee * treasuryBps) / 10000;
        uint256 certifierShare = std.baseFee - creatorShare - treasuryShare;

        // Distribute
        if (creatorShare > 0) {
            ecToken.safeTransfer(std.creator, creatorShare);
        }
        if (treasuryShare > 0) {
            ecToken.safeTransfer(treasury, treasuryShare);
        }
        if (certifierShare > 0) {
            ecToken.safeTransfer(attestation.certifier, certifierShare);
        }
    }
}
