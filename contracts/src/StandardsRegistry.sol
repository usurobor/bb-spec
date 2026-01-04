// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title StandardsRegistry
/// @notice Registry for versioned certification Standard definitions
/// @dev Standards are immutable once created; versions are tracked separately
contract StandardsRegistry is Ownable {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    struct StandardVersion {
        bytes32 standardId;
        uint32 version;
        address creator;
        bytes32 metadataHash; // hash of metadata (IPFS CID hash, etc.)
        string metadataURI; // pointer to metadata
        uint256 royaltyBps;
        uint256 baseFee;
        bool leaderboardEligible;
        uint64 createdAt;
    }

    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant MAX_ROYALTY_BPS = 3000; // 30% max

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping from (standardId, version) to StandardVersion
    mapping(bytes32 => mapping(uint32 => StandardVersion)) public versions;

    /// @notice Latest version number for each standardId
    mapping(bytes32 => uint32) public latestVersion;

    /// @notice Creator of each standardId
    mapping(bytes32 => address) public standardCreator;

    /// @notice All standard IDs
    bytes32[] public standardIds;

    uint256 private _nonce;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event StandardCreated(bytes32 indexed standardId, address indexed creator);

    event VersionCreated(
        bytes32 indexed standardId,
        uint32 indexed version,
        address indexed creator,
        bytes32 metadataHash,
        string metadataURI,
        uint256 royaltyBps,
        uint256 baseFee
    );

    event LeaderboardEligibilitySet(
        bytes32 indexed standardId,
        uint32 indexed version,
        bool eligible
    );

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error StandardNotFound();
    error VersionNotFound();
    error NotStandardCreator();
    error RoyaltyTooHigh();
    error InvalidMetadata();
    error VersionAlreadyExists();

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Create a new standard with initial version
    /// @param metadataHash Hash of the metadata content
    /// @param metadataURI URI pointing to metadata (IPFS, Arweave, etc.)
    /// @param royaltyBps Creator royalty in basis points (max 3000 = 30%)
    /// @param baseFee Base certification fee in $EC wei
    /// @return standardId Unique identifier for the standard
    function createStandard(
        bytes32 metadataHash,
        string calldata metadataURI,
        uint256 royaltyBps,
        uint256 baseFee
    ) external returns (bytes32 standardId) {
        if (metadataHash == bytes32(0)) revert InvalidMetadata();
        if (bytes(metadataURI).length == 0) revert InvalidMetadata();
        if (royaltyBps > MAX_ROYALTY_BPS) revert RoyaltyTooHigh();

        // Generate unique ID
        standardId = keccak256(abi.encodePacked(msg.sender, block.timestamp, _nonce++));

        standardCreator[standardId] = msg.sender;
        standardIds.push(standardId);

        emit StandardCreated(standardId, msg.sender);

        // Create version 1
        _createVersion(standardId, 1, metadataHash, metadataURI, royaltyBps, baseFee);
    }

    /// @notice Create a new version of an existing standard
    /// @param standardId ID of the standard
    /// @param metadataHash Hash of the metadata content
    /// @param metadataURI URI pointing to metadata
    /// @param royaltyBps Creator royalty in basis points
    /// @param baseFee Base certification fee
    /// @return version The new version number
    function createVersion(
        bytes32 standardId,
        bytes32 metadataHash,
        string calldata metadataURI,
        uint256 royaltyBps,
        uint256 baseFee
    ) external returns (uint32 version) {
        if (standardCreator[standardId] == address(0)) revert StandardNotFound();
        if (standardCreator[standardId] != msg.sender) revert NotStandardCreator();
        if (metadataHash == bytes32(0)) revert InvalidMetadata();
        if (bytes(metadataURI).length == 0) revert InvalidMetadata();
        if (royaltyBps > MAX_ROYALTY_BPS) revert RoyaltyTooHigh();

        version = latestVersion[standardId] + 1;
        _createVersion(standardId, version, metadataHash, metadataURI, royaltyBps, baseFee);
    }

    /// @notice Set leaderboard eligibility for a version (owner only)
    /// @param standardId ID of the standard
    /// @param version Version number
    /// @param eligible Whether this version is leaderboard eligible
    function setLeaderboardEligible(
        bytes32 standardId,
        uint32 version,
        bool eligible
    ) external onlyOwner {
        if (versions[standardId][version].creator == address(0)) revert VersionNotFound();

        versions[standardId][version].leaderboardEligible = eligible;

        emit LeaderboardEligibilitySet(standardId, version, eligible);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get a specific version of a standard
    /// @param standardId ID of the standard
    /// @param version Version number
    /// @return StandardVersion struct
    function getVersion(
        bytes32 standardId,
        uint32 version
    ) external view returns (StandardVersion memory) {
        StandardVersion memory v = versions[standardId][version];
        if (v.creator == address(0)) revert VersionNotFound();
        return v;
    }

    /// @notice Get the latest version of a standard
    /// @param standardId ID of the standard
    /// @return StandardVersion struct
    function getLatestVersion(bytes32 standardId) external view returns (StandardVersion memory) {
        uint32 version = latestVersion[standardId];
        if (version == 0) revert StandardNotFound();
        return versions[standardId][version];
    }

    /// @notice Check if a version exists and is valid
    /// @param standardId ID to check
    /// @param version Version to check
    /// @return True if version exists
    function isValidVersion(bytes32 standardId, uint32 version) external view returns (bool) {
        return versions[standardId][version].creator != address(0);
    }

    /// @notice Check if a version is leaderboard eligible
    /// @param standardId ID to check
    /// @param version Version to check
    /// @return True if leaderboard eligible
    function isLeaderboardEligible(
        bytes32 standardId,
        uint32 version
    ) external view returns (bool) {
        return versions[standardId][version].leaderboardEligible;
    }

    /// @notice Get total number of standards
    /// @return Count of all standards
    function getStandardCount() external view returns (uint256) {
        return standardIds.length;
    }

    /// @notice Get all standard IDs
    /// @return Array of standard IDs
    function getAllStandardIds() external view returns (bytes32[] memory) {
        return standardIds;
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _createVersion(
        bytes32 standardId,
        uint32 version,
        bytes32 metadataHash,
        string calldata metadataURI,
        uint256 royaltyBps,
        uint256 baseFee
    ) internal {
        versions[standardId][version] = StandardVersion({
            standardId: standardId,
            version: version,
            creator: msg.sender,
            metadataHash: metadataHash,
            metadataURI: metadataURI,
            royaltyBps: royaltyBps,
            baseFee: baseFee,
            leaderboardEligible: false,
            createdAt: uint64(block.timestamp)
        });

        latestVersion[standardId] = version;

        emit VersionCreated(
            standardId,
            version,
            msg.sender,
            metadataHash,
            metadataURI,
            royaltyBps,
            baseFee
        );
    }
}
