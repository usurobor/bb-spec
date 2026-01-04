// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @title EC (Embodied Coherence Token)
/// @notice ERC-20 fee and governance token for the Embodied Coherence protocol
/// @dev Standard ERC-20 with EIP-2612 permit functionality
contract EC is ERC20, ERC20Permit {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 10 ** 18; // 1 billion tokens

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Deploy EC token and mint initial supply to treasury
    /// @param treasury Address to receive initial token supply
    constructor(address treasury) ERC20("Embodied Coherence", "EC") ERC20Permit("Embodied Coherence") {
        _mint(treasury, INITIAL_SUPPLY);
    }
}
