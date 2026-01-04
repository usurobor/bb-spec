# Technical Specification
## Embodied Coherence Protocol v1.0.16

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

**Purpose**: Manage Certifier authorization, vouching, revocation, and rate limits.

**State Variables**:
```solidity
mapping(address => bool) public isCertifier;
mapping(address => bool) public isGenesisKey;
mapping(address => address[]) public vouchesReceived;
mapping(address => mapping(address => bool)) public hasVouched;
uint256 public constant VOUCHES_REQUIRED = 3;

// Rate limiting
struct RateLimit {
    uint64 windowSeconds;
    uint32 maxAttestations;
}
mapping(bytes32 => RateLimit) public rateLimits;
mapping(address => mapping(bytes32 => mapping(uint64 => uint32))) public attestationCounts;
```

**Functions**:
```solidity
function initializeGenesis(address[] calldata genesisKeys) external onlyOwner;
function vouch(address candidate) external onlyCertifier;
function revokeVouch(address candidate) external onlyCertifier;
function revokeCertifier(address certifier) external onlyGenesisKey;
function getCertifierStatus(address account) external view returns (bool);

// Rate limiting
function setRateLimit(bytes32 standardId, uint64 windowSeconds, uint32 maxAttestations) external onlyOwner;
function recordAttestation(address certifier, bytes32 standardId) external onlyPoPW returns (bool);
function checkRateLimit(address certifier, bytes32 standardId) external view returns (bool);
```

**Events**:
```solidity
event GenesisKeyAdded(address indexed certifier);
event CertifierVouched(address indexed voucher, address indexed candidate);
event VouchRevoked(address indexed voucher, address indexed candidate);
event CertifierAdmitted(address indexed certifier);
event CertifierRevoked(address indexed certifier, address indexed revokedBy);
event RateLimitSet(bytes32 indexed standardId, uint64 windowSeconds, uint32 maxAttestations);
```

---

### 2.2 StandardsRegistry.sol

**Purpose**: Store and manage versioned certification Standard definitions.

**State Variables**:
```solidity
struct StandardVersion {
    bytes32 metadataHash;
    bool leaderboardEligible;
    uint256 createdAt;
}

struct Standard {
    bytes32 id;
    address creator;
    uint32 latestVersion;
    uint256 royaltyBps;
    uint256 baseFee;
    bool active;
}

mapping(bytes32 => Standard) public standards;
mapping(bytes32 => mapping(uint32 => StandardVersion)) public versions;
bytes32[] public standardIds;
```

**Functions**:
```solidity
function createStandard(
    bytes32 metadataHash,
    uint256 royaltyBps,
    uint256 baseFee
) external returns (bytes32 standardId);

function addVersion(
    bytes32 standardId,
    bytes32 metadataHash
) external returns (uint32 version);

function setLeaderboardEligible(
    bytes32 standardId,
    uint32 version,
    bool eligible
) external onlyOwner;

function deactivateStandard(bytes32 standardId) external;
function getStandard(bytes32 standardId) external view returns (Standard memory);
function getVersion(bytes32 standardId, uint32 version) external view returns (StandardVersion memory);
```

**Events**:
```solidity
event StandardRegistered(bytes32 indexed id, address indexed creator, bytes32 metadataHash);
event VersionAdded(bytes32 indexed standardId, uint32 version, bytes32 metadataHash);
event LeaderboardEligibilitySet(bytes32 indexed standardId, uint32 version, bool eligible);
event StandardDeactivated(bytes32 indexed id);
```

---

### 2.3 PoPW.sol

**Purpose**: Core attestation and minting contract with nonce/deadline validation.

**State Variables**:
```solidity
struct Attestation {
    bytes32 standardId;
    uint32 version;
    address prover;
    address certifier;
    uint8 result;          // PASS=1, NO_PASS=0
    uint64 timestamp;
    uint64 nonce;
    uint64 deadline;
    bytes32 toolId;        // Optional
    bytes32 evidenceHash;  // Optional
}

uint8 public constant PASS = 1;
uint8 public constant NO_PASS = 0;

mapping(address => uint64) public nonces;
mapping(bytes32 => bool) public attestationRecorded;
mapping(address => mapping(bytes32 => mapping(uint32 => bool))) public hasPassed;

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
function getCurrentNonce(address prover) external view returns (uint64);
```

