# Technical Specification
## Embodied Coherence Protocol v1.0

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Frontend (App)                         │
├─────────────────────────────────────────────────────────────┤
│                    Indexer / Subgraph                       │
├─────────────────────────────────────────────────────────────┤
│                    Smart Contracts                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │  Certifier  │ │  Standards  │ │    PoPW     │           │
│  │  Registry   │ │  Registry   │ │  (Attest)   │           │
│  └─────────────┘ └─────────────┘ └──────┬──────┘           │
│                                         │                   │
│  ┌─────────────┐ ┌─────────────┐       │                   │
│  │    BBT      │ │     EC      │←──────┘                   │
│  │   (SBT)     │ │  (ERC-20)   │                           │
│  └─────────────┘ └─────────────┘                           │
├─────────────────────────────────────────────────────────────┤
│                    Storage (IPFS/Arweave)                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Smart Contract Specifications

### 2.1 CertifierRegistry.sol

**Purpose**: Manage Certifier authorization and status.

**State Variables**:
```solidity
mapping(address => bool) public isCertifier;
mapping(address => bool) public isGenesisKey;
mapping(address => address[]) public vouchesReceived;
mapping(address => mapping(address => bool)) public hasVouched;
uint256 public constant VOUCHES_REQUIRED = 3;
```

**Functions**:
```solidity
function initializeGenesis(address[] calldata genesisKeys) external onlyOwner;
function vouch(address candidate) external onlyCertifier;
function revokeVouch(address candidate) external onlyCertifier;
function getCertifierStatus(address account) external view returns (bool);
```

**Events**:
```solidity
event GenesisKeyAdded(address indexed certifier);
event VouchGiven(address indexed voucher, address indexed candidate);
event VouchRevoked(address indexed voucher, address indexed candidate);
event CertifierAdmitted(address indexed certifier);
```

---

### 2.2 StandardsRegistry.sol

**Purpose**: Store and manage certification Standard definitions.

**State Variables**:
```solidity
struct Standard {
    bytes32 id;
    address creator;
    string metadataURI;
    uint256 royaltyBps;
    uint256 baseFee;
    bool active;
    uint256 createdAt;
}

mapping(bytes32 => Standard) public standards;
bytes32[] public standardIds;
```

**Functions**:
```solidity
function createStandard(
    string calldata metadataURI,
    uint256 royaltyBps,
    uint256 baseFee
) external returns (bytes32 standardId);

function deactivateStandard(bytes32 standardId) external;
function getStandard(bytes32 standardId) external view returns (Standard memory);
function getStandardCount() external view returns (uint256);
```

**Events**:
```solidity
event StandardCreated(bytes32 indexed id, address indexed creator, string metadataURI);
event StandardDeactivated(bytes32 indexed id);
```

---

### 2.3 PoPW.sol

**Purpose**: Core attestation and minting contract.

**State Variables**:
```solidity
struct Attestation {
    address prover;
    address certifier;
    bytes32 standardId;
    bytes32 evidenceHash;
    uint256 timestamp;
    uint256 score;
}

mapping(bytes32 => bool) public usedAttestations;
ICertifierRegistry public certifierRegistry;
IStandardsRegistry public standardsRegistry;
IBBT public bbt;
IEC public ecToken;
```

**Functions**:
```solidity
function attest(
    Attestation calldata attestation,
    bytes calldata proverSig,
    bytes calldata certifierSig
) external returns (uint256 tokenId);

function verifySignatures(
    Attestation calldata attestation,
    bytes calldata proverSig,
    bytes calldata certifierSig
) public view returns (bool);

function getAttestationHash(Attestation calldata attestation) public pure returns (bytes32);
```

**Events**:
```solidity
event AttestationSubmitted(
    bytes32 indexed attestationHash,
    address indexed prover,
    address indexed certifier,
    bytes32 standardId,
    uint256 tokenId
);
```

**EIP-712 Domain**:
```solidity
bytes32 constant DOMAIN_TYPEHASH = keccak256(
    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
);

bytes32 constant ATTESTATION_TYPEHASH = keccak256(
    "Attestation(address prover,address certifier,bytes32 standardId,bytes32 evidenceHash,uint256 timestamp,uint256 score)"
);
```

---

### 2.4 BBT.sol

**Purpose**: Non-transferable Soul Bound Token for certifications.

**Inheritance**: ERC-721 with transfer restrictions.

**State Variables**:
```solidity
struct TokenData {
    bytes32 standardId;
    address certifier;
    bytes32 evidenceHash;
    uint256 certifiedAt;
    uint256 score;
}

mapping(uint256 => TokenData) public tokenData;
uint256 private _tokenIdCounter;
```

