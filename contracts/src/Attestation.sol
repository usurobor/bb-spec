// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Attestation
/// @notice EIP-712 typed data schema for PoPW attestations
/// @dev Defines the attestation structure and hashing for signature verification
library Attestation {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    struct Data {
        address prover;
        address certifier;
        bytes32 standardId;
        bytes32 evidenceHash;
        uint256 timestamp;
        uint256 score;
    }

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    bytes32 internal constant ATTESTATION_TYPEHASH = keccak256(
        "Attestation(address prover,address certifier,bytes32 standardId,bytes32 evidenceHash,uint256 timestamp,uint256 score)"
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
                attestation.prover,
                attestation.certifier,
                attestation.standardId,
                attestation.evidenceHash,
                attestation.timestamp,
                attestation.score
            )
        );
    }
}
