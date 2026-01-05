# Technical Specification
## Embodied Coherence Protocol v1.0.17

> **Vocabulary:** Architect (defines Trials) • Contender (attempts) • Marshal (observes) • Trial (the test) • Run (one attempt) • Record (signed attestation) • Badge (credential) • Replay (video evidence) • Ladder (rankings)

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
│  │   Marshal   │ │   Trials    │ │    PoPW     │           │
│  │  Registry   │ │  Registry   │ │  (Record)   │           │
│  └─────────────┘ └─────────────┘ └──────┬──────┘           │
│                                         │                   │
│  ┌─────────────┐ ┌─────────────┐       │                   │
│  │   Badge     │ │     EC      │←──────┘                   │
│  │   (SBT)     │ │  (ERC-20)   │                           │
│  └─────────────┘ └─────────────┘                           │
├─────────────────────────────────────────────────────────────┤
│                    Storage (IPFS/Arweave)                   │
│                    (Replay video evidence)                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Smart Contract Specifications

### 2.1 MarshalRegistry.sol

**Purpose**: Manage Marshal authorization, vouching, revocation, and rate limits.

**State Variables**:
```solidity
mapping(address => bool) public isMarshal;
mapping(address => bool) public isGenesisKey;
mapping(address => address[]) public vouchesReceived;
mapping(address => mapping(address => bool)) public hasVouched;
uint256 public constant VOUCHES_REQUIRED = 3;

// Rate limiting
struct RateLimit {
    uint64 windowSeconds;
    uint32 maxRuns;
}
mapping(bytes32 => RateLimit) public rateLimits;
mapping(address => mapping(bytes32 => mapping(uint64 => uint32))) public runCounts;
```

**Functions**:
```solidity
function initializeGenesis(address[] calldata genesisKeys) external onlyOwner;
function vouch(address candidate) external onlyMarshal;
function revokeVouch(address candidate) external onlyMarshal;
function revokeMarshal(address marshal) external onlyGenesisKey;
function getMarshalStatus(address account) external view returns (bool);

// Rate limiting
function setRateLimit(bytes32 trialId, uint64 windowSeconds, uint32 maxRuns) external onlyOwner;
function recordRun(address marshal, bytes32 trialId) external onlyPoPW returns (bool);
function checkRateLimit(address marshal, bytes32 trialId) external view returns (bool);
```

**Events**:
```solidity
event GenesisKeyAdded(address indexed marshal);
event MarshalVouched(address indexed voucher, address indexed candidate);
event VouchRevoked(address indexed voucher, address indexed candidate);
event MarshalAdmitted(address indexed marshal);
event MarshalRevoked(address indexed marshal, address indexed revokedBy);
event RateLimitSet(bytes32 indexed trialId, uint64 windowSeconds, uint32 maxRuns);
```

---

### 2.2 TrialsRegistry.sol

**Purpose**: Store and manage versioned Trial definitions.

**State Variables**:
```solidity
struct TrialVersion {
    bytes32 metadataHash;
    bool ladderEligible;
    uint256 createdAt;
}

struct Trial {
    bytes32 id;
    address architect;
    uint32 latestVersion;
    uint256 royaltyBps;
    uint256 baseFee;
    bool active;
}

mapping(bytes32 => Trial) public trials;
mapping(bytes32 => mapping(uint32 => TrialVersion)) public versions;
bytes32[] public trialIds;
```

**Functions**:
```solidity
function createTrial(
    bytes32 metadataHash,
    uint256 royaltyBps,
    uint256 baseFee
) external returns (bytes32 trialId);

function addVersion(
    bytes32 trialId,
    bytes32 metadataHash
) external returns (uint32 version);

function setLadderEligible(
    bytes32 trialId,
    uint32 version,
    bool eligible
) external onlyOwner;

function deactivateTrial(bytes32 trialId) external;
function getTrial(bytes32 trialId) external view returns (Trial memory);
function getVersion(bytes32 trialId, uint32 version) external view returns (TrialVersion memory);
```

