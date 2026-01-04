// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title StandardsRegistry
/// @notice Registry for certification Standard definitions
/// @dev Standards define what physical achievements can be certified
contract StandardsRegistry {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    struct Standard {
        bytes32 id;
        address creator;
        string metadataURI;
        uint256 royaltyBps;
        uint256 baseFee;
        bool active;
        uint256 createdAt;
    }

    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant MAX_ROYALTY_BPS = 3000; // 30% max

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    mapping(bytes32 => Standard) public standards;
    bytes32[] public standardIds;

    uint256 private _nonce;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event StandardCreated(
        bytes32 indexed id,
        address indexed creator,
        string metadataURI,
        uint256 royaltyBps,
        uint256 baseFee
    );
    event StandardDeactivated(bytes32 indexed id);
    event StandardReactivated(bytes32 indexed id);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error StandardNotFound();
    error StandardNotActive();
    error NotStandardCreator();
    error RoyaltyTooHigh();
    error InvalidMetadataURI();

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Create a new certification standard
    /// @param metadataURI IPFS/Arweave URI pointing to standard JSON
    /// @param royaltyBps Creator royalty in basis points (max 3000 = 30%)
    /// @param baseFee Base certification fee in $EC wei
    /// @return standardId Unique identifier for the standard
    function createStandard(
        string calldata metadataURI,
        uint256 royaltyBps,
        uint256 baseFee
    ) external returns (bytes32 standardId) {
        if (bytes(metadataURI).length == 0) revert InvalidMetadataURI();
        if (royaltyBps > MAX_ROYALTY_BPS) revert RoyaltyTooHigh();

        // Generate unique ID
        standardId = keccak256(abi.encodePacked(msg.sender, block.timestamp, _nonce++));

        standards[standardId] = Standard({
            id: standardId,
            creator: msg.sender,
            metadataURI: metadataURI,
            royaltyBps: royaltyBps,
            baseFee: baseFee,
            active: true,
            createdAt: block.timestamp
        });

        standardIds.push(standardId);

        emit StandardCreated(standardId, msg.sender, metadataURI, royaltyBps, baseFee);
    }

    /// @notice Deactivate a standard (creator only)
    /// @param standardId ID of standard to deactivate
    function deactivateStandard(bytes32 standardId) external {
        Standard storage std = standards[standardId];
        if (std.creator == address(0)) revert StandardNotFound();
        if (std.creator != msg.sender) revert NotStandardCreator();

        std.active = false;

        emit StandardDeactivated(standardId);
    }

    /// @notice Reactivate a standard (creator only)
    /// @param standardId ID of standard to reactivate
    function reactivateStandard(bytes32 standardId) external {
        Standard storage std = standards[standardId];
        if (std.creator == address(0)) revert StandardNotFound();
        if (std.creator != msg.sender) revert NotStandardCreator();

        std.active = true;

        emit StandardReactivated(standardId);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get a standard by ID
    /// @param standardId ID of standard to retrieve
    /// @return Standard struct
    function getStandard(bytes32 standardId) external view returns (Standard memory) {
        Standard memory std = standards[standardId];
        if (std.creator == address(0)) revert StandardNotFound();
        return std;
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

    /// @notice Check if a standard exists and is active
    /// @param standardId ID to check
    /// @return True if standard exists and is active
    function isActiveStandard(bytes32 standardId) external view returns (bool) {
        Standard memory std = standards[standardId];
        return std.creator != address(0) && std.active;
    }
}
