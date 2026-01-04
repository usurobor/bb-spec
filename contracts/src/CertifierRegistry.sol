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
                                 STATE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) public isCertifier;
    mapping(address => bool) public isGenesisKey;
    mapping(address => address[]) public vouchesReceived;
    mapping(address => mapping(address => bool)) public hasVouched;

    uint256 public certifierCount;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event GenesisKeyAdded(address indexed certifier);
    event VouchGiven(address indexed voucher, address indexed candidate);
    event VouchRevoked(address indexed voucher, address indexed candidate);
    event CertifierAdmitted(address indexed certifier);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error AlreadyCertifier();
    error NotCertifier();
    error AlreadyVouched();
    error NotVouched();
    error CannotVouchSelf();
    error GenesisAlreadyInitialized();

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
