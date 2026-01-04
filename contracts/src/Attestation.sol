// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Attestation
/// @notice EIP-712 typed data schema for PoPW attestations
/// @dev Defines the attestation structure and hashing for signature verification
library Attestation {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    /// @notice Result of an attestation attempt
    uint8 public constant PASS = 1;
    uint8 public constant NO_PASS = 0;

    struct Data {
        bytes32 standardId;
        uint32 version;
        address prover;
        address certifier;
        uint8 result; // PASS=1, NO_PASS=0
        uint64 timestamp;
        uint64 nonce; // per-prover nonce
        uint64 deadline; // signature expiry
        bytes32 toolId; // optional; 0x0 if unused
        bytes32 evidenceHash; // optional; 0x0 if unused
    }

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    bytes32 internal constant ATTESTATION_TYPEHASH = keccak256(
        "Attestation(bytes32 standardId,uint32 version,address prover,address certifier,uint8 result,uint64 timestamp,uint64 nonce,uint64 deadline,bytes32 toolId,bytes32 evidenceHash)"
    );

    /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Hash an attestation for EIP-712 signing
    /// @param attestation The attestation data to hash
    /// @return The struct hash
    function hash(Data memory attestation) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                ATTESTATION_TYPEHASH,
                attestation.standardId,
                attestation.version,
                attestation.prover,
                attestation.certifier,
                attestation.result,
                attestation.timestamp,
                attestation.nonce,
                attestation.deadline,
                attestation.toolId,
                attestation.evidenceHash
            )
        );
    }

    /// @notice Check if attestation result is PASS
    /// @param attestation The attestation to check
    /// @return True if result is PASS
    function isPassed(Data memory attestation) internal pure returns (bool) {
        return attestation.result == PASS;
    }
}
