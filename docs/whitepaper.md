# Embodied Coherence (v1.0.15)
## Proof of Physical Work (PoPW)

---

## Goal

Issue durable, non-transferable credentials for physical achievements verified by authorized Certifiers under shared Standards.

---

## Motivation

- Portable proof of achievement.
- Comparable results under shared rules.

---

## Primitives

| Primitive | Description |
|-----------|-------------|
| **Standard** (standardId, version) | Tool spec, task, evidence requirements, pass rule, leaderboard rule |
| **Attestation** | 2-of-2 signed attempt record (Prover + Certifier), PASS / NO PASS |
| **Bodybound Token (BBT)** | Non-transferable SBT credential minted on PASS; does not expire (v1) |
| **$EC** | Fee / governance token |

---

## Roles

| Role | Description |
|------|-------------|
| **Creator** | Registers Standards; earns royalty per PASS mint |
| **Prover** | Attempts; pays fee |
| **Certifier** | Authorized; observes live; co-signs; earns fee |
| **Genesis Keys** | Initial Certifiers; manage Certifier set in v1 |

---

## Registries (v1)

### Standards Registry
- Stores: creator, (standardId, version), metadata pointer/hash.
- Versions are immutable.
- Registry may mark a Standard version "leaderboard-eligible".

### Certifier Registry
- **Phase 1 (Genesis)**: Only Genesis Keys certify.
- **Phase 2 (Expansion)**: Candidate becomes Certifier after 3 distinct Certifiers vouch on-chain.
- **Revocation**: Genesis Keys may revoke Certifier status (v1 safety valve).
- **Limits**: Registry may enforce rate limits per Certifier per Standard per time window.

---

## Live Observation

Co-located or live audio-video. Certifier may request camera/tool checks. Evidence follows the Standard.

---

## Flow

1. Prover selects a Standard version and a tool matching its spec.
2. Prover performs under live observation.
3. Prover + Certifier sign one attestation in the app.
4. Attestation submitted on-chain.
   - **PASS**: mint BBT.
   - **NO PASS**: record attempt; no BBT.

---

## Attestation Schema (EIP-712)

**Domain**: `name="PoPW"`, `version="1"`, `chainId`, `verifyingContract`.

**Message fields**:
| Field | Description |
|-------|-------------|
| `standardId` | Standard identifier |
| `version` | Standard version |
| `prover` | Prover address |
| `certifier` | Certifier address |
| `result` | PASS=1, NO_PASS=0 |
| `timestamp` | Attempt timestamp |
| `nonce` | Per-prover nonce |
| `deadline` | Signature expiry |
| `toolId` | Optional; 0x0 if unused |
| `evidenceHash` | Optional; 0x0 if unused |

---

## Authorization Timing (v1)

Certifier authorization is checked at submission time.

---

## On-chain (minimum)

Standard ID + version, Prover, Certifier, timestamp, PASS / NO PASS.

**Optional**: toolId, evidence hash/pointer (off-chain).

---

## Economics

Fees are paid in $EC or other protocol-approved fee assets.

Fee split: certifier reward, creator royalty (PASS only), protocol ops.

*(Default: certifier reward applies per attempt.)*

---

## Leaderboards

Per Standard: rank verified PASS by the Standard leaderboard rule.

Leaderboards apply to versions marked leaderboard-eligible.

---

## Privacy & Safety (v1)

Recording is defined by the Standard and requires mutual consent.

Media stays off-chain; attestations may reference media by hash/pointer.

---

## Contract Requirements (v1)

| Contract | Requirement |
|----------|-------------|
| **Certifier Registry** | Phases, vouching, revocation, rate limits |
| **Standards Registry** | Creator + versioned metadata pointer/hash + leaderboard eligibility flag |
| **Attest + Mint** | Verifies EIP-712 signatures, nonces, deadlines, registry authorization; records attestation; mints BBT on PASS |
| **BBT** | Transfers and approvals disabled |

**Default**: one PASS per (prover, standardId, version).

---

## Out of Scope (v1)

Trustless verification; anonymous proving; automated fraud detection; decentralized disputes; credential revocation.

---

## Future

Multi-certifier attestations, staking, dispute flags, automated evidence checks.

---

## Precedents

GTO badges; WoW soulbound; POAP.

---

*Version 1.0.15*