**Events**:
```solidity
event TrialRegistered(bytes32 indexed id, address indexed architect, bytes32 metadataHash);
event VersionAdded(bytes32 indexed trialId, uint32 version, bytes32 metadataHash);
event LadderEligibilitySet(bytes32 indexed trialId, uint32 version, bool eligible);
event TrialDeactivated(bytes32 indexed id);
```

---

### 2.3 PoPW.sol

**Purpose**: Core Record submission and Badge minting with nonce/deadline validation and Replay enforcement.

**State Variables**:
```solidity
struct Record {
    bytes32 trialId;
    uint32 version;
    address contender;
    address marshal;
    uint8 result;          // PASS=1, NO_PASS=0
    uint64 timestamp;
    uint64 nonce;
    uint64 deadline;
    bytes32 toolId;        // Optional; 0x0 if unused
    bytes32 replayHash;    // Required for PASS; 0x0 allowed for NO_PASS
    string replayRef;      // Required for PASS; empty allowed for NO_PASS
}

uint8 public constant PASS = 1;
uint8 public constant NO_PASS = 0;

mapping(address => uint64) public nonces;
mapping(bytes32 => bool) public recordSubmitted;
mapping(address => mapping(bytes32 => mapping(uint32 => bool))) public hasPassed;

IMarshalRegistry public marshalRegistry;
ITrialsRegistry public trialsRegistry;
IBadge public badge;
IEC public ecToken;
```

**Functions**:
```solidity
function submitRecord(
    Record calldata record,
    bytes calldata contenderSig,
    bytes calldata marshalSig
) external returns (uint256 tokenId);

function verifySignatures(
    Record calldata record,
    bytes calldata contenderSig,
    bytes calldata marshalSig
) public view returns (bool);

function getRecordHash(Record calldata record) public pure returns (bytes32);
function getCurrentNonce(address contender) external view returns (uint64);
```

**Validation Logic**:
```solidity
function submitRecord(...) external returns (uint256 tokenId) {
    // 1. Verify deadline not expired
    require(block.timestamp <= record.deadline, "Deadline expired");

    // 2. Verify nonce matches expected
    require(record.nonce == nonces[record.contender], "Invalid nonce");

    // 3. Verify marshal is authorized (at submission time)
    require(marshalRegistry.isMarshal(record.marshal), "Not authorized");

    // 4. Check rate limits
    require(marshalRegistry.recordRun(record.marshal, record.trialId), "Rate limit exceeded");

    // 5. Verify signatures
    require(verifySignatures(record, contenderSig, marshalSig), "Invalid signatures");

    // 6. Increment nonce
    nonces[record.contender]++;

    // 7. Store record hash
    bytes32 recordHash = getRecordHash(record);
    recordSubmitted[recordHash] = true;

    // 8. Handle result
    if (record.result == PASS) {
        // Check one PASS per (contender, trialId, version)
        require(!hasPassed[record.contender][record.trialId][record.version], "Already passed");
        hasPassed[record.contender][record.trialId][record.version] = true;

        // REPLAY REQUIREMENT: replayHash and replayRef MUST be present for PASS
        require(record.replayHash != bytes32(0), "Replay hash required for PASS");
        require(bytes(record.replayRef).length > 0, "Replay ref required for PASS");

        // Mint Badge (linked to Replay)
        tokenId = badge.mint(record.contender, record.trialId, record.version, record.marshal, record.replayHash);

        // Distribute fees (architect royalty on PASS only)
        _distributeFees(record.trialId, record.marshal, true);
    } else {
        // NO_PASS: record Run, no Badge
        // replayHash and replayRef may be 0x0/empty for NO_PASS
        tokenId = 0;

        // Marshal still gets fee for Run
        _distributeFees(record.trialId, record.marshal, false);
    }

    emit RecordSubmitted(recordHash, record.contender, record.marshal, record.trialId, record.version, record.result, record.replayHash);
    if (record.result == PASS) {
        emit BadgeMinted(tokenId, record.contender, record.trialId, record.version, record.replayHash);
    }
}
```