**Validation Logic**:
```solidity
function attest(...) external returns (uint256 tokenId) {
    // 1. Verify deadline not expired
    require(block.timestamp <= attestation.deadline, "Deadline expired");

    // 2. Verify nonce matches expected
    require(attestation.nonce == nonces[attestation.prover], "Invalid nonce");

    // 3. Verify certifier is authorized (at submission time)
    require(certifierRegistry.isCertifier(attestation.certifier), "Not authorized");

    // 4. Check rate limits
    require(certifierRegistry.recordAttestation(attestation.certifier, attestation.standardId), "Rate limit exceeded");

    // 5. Verify signatures
    require(verifySignatures(attestation, proverSig, certifierSig), "Invalid signatures");

    // 6. Increment nonce
    nonces[attestation.prover]++;

    // 7. Record attestation
    bytes32 attestHash = getAttestationHash(attestation);
    attestationRecorded[attestHash] = true;

    // 8. Handle result
    if (attestation.result == PASS) {
        // Check one PASS per (prover, standardId, version)
        require(!hasPassed[attestation.prover][attestation.standardId][attestation.version], "Already passed");
        hasPassed[attestation.prover][attestation.standardId][attestation.version] = true;

        // Mint BBT
        tokenId = bbt.mint(attestation.prover, attestation.standardId, attestation.version, ...);

        // Distribute fees (creator royalty on PASS only)
        _distributeFees(attestation.standardId, attestation.certifier, true);
    } else {
        // NO_PASS: record attempt, no BBT
        tokenId = 0;

        // Certifier still gets fee for attempt
        _distributeFees(attestation.standardId, attestation.certifier, false);
    }

    emit AttestationRecorded(attestHash, attestation.prover, attestation.certifier, attestation.standardId, attestation.version, attestation.result);
    if (attestation.result == PASS) {
        emit BBTMinted(tokenId, attestation.prover, attestation.standardId, attestation.version);
    }
}
```

**Events**:
```solidity
event AttestationRecorded(
    bytes32 indexed attestationHash,
    address indexed prover,
    address indexed certifier,
    bytes32 standardId,
    uint32 version,
    uint8 result
);
event BBTMinted(
    uint256 indexed tokenId,
    address indexed prover,
    bytes32 indexed standardId,
    uint32 version
);
```

**EIP-712 Domain**:
```solidity
bytes32 constant DOMAIN_TYPEHASH = keccak256(
    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
);

// Domain: name="PoPW", version="1"
```

**EIP-712 Attestation Type**:
```solidity
bytes32 constant ATTESTATION_TYPEHASH = keccak256(
    "Attestation(bytes32 standardId,uint32 version,address prover,address certifier,uint8 result,uint64 timestamp,uint64 nonce,uint64 deadline,bytes32 toolId,bytes32 evidenceHash)"
);
```

---

### 2.4 BBT.sol

**Purpose**: Non-transferable Soul Bound Token for certifications. Does not expire (v1).

**Inheritance**: ERC-721 with transfer restrictions.

**State Variables**:
```solidity
struct TokenData {
    bytes32 standardId;
    uint32 version;
    address certifier;
    bytes32 evidenceHash;
    uint256 certifiedAt;
}

mapping(uint256 => TokenData) public tokenData;
uint256 private _tokenIdCounter;
```

**Functions**:
```solidity
function mint(
    address to,
    bytes32 standardId,
    uint32 version,
    address certifier,
    bytes32 evidenceHash
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

function approve(address, uint256) public pure override {
    revert ApprovalsDisabled();
}

function setApprovalForAll(address, bool) public pure override {
    revert ApprovalsDisabled();
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
    name: "PoPW",
    version: "1",
    chainId: chainId,
    verifyingContract: popwAddress
};

const types = {
    Attestation: [
        { name: "standardId", type: "bytes32" },
        { name: "version", type: "uint32" },
        { name: "prover", type: "address" },
        { name: "certifier", type: "address" },
        { name: "result", type: "uint8" },
        { name: "timestamp", type: "uint64" },
        { name: "nonce", type: "uint64" },
        { name: "deadline", type: "uint64" },
        { name: "toolId", type: "bytes32" },
        { name: "evidenceHash", type: "bytes32" }
    ]
};
```

### 3.2 Verification Flow

