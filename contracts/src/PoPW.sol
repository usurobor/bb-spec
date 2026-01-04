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
/// @dev Verifies 2-of-2 signatures and triggers BBT minting
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

    mapping(bytes32 => bool) public usedAttestations;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event AttestationSubmitted(
        bytes32 indexed attestationHash,
        address indexed prover,
        address indexed certifier,
        bytes32 standardId,
        uint256 tokenId
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
    error StandardNotActive();
    error InvalidTimestamp();
    error ProverCertifierSame();

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _certifierRegistry,
        address _standardsRegistry,
        address _bbt,
        address _ecToken,
        address _treasury
    ) EIP712("Embodied Coherence", "1") Ownable(msg.sender) {
        certifierRegistry = CertifierRegistry(_certifierRegistry);
        standardsRegistry = StandardsRegistry(_standardsRegistry);
        bbt = BBT(_bbt);
        ecToken = IERC20(_ecToken);
        treasury = _treasury;
    }

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Submit an attestation to mint a BBT
    /// @param attestation The attestation data
    /// @param proverSig Prover's EIP-712 signature
    /// @param certifierSig Certifier's EIP-712 signature
    /// @return tokenId The minted BBT token ID
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

        // Mark as used
        usedAttestations[attestationHash] = true;

        // Handle fees
        _handleFees(attestation.standardId, attestation.certifier);

        // Mint BBT
        tokenId = bbt.mint(
            attestation.prover,
            attestation.standardId,
            attestation.certifier,
            attestation.evidenceHash,
            attestation.score
        );

        emit AttestationSubmitted(
            attestationHash,
            attestation.prover,
            attestation.certifier,
            attestation.standardId,
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

        // Certifier must be authorized
        if (!certifierRegistry.isCertifier(attestation.certifier)) {
            revert CertifierNotAuthorized();
        }

        // Standard must be active
        if (!standardsRegistry.isActiveStandard(attestation.standardId)) {
            revert StandardNotActive();
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

    function _handleFees(bytes32 standardId, address certifier) internal {
        StandardsRegistry.Standard memory std = standardsRegistry.getStandard(standardId);

        if (std.baseFee == 0) return;

        // Transfer fee from caller
        ecToken.safeTransferFrom(msg.sender, address(this), std.baseFee);

        // Calculate splits
        uint256 creatorShare = (std.baseFee * std.royaltyBps) / 10000;
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
            ecToken.safeTransfer(certifier, certifierShare);
        }
    }
}