**Events**:
```solidity
event RecordSubmitted(
    bytes32 indexed recordHash,
    address indexed contender,
    address indexed marshal,
    bytes32 trialId,
    uint32 version,
    uint8 result,
    bytes32 replayHash
);
event BadgeMinted(
    uint256 indexed tokenId,
    address indexed contender,
    bytes32 indexed trialId,
    uint32 version,
    bytes32 replayHash
);
```

**EIP-712 Domain**:
```solidity
bytes32 constant DOMAIN_TYPEHASH = keccak256(
    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
);

// Domain: name="PoPW", version="1"
```

**EIP-712 Record Type**:
```solidity
bytes32 constant RECORD_TYPEHASH = keccak256(
    "Record(bytes32 trialId,uint32 version,address contender,address marshal,uint8 result,uint64 timestamp,uint64 nonce,uint64 deadline,bytes32 toolId,bytes32 replayHash,string replayRef)"
);
```

---

### 2.4 Badge.sol

**Purpose**: Non-transferable Soul Bound Token for credentials, linked to Replay. Does not expire (v1).

**Inheritance**: ERC-721 with transfer restrictions.

**State Variables**:
```solidity
struct TokenData {
    bytes32 trialId;
    uint32 version;
    address marshal;
    bytes32 replayHash;    // Hash of Replay video
    uint256 earnedAt;
}

mapping(uint256 => TokenData) public tokenData;
uint256 private _tokenIdCounter;
```

**Functions**:
```solidity
function mint(
    address to,
    bytes32 trialId,
    uint32 version,
    address marshal,
    bytes32 replayHash
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
    Record: [
        { name: "trialId", type: "bytes32" },
        { name: "version", type: "uint32" },
        { name: "contender", type: "address" },
        { name: "marshal", type: "address" },
        { name: "result", type: "uint8" },
        { name: "timestamp", type: "uint64" },
        { name: "nonce", type: "uint64" },
        { name: "deadline", type: "uint64" },
        { name: "toolId", type: "bytes32" },
        { name: "replayHash", type: "bytes32" },
        { name: "replayRef", type: "string" }
    ]
};
```

### 3.2 Verification Flow

1. Verify deadline has not expired
2. Verify nonce matches Contender's current nonce
3. Reconstruct Record hash using EIP-712
4. Recover signer from Contender signature
5. Verify recovered address matches `record.contender`
6. Recover signer from Marshal signature
7. Verify recovered address matches `record.marshal`
8. Verify Marshal is authorized at submission time via MarshalRegistry
9. **For PASS**: verify `replayHash` and `replayRef` are present

---

## 4. Fee Distribution

### 4.1 Flow

```
Contender pays (baseFee in $EC or approved fee assets)
         │
         ├──► Architect royalty (PASS only)
         ├──► Marshal reward (per Run)
         └──► Protocol ops
```

### 4.2 Implementation

```solidity
function _distributeFees(bytes32 trialId, address marshal, bool isPass) internal {
    Trial memory trial = trialsRegistry.getTrial(trialId);
    uint256 fee = trial.baseFee;

    // Marshal gets reward per Run
    uint256 marshalShare = (fee * MARSHAL_BPS) / 10000;
    ecToken.transfer(marshal, marshalShare);

    if (isPass) {
        // Architect royalty only on PASS
        uint256 architectShare = (fee * trial.royaltyBps) / 10000;
        ecToken.transfer(trial.architect, architectShare);

        uint256 treasuryShare = fee - marshalShare - architectShare;
        ecToken.transfer(treasury, treasuryShare);
    } else {
        // NO_PASS: remaining goes to treasury
        uint256 treasuryShare = fee - marshalShare;
        ecToken.transfer(treasury, treasuryShare);
    }
}
```

---

## 5. Replay (Video Evidence)

### 5.1 Replay Requirement

**v1.0.17**: Replay is **required** for PASS / Badge issuance.