1. Verify deadline has not expired
2. Verify nonce matches prover's current nonce
3. Reconstruct attestation hash using EIP-712
4. Recover signer from prover signature
5. Verify recovered address matches `attestation.prover`
6. Recover signer from certifier signature
7. Verify recovered address matches `attestation.certifier`
8. Verify certifier is authorized at submission time via CertifierRegistry

---

## 4. Fee Distribution

### 4.1 Flow

```
Prover pays (baseFee in $EC or approved fee assets)
         │
         ├──► Creator royalty (PASS only)
         ├──► Certifier reward (per attempt)
         └──► Protocol ops
```

### 4.2 Implementation

```solidity
function _distributeFees(bytes32 standardId, address certifier, bool isPass) internal {
    Standard memory std = standardsRegistry.getStandard(standardId);
    uint256 fee = std.baseFee;

    // Certifier gets reward per attempt
    uint256 certifierShare = (fee * CERTIFIER_BPS) / 10000;
    ecToken.transfer(certifier, certifierShare);

    if (isPass) {
        // Creator royalty only on PASS
        uint256 creatorShare = (fee * std.royaltyBps) / 10000;
        ecToken.transfer(std.creator, creatorShare);

        uint256 treasuryShare = fee - certifierShare - creatorShare;
        ecToken.transfer(treasury, treasuryShare);
    } else {
        // NO_PASS: remaining goes to treasury
        uint256 treasuryShare = fee - certifierShare;
        ecToken.transfer(treasury, treasuryShare);
    }
}
```

---

## 5. Evidence Storage

### 5.1 Off-Chain Storage

Evidence files stored on IPFS or Arweave:
- Video recordings
- Witness statements
- Metadata

Media stays off-chain; recording requires mutual consent as defined by the Standard.

### 5.2 On-Chain Reference

```solidity
bytes32 evidenceHash = keccak256(abi.encodePacked(ipfsCid));
```

Attestations may reference media by hash/pointer.

---

## 6. Indexing & Leaderboards

### 6.1 Subgraph Entities

```graphql
type Certifier @entity {
  id: ID!
  address: Bytes!
  isGenesis: Boolean!
  isActive: Boolean!
  vouches: [Vouch!]! @derivedFrom(field: "voucher")
  certifications: [Certification!]! @derivedFrom(field: "certifier")
  totalCertifications: BigInt!
}

type Standard @entity {
  id: ID!
  creator: Bytes!
  latestVersion: Int!
  versions: [StandardVersion!]! @derivedFrom(field: "standard")
  certifications: [Certification!]! @derivedFrom(field: "standard")
  totalCertifications: BigInt!
}

type StandardVersion @entity {
  id: ID!
  standard: Standard!
  version: Int!
  metadataHash: Bytes!
  leaderboardEligible: Boolean!
  createdAt: BigInt!
}

type Certification @entity {
  id: ID!
  prover: Bytes!
  certifier: Certifier!
  standard: Standard!
  version: Int!
  tokenId: BigInt
  evidenceHash: Bytes!
  result: Int!
  timestamp: BigInt!
}
```

### 6.2 Leaderboards

Per Standard version: rank verified PASS by the Standard's leaderboard rule.

Leaderboards apply only to versions marked `leaderboardEligible`.

Anomalous Certifier–Prover concentration may be excluded from leaderboard eligibility (monitoring).

---

## 7. Security Considerations

### 7.1 Replay Protection
- Attestation includes nonce (per prover)
- Attestation includes deadline (expiry)
- Used attestations tracked in mapping

### 7.2 Signature Malleability
- Use OpenZeppelin ECDSA library
- Reject malleable signatures

### 7.3 Access Control
- Only PoPW can mint BBTs
- Only owner can initialize genesis keys
- Only certifiers can vouch
- Only Genesis Keys can revoke certifiers (v1 safety valve)
- Rate limits enforced per certifier per standard per time window

### 7.4 Authorization Timing
- Certifier authorization checked at submission time
- A revoked certifier cannot submit new attestations

---

## 8. Gas Optimization

- Pack structs efficiently (uint32, uint64, uint8 together)
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

## 10. Required Events (v1)

| Event | Contract |
|-------|----------|
| StandardRegistered | StandardsRegistry |
| CertifierVouched | CertifierRegistry |
| CertifierRevoked | CertifierRegistry |
| AttestationRecorded | PoPW |
| BBTMinted | PoPW |

---

*Technical Specification v1.0.16 — January 2026*