**Functions**:
```solidity
function mint(
    address to,
    bytes32 standardId,
    address certifier,
    bytes32 evidenceHash,
    uint256 score
) external onlyPoPW returns (uint256 tokenId);

function burn(uint256 tokenId) external; // Only token owner
function tokenURI(uint256 tokenId) external view returns (string memory);
```

**Transfer Restrictions**:
```solidity
function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
    address from = _ownerOf(tokenId);
    if (from != address(0) && to != address(0)) {
        revert TransferNotAllowed();
    }
    return super._update(to, tokenId, auth);
}
```

---

### 2.5 EC.sol

**Purpose**: ERC-20 fee and governance token.

**Inheritance**: OpenZeppelin ERC-20, ERC20Permit.

**State Variables**:
```solidity
uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 10**18; // 1B tokens
```

**Functions**:
```solidity
constructor(address treasury) ERC20("Embodied Coherence", "EC") {
    _mint(treasury, INITIAL_SUPPLY);
}
```

---

## 3. Signature Verification

### 3.1 EIP-712 Typed Data

```javascript
const domain = {
    name: "Embodied Coherence",
    version: "1",
    chainId: chainId,
    verifyingContract: popwAddress
};

const types = {
    Attestation: [
        { name: "prover", type: "address" },
        { name: "certifier", type: "address" },
        { name: "standardId", type: "bytes32" },
        { name: "evidenceHash", type: "bytes32" },
        { name: "timestamp", type: "uint256" },
        { name: "score", type: "uint256" }
    ]
};
```

### 3.2 Verification Flow

1. Reconstruct attestation hash using EIP-712
2. Recover signer from prover signature
3. Verify recovered address matches `attestation.prover`
4. Recover signer from certifier signature
5. Verify recovered address matches `attestation.certifier`
6. Verify certifier is authorized via CertifierRegistry

---

## 4. Fee Distribution

### 4.1 Flow

```
Prover pays (baseFee in $EC)
         │
         ├──► Creator (royaltyBps)
         ├──► Certifier (certifierBps)
         └──► Treasury (remainingBps)
```

### 4.2 Implementation

```solidity
function _distributeFees(bytes32 standardId, address certifier, uint256 fee) internal {
    Standard memory std = standardsRegistry.getStandard(standardId);

    uint256 creatorShare = (fee * std.royaltyBps) / 10000;
    uint256 treasuryShare = (fee * TREASURY_BPS) / 10000;
    uint256 certifierShare = fee - creatorShare - treasuryShare;

    ecToken.transfer(std.creator, creatorShare);
    ecToken.transfer(treasury, treasuryShare);
    ecToken.transfer(certifier, certifierShare);
}
```

---

## 5. Evidence Storage

### 5.1 Off-Chain Storage

Evidence files stored on IPFS or Arweave:
- Video recordings
- Sensor data
- Witness statements
- Metadata

### 5.2 On-Chain Reference

```solidity
bytes32 evidenceHash = keccak256(abi.encodePacked(ipfsCid));
```

---

## 6. Indexing & Leaderboards

### 6.1 Subgraph Entities

```graphql
type Certifier @entity {
  id: ID!
  address: Bytes!
  isGenesis: Boolean!
  vouches: [Vouch!]! @derivedFrom(field: "voucher")
  certifications: [Certification!]! @derivedFrom(field: "certifier")
  totalCertifications: BigInt!
}

type Standard @entity {
  id: ID!
  creator: Bytes!
  metadataURI: String!
  royaltyBps: BigInt!
  certifications: [Certification!]! @derivedFrom(field: "standard")
  totalCertifications: BigInt!
}

type Certification @entity {
  id: ID!
  prover: Bytes!
  certifier: Certifier!
  standard: Standard!
  tokenId: BigInt!
  evidenceHash: Bytes!
  score: BigInt!
  timestamp: BigInt!
}
```

---

## 7. Security Considerations

### 7.1 Replay Protection
- Attestation hash includes timestamp
- Used attestations tracked in mapping
- Nonce per prover (optional enhancement)

### 7.2 Signature Malleability
- Use OpenZeppelin ECDSA library
- Reject malleable signatures

### 7.3 Access Control
- Only PoPW can mint BBTs
- Only owner can initialize genesis keys
- Only certifiers can vouch

---

## 8. Gas Optimization

- Pack structs efficiently
- Use bytes32 for IDs
- Batch operations where possible
- Minimize storage writes

---

## 9. Upgrade Path

Contracts designed for minimal upgradeability:
- Registry contracts: Proxy pattern (optional)
- BBT: Immutable
- EC: Immutable
- PoPW: Versioned deployments

---

*Technical Specification v1.0 — January 2026*
