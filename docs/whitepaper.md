# Embodied Coherence Protocol
## Whitepaper v1.0

---

## Abstract

Embodied Coherence is a decentralized protocol for certifying physical achievements through Proof-of-Physical-Work (PoPW). The protocol enables trust propagation from established practitioners to emerging ones, creating verifiable on-chain records of embodied accomplishments via non-transferable Soul Bound Tokens.

---

## 1. Goal

Create a permissionless, trust-minimized system for certifying physical achievements that:
- Preserves the integrity of embodied practice lineages
- Provides verifiable, non-transferable proof of accomplishment
- Incentivizes quality certification through economic alignment

---

## 2. Motivation

Physical mastery—whether in martial arts, yoga, athletics, or craftsmanship—has historically relied on in-person verification and lineage-based trust. This creates:
- **Fragmentation**: No universal verification standard
- **Fraud**: Easy to claim false credentials
- **Gatekeeping**: Centralized certification bodies with misaligned incentives

Embodied Coherence addresses these by creating an open, verifiable certification layer.

---

## 3. Primitives

### 3.1 Body Bound Token (BBT)
- Non-transferable ERC-721 (Soul Bound Token)
- Represents a certified physical achievement
- Linked to a specific Standard and Certifier

### 3.2 $EC Token
- ERC-20 fee and governance token
- Used for certification fees
- Governs protocol parameters

### 3.3 Standard
- JSON definition of a certifiable achievement
- Includes: name, description, requirements, evidence schema, royalty parameters
- Versioned and immutable once published

### 3.4 Attestation
- EIP-712 typed data structure
- Co-signed by Prover and Certifier
- Contains: standard ID, evidence hash, timestamp, scores

---

## 4. Roles

### 4.1 Creator
- Defines certification Standards
- Sets royalty parameters
- Receives royalties on certifications using their Standard

### 4.2 Prover
- Performs physical feats
- Submits evidence
- Requests certification from Certifiers
- Receives BBT upon successful certification

### 4.3 Certifier
- Authorized to verify physical achievements
- Co-signs attestations with Provers
- Earns fees for certifications
- Reputation tracked via leaderboards

---

## 5. Certifier Authorization

### 5.1 Genesis Keys
Initial set of trusted Certifiers established at protocol launch:
- Selected for demonstrated expertise and community standing
- Bootstrap trust network
- Can vouch for new Certifiers

### 5.2 3-Vouch Expansion
New Certifiers admitted via vouching:
- Requires 3 existing Certifier vouches
- Vouchers stake reputation
- Creates web-of-trust expansion

---

## 6. Certification Flow

```
1. Prover selects Standard
2. Prover performs feat with evidence capture
3. Prover requests certification from Certifier
4. Certifier reviews evidence
5. Certifier signs attestation
6. Prover co-signs attestation
7. Submit to PoPW contract
8. BBT minted to Prover
9. Fees distributed ($EC)
```

---

## 7. On-Chain Fields

### Attestation Structure
```solidity
struct Attestation {
    address prover;
    address certifier;
    bytes32 standardId;
    bytes32 evidenceHash;
    uint256 timestamp;
    uint256 score;
    bytes proverSig;
    bytes certifierSig;
}
```

### BBT Metadata
- Standard ID
- Certifier address
- Certification timestamp
- Evidence pointer (IPFS/Arweave)
- Score (if applicable)

---

## 8. Economics

### 8.1 Fee Structure
- Base certification fee: Set per Standard
- Distribution:
  - Creator royalty: 10-30% (set by Creator)
  - Certifier fee: 50-70%
  - Protocol treasury: 10-20%

### 8.2 $EC Utility
- Pay certification fees
- Governance voting
- Certifier staking (future)

---

## 9. Leaderboards

Track and display:
- Top Certifiers by certification count
- Top Certifiers by Standard
- Top Provers by achievement count
- Standard popularity rankings

Indexed off-chain, verifiable on-chain.

---

## 10. Contract Requirements

### CertifierRegistry.sol
- Genesis key initialization
- 3-vouch admission logic
- Certifier status tracking

### StandardsRegistry.sol
- Standard creation and storage
- Royalty parameter management
- Version tracking

### PoPW.sol
- Attestation verification
- 2-of-2 signature validation
- BBT minting trigger
- Fee distribution

### BBT.sol
- ERC-721 with transfer restrictions
- Metadata storage
- Burn capability (self-only)

### EC.sol
- Standard ERC-20
- Initial distribution
- Governance integration (future)

---

## 11. Precedents

- **EAS (Ethereum Attestation Service)**: Attestation patterns
- **Lens Protocol**: Social graph primitives
- **Gitcoin Passport**: Sybil resistance via stamps
- **POAP**: Event attendance tokens

---

## 12. Future Work

- Multi-certifier requirements for advanced Standards
- Certifier staking and slashing
- Cross-chain certification bridging
- DAO governance implementation
- Mobile evidence capture SDK

---

## Appendix A: Standard Schema

See `/standards/schema.json` for the full JSON schema definition.

---

*Version 1.0 — January 2026*
