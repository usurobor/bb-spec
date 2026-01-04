// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title CertifierRegistry
/// @notice Manages Certifier authorization via Genesis Keys and 3-vouch expansion
/// @dev Certifiers are authorized to co-sign attestations for the PoPW contract
contract CertifierRegistry is Ownable {
    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant VOUCHES_REQUIRED = 3;

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    struct RateLimit {
        uint64 windowSeconds;
        uint32 maxAttestations;
    }

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) public isCertifier;
    mapping(address => bool) public isGenesisKey;
    mapping(address => address[]) public vouchesReceived;
    mapping(address => mapping(address => bool)) public hasVouched;

    uint256 public certifierCount;

    /// @notice Rate limits per standard (bytes32(0) = global default)
    mapping(bytes32 => RateLimit) public rateLimits;

    /// @notice Attestation count per certifier per standard per window
    /// @dev Key: keccak256(certifier, standardId, windowStart)
    mapping(bytes32 => uint32) public attestationCounts;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event GenesisKeyAdded(address indexed certifier);
    event VouchGiven(address indexed voucher, address indexed candidate);
    event VouchRevoked(address indexed voucher, address indexed candidate);
    event CertifierAdmitted(address indexed certifier);
    event CertifierRevoked(address indexed certifier, address indexed revokedBy);
    event RateLimitSet(bytes32 indexed standardId, uint64 windowSeconds, uint32 maxAttestations);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error AlreadyCertifier();
    error NotCertifier();
    error AlreadyVouched();
    error NotVouched();
    error CannotVouchSelf();
    error GenesisAlreadyInitialized();
    error NotGenesisKey();
    error CannotRevokeGenesisKey();
    error RateLimitExceeded();

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                            GENESIS FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Initialize genesis certifiers (can only be called once per address)
    /// @param genesisKeys Array of addresses to set as genesis certifiers
    function initializeGenesis(address[] calldata genesisKeys) external onlyOwner {
        for (uint256 i = 0; i < genesisKeys.length; i++) {
            address key = genesisKeys[i];
            if (isGenesisKey[key]) revert GenesisAlreadyInitialized();

            isGenesisKey[key] = true;
            isCertifier[key] = true;
            certifierCount++;

            emit GenesisKeyAdded(key);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            VOUCH FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Vouch for a candidate to become a certifier
    /// @param candidate Address to vouch for
    function vouch(address candidate) external {
        if (!isCertifier[msg.sender]) revert NotCertifier();
        if (isCertifier[candidate]) revert AlreadyCertifier();
        if (hasVouched[msg.sender][candidate]) revert AlreadyVouched();
        if (candidate == msg.sender) revert CannotVouchSelf();

        hasVouched[msg.sender][candidate] = true;
        vouchesReceived[candidate].push(msg.sender);

        emit VouchGiven(msg.sender, candidate);

        // Check if candidate now has enough vouches
        if (vouchesReceived[candidate].length >= VOUCHES_REQUIRED) {
            _admitCertifier(candidate);
        }
    }

    /// @notice Revoke a vouch for a candidate
    /// @param candidate Address to revoke vouch from
    function revokeVouch(address candidate) external {
        if (!isCertifier[msg.sender]) revert NotCertifier();
        if (!hasVouched[msg.sender][candidate]) revert NotVouched();
        if (isCertifier[candidate]) revert AlreadyCertifier(); // Can't revoke after admission

        hasVouched[msg.sender][candidate] = false;

        // Remove from vouchesReceived array
        address[] storage vouches = vouchesReceived[candidate];
        for (uint256 i = 0; i < vouches.length; i++) {
            if (vouches[i] == msg.sender) {
                vouches[i] = vouches[vouches.length - 1];
                vouches.pop();
                break;
            }
        }

        emit VouchRevoked(msg.sender, candidate);
    }

    /*//////////////////////////////////////////////////////////////
                          REVOCATION FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Revoke a certifier's status (Genesis Keys only, v1 safety valve)
    /// @param certifier Address to revoke
    function revokeCertifier(address certifier) external {
        if (!isGenesisKey[msg.sender]) revert NotGenesisKey();
        if (!isCertifier[certifier]) revert NotCertifier();
        if (isGenesisKey[certifier]) revert CannotRevokeGenesisKey();

        isCertifier[certifier] = false;
        certifierCount--;

        emit CertifierRevoked(certifier, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                          RATE LIMIT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Set rate limit for a standard (owner only)
    /// @param standardId Standard ID (bytes32(0) for global default)
    /// @param windowSeconds Time window in seconds
    /// @param maxAttestations Max attestations per certifier per window
    function setRateLimit(
        bytes32 standardId,
        uint64 windowSeconds,
        uint32 maxAttestations
    ) external onlyOwner {
        rateLimits[standardId] = RateLimit({
            windowSeconds: windowSeconds,
            maxAttestations: maxAttestations
        });

        emit RateLimitSet(standardId, windowSeconds, maxAttestations);
    }

    /// @notice Record an attestation and check rate limit (called by PoPW)
    /// @param certifier Certifier address
    /// @param standardId Standard ID
    /// @return allowed True if within rate limit
    function recordAttestation(
        address certifier,
        bytes32 standardId
    ) external returns (bool allowed) {
        if (!isCertifier[certifier]) revert NotCertifier();

        // Get rate limit (standard-specific or global default)
        RateLimit memory limit = rateLimits[standardId];
        if (limit.windowSeconds == 0) {
            limit = rateLimits[bytes32(0)]; // global default
        }

        // No rate limit configured
        if (limit.windowSeconds == 0 || limit.maxAttestations == 0) {
            return true;
        }

        // Calculate window start
        uint64 windowStart = uint64(block.timestamp / limit.windowSeconds) * limit.windowSeconds;
        bytes32 key = keccak256(abi.encodePacked(certifier, standardId, windowStart));

        // Check and increment
        uint32 count = attestationCounts[key];
        if (count >= limit.maxAttestations) {
            revert RateLimitExceeded();
        }

        attestationCounts[key] = count + 1;
        return true;
    }

    /// @notice Check if a certifier can attest (view only, doesn't record)
    /// @param certifier Certifier address
    /// @param standardId Standard ID
    /// @return canAttest True if within rate limit
    /// @return remaining Remaining attestations in current window
    function checkRateLimit(
        address certifier,
        bytes32 standardId
    ) external view returns (bool canAttest, uint32 remaining) {
        if (!isCertifier[certifier]) {
            return (false, 0);
        }

        RateLimit memory limit = rateLimits[standardId];
        if (limit.windowSeconds == 0) {
            limit = rateLimits[bytes32(0)];
        }

        if (limit.windowSeconds == 0 || limit.maxAttestations == 0) {
            return (true, type(uint32).max);
        }

        uint64 windowStart = uint64(block.timestamp / limit.windowSeconds) * limit.windowSeconds;
        bytes32 key = keccak256(abi.encodePacked(certifier, standardId, windowStart));
        uint32 count = attestationCounts[key];

        if (count >= limit.maxAttestations) {
            return (false, 0);
        }

        return (true, limit.maxAttestations - count);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the number of vouches a candidate has received
    /// @param candidate Address to check
    /// @return Number of vouches
    function getVouchCount(address candidate) external view returns (uint256) {
        return vouchesReceived[candidate].length;
    }

    /// @notice Get all vouchers for a candidate
    /// @param candidate Address to check
    /// @return Array of voucher addresses
    function getVouchers(address candidate) external view returns (address[] memory) {
        return vouchesReceived[candidate];
    }

    /// @notice Check if an address is an authorized certifier
    /// @param account Address to check
    /// @return True if certifier
    function getCertifierStatus(address account) external view returns (bool) {
        return isCertifier[account];
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _admitCertifier(address candidate) internal {
        isCertifier[candidate] = true;
        certifierCount++;

        emit CertifierAdmitted(candidate);
    }
}
