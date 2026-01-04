// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/// @title BBT (Body Bound Token)
/// @notice Non-transferable Soul Bound Token for certified physical achievements
/// @dev ERC-721 with transfer restrictions - tokens can only be minted or burned
contract BBT is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Strings for address;

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    struct TokenData {
        bytes32 standardId;
        address certifier;
        bytes32 evidenceHash;
        uint256 certifiedAt;
        uint256 score;
    }

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => TokenData) public tokenData;
    uint256 private _tokenIdCounter;

    address public popw;
    string public baseURI;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event BBTMinted(
        uint256 indexed tokenId,
        address indexed prover,
        bytes32 indexed standardId,
        address certifier,
        uint256 score
    );

    event BBTBurned(uint256 indexed tokenId, address indexed owner);
    event PoPWUpdated(address indexed newPoPW);
    event BaseURIUpdated(string newBaseURI);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error TransferNotAllowed();
    error OnlyPoPW();
    error OnlyTokenOwner();

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyPoPW() {
        if (msg.sender != popw) revert OnlyPoPW();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() ERC721("Body Bound Token", "BBT") Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mint a new BBT (only callable by PoPW contract)
    /// @param to Recipient (prover) address
    /// @param standardId ID of the achieved standard
    /// @param certifier Address of the certifying certifier
    /// @param evidenceHash Hash of evidence (IPFS CID hash)
    /// @param score Achievement score (if applicable)
    /// @return tokenId The minted token ID
    function mint(
        address to,
        bytes32 standardId,
        address certifier,
        bytes32 evidenceHash,
        uint256 score
    ) external onlyPoPW returns (uint256 tokenId) {
        tokenId = _tokenIdCounter++;

        tokenData[tokenId] = TokenData({
            standardId: standardId,
            certifier: certifier,
            evidenceHash: evidenceHash,
            certifiedAt: block.timestamp,
            score: score
        });

        _safeMint(to, tokenId);

        emit BBTMinted(tokenId, to, standardId, certifier, score);
    }

    /// @notice Burn a BBT (only callable by token owner)
    /// @param tokenId Token ID to burn
    function burn(uint256 tokenId) external {
        if (ownerOf(tokenId) != msg.sender) revert OnlyTokenOwner();

        delete tokenData[tokenId];
        _burn(tokenId);

        emit BBTBurned(tokenId, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Set the PoPW contract address
    /// @param _popw New PoPW address
    function setPoPW(address _popw) external onlyOwner {
        popw = _popw;
        emit PoPWUpdated(_popw);
    }

    /// @notice Set the base URI for token metadata
    /// @param _baseURI New base URI
    function setBaseURI(string calldata _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit BaseURIUpdated(_baseURI);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get token data for a specific token
    /// @param tokenId Token ID to query
    /// @return Token data struct
    function getTokenData(uint256 tokenId) external view returns (TokenData memory) {
        _requireOwned(tokenId);
        return tokenData[tokenId];
    }

    /// @notice Get all tokens owned by an address
    /// @param owner Address to query
    /// @return Array of token IDs
    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 balance = balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance);

        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(owner, i);
        }

        return tokens;
    }

    /// @notice Generate on-chain token URI with metadata
    /// @param tokenId Token ID to get URI for
    /// @return JSON metadata URI (base64 encoded)
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        TokenData memory data = tokenData[tokenId];

        // If baseURI is set, use external metadata
        if (bytes(baseURI).length > 0) {
            return string(abi.encodePacked(baseURI, tokenId.toString()));
        }

        // Otherwise, generate on-chain metadata
        string memory json = string(
            abi.encodePacked(
                '{"name":"BBT #',
                tokenId.toString(),
                '","description":"Body Bound Token - Certified Physical Achievement",',
                '"attributes":[',
                '{"trait_type":"Standard ID","value":"',
                _bytes32ToHexString(data.standardId),
                '"},',
                '{"trait_type":"Certifier","value":"',
                data.certifier.toHexString(),
                '"},',
                '{"trait_type":"Score","value":',
                data.score.toString(),
                "},",
                '{"trait_type":"Certified At","value":',
                data.certifiedAt.toString(),
                "}",
                "]}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Override to prevent transfers (Soul Bound)
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);

        // Allow minting (from = 0) and burning (to = 0)
        // Block all transfers (from != 0 && to != 0)
        if (from != address(0) && to != address(0)) {
            revert TransferNotAllowed();
        }

        return super._update(to, tokenId, auth);
    }

    /// @dev Convert bytes32 to hex string
    function _bytes32ToHexString(bytes32 data) internal pure returns (string memory) {
        bytes memory hexChars = "0123456789abcdef";
        bytes memory str = new bytes(66);
        str[0] = "0";
        str[1] = "x";

        for (uint256 i = 0; i < 32; i++) {
            str[2 + i * 2] = hexChars[uint8(data[i] >> 4)];
            str[3 + i * 2] = hexChars[uint8(data[i] & 0x0f)];
        }

        return string(str);
    }
}