- Every minted Badge is linked to a Replay (video evidence of the Run)
- Contract enforces `replayHash` and `replayRef` are non-empty for PASS
- NO_PASS Records may omit Replay (0x0 / empty allowed)

### 5.2 Off-Chain Storage

Replay files stored on IPFS or Arweave:
- Video recordings of Runs
- Metadata

Media stays off-chain; on-chain stores only hash/pointer.

### 5.3 On-Chain Reference

```solidity
// replayHash = hash of video content (for integrity)
bytes32 replayHash = keccak256(videoBytes);

// replayRef = pointer to off-chain storage (e.g., IPFS CID)
string replayRef = "ipfs://Qm...";
```

Records and Badges reference Replay by hash/pointer.

### 5.4 Privacy & Access Control

Access control (public/unlisted/encrypted) is defined by the Trial and product policy:
- **Public**: Replay accessible to anyone
- **Unlisted**: Replay accessible via direct link only
- **Encrypted**: Replay encrypted, decryption keys managed off-chain

---

## 6. Indexing & Ladders

### 6.1 Subgraph Entities

```graphql
type Marshal @entity {
  id: ID!
  address: Bytes!
  isGenesis: Boolean!
  isActive: Boolean!
  vouches: [Vouch!]! @derivedFrom(field: "voucher")
  runs: [Run!]! @derivedFrom(field: "marshal")
  totalRuns: BigInt!
}

type Trial @entity {
  id: ID!
  architect: Bytes!
  latestVersion: Int!
  versions: [TrialVersion!]! @derivedFrom(field: "trial")
  runs: [Run!]! @derivedFrom(field: "trial")
  totalRuns: BigInt!
}

type TrialVersion @entity {
  id: ID!
  trial: Trial!
  version: Int!
  metadataHash: Bytes!
  ladderEligible: Boolean!
  createdAt: BigInt!
}

type Run @entity {
  id: ID!
  contender: Bytes!
  marshal: Marshal!
  trial: Trial!
  version: Int!
  tokenId: BigInt
  replayHash: Bytes!
  replayRef: String!
  result: Int!
  timestamp: BigInt!
}
```

### 6.2 Ladders

Per Trial version: rank verified PASS by the Trial's Ladder rule.

Ladders apply only to versions marked `ladderEligible`.

Anomalous Marshal–Contender concentration may be excluded from Ladder eligibility (monitoring).

---

## 7. Security Considerations

### 7.1 Replay Protection
- Record includes nonce (per Contender)
- Record includes deadline (expiry)
- Used Records tracked in mapping

### 7.2 Signature Malleability
- Use OpenZeppelin ECDSA library
- Reject malleable signatures

### 7.3 Access Control
- Only PoPW can mint Badges
- Only owner can initialize genesis keys
- Only Marshals can vouch
- Only Genesis Keys can revoke Marshals (v1 safety valve)
- Rate limits enforced per Marshal per Trial per time window

### 7.4 Authorization Timing
- Marshal authorization checked at submission time
- A revoked Marshal cannot submit new Records

### 7.5 Replay Enforcement
- PASS requires non-empty `replayHash` and `replayRef`
- Contract enforces this at submission time
- Prevents missing-evidence disputes

---

## 8. Gas Optimization

- Pack structs efficiently (uint32, uint64, uint8 together)
- Use bytes32 for IDs
- Batch operations where possible
- Minimize storage writes
- replayRef stored as event data (not in storage) where possible

---

## 9. Upgrade Path

Contracts designed for minimal upgradeability:
- Registry contracts: Proxy pattern (optional)
- Badge: Immutable
- EC: Immutable
- PoPW: Versioned deployments

---

## 10. Required Events (v1)

| Event | Contract |
|-------|----------|
| TrialRegistered | TrialsRegistry |
| MarshalVouched | MarshalRegistry |
| MarshalRevoked | MarshalRegistry |
| RecordSubmitted | PoPW |
| BadgeMinted | PoPW |

---

*Technical Specification v1.0.17 — January 2026*
