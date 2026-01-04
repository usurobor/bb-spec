# Changelog

All notable changes to the Embodied Coherence protocol.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

---

## [1.0.16] - 2026-01-04

### Protocol Spec (Whitepaper)
- Certifier Registry: added monitoring note (anomalous Certifier–Prover concentration excluded from leaderboards)
- Flow: restored step 5 (Leaderboards rank verified PASS per Standard)
- Economics: clarified certifier reward is per attempt
- Contract Requirements: added required events list (StandardRegistered, CertifierVouched, CertifierRevoked, AttestationRecorded, BBTMinted)

---

## [1.0.15] - 2026-01-04

### Protocol Spec (Whitepaper)
- New "Registries (v1)" section with Standards Registry and Certifier Registry details
- Standards Registry: versioned standards, immutable versions, leaderboard-eligible flag
- Certifier Registry: rate limits per Certifier per Standard per time window
- New "Attestation Schema (EIP-712)" section with full field spec
- Attestation fields: standardId, version, prover, certifier, result, timestamp, nonce, deadline, toolId, evidenceHash
- New "Authorization Timing (v1)" section
- New "Privacy & Safety (v1)" section
- Economics: fees in $EC or protocol-approved assets; creator royalty on PASS only
- Default: one PASS per (prover, standardId, version)

### Contracts
- Attestation.sol — Full EIP-712 schema with nonce, deadline, result, version
- StandardsRegistry.sol — Versioned standards with leaderboard eligibility
- CertifierRegistry.sol — Rate limits per Certifier/Standard/window
- PoPW.sol — Nonce tracking, deadline validation, NO_PASS recording

---

## [1.0.14] - 2026-01-04

### Protocol Spec (Whitepaper)
- Standard now includes evidence requirements
- BBT: does not expire (v1)
- $EC: fee assets may expand
- Genesis Keys: manage Certifier set (not just admission)
- Added Certifier revocation: Genesis Keys may revoke (v1 safety valve)
- Evidence follows the Standard
- Flow step 5: Leaderboards rank verified PASS per Standard
- Added "Out of Scope (v1)" section
- Added "Future" section

### Contracts
- CertifierRegistry.sol — Added revocation by Genesis Keys

---

## [1.0.13] - 2026-01-04

### Protocol Spec (Whitepaper)
- Converged whitepaper after Bohmian dialogue iteration
- Defined: Goal, Motivation, Primitives, Roles, Certifier Authorization, Flow, On-chain fields, Economics, Leaderboards, Contract Requirements, Precedents
- Certifier authorization: Genesis Keys → 3-vouch expansion
- BBT: non-transferable (SBT)
- $EC: fee/governance token

### Contracts (Scaffolded)
- CertifierRegistry.sol — Genesis + 3-vouch admission
- StandardsRegistry.sol — Standard definitions + royalty params
- PoPW.sol — Attest + Mint wiring
- BBT.sol — non-transferable SBT placeholder
- EC.sol — ERC-20 placeholder

### Standards (v1)
- sadhu-board-1m.json
- heavy-cup.json
- slack-board-1m.json
- lotus-wheels-1m.json

---

## [Unreleased]

### TODO
- [ ] Leaderboard indexing
- [ ] Frontend certification flow
