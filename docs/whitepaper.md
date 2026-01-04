# Embodied Coherence (v1.0.16)
## Proof of Physical Work (PoPW)

---

## Goal

Issue durable, non-transferable credentials for physical achievements verified by authorized Marshals under shared Trials.

---

## Motivation

- Portable proof of achievement.
- Comparable results under shared rules.

---

## Primitives

| Primitive | Description |
|-----------|-------------|
| **Trial** (trialId, version) | Tool spec, task, evidence requirements, pass rule, Ladder rule |
| **Record** | 2-of-2 signed Run record (Contender + Marshal), PASS / NO PASS |
| **Badge** | Non-transferable SBT credential minted on PASS; does not expire (v1) |
| **$EC** | Fee / governance token |

---

## Roles

| Role | Description |
|------|-------------|
| **Architect** | Defines Trials; earns royalty per PASS mint |
| **Contender** | Attempts Runs; pays fee |
| **Marshal** | Authorized; observes live; co-signs; earns fee |
| **Genesis Keys** | Initial Marshals; manage Marshal set in v1 |

---

## Registries (v1)

### Trials Registry
- Stores: architect, (trialId, version), metadata pointer/hash.
- Versions are immutable.
- Registry may mark a Trial version "Ladder-eligible".

### Marshal Registry
- **Phase 1 (Genesis)**: Only Genesis Keys certify.
- **Phase 2 (Expansion)**: Candidate becomes Marshal after 3 distinct Marshals vouch on-chain.
- **Revocation**: Genesis Keys may revoke Marshal status (v1 safety valve).
- **Limits**: Registry may enforce rate limits per Marshal per Trial per time window.
- **Monitoring**: Anomalous Marshal–Contender concentration may be excluded from Ladder eligibility.

---

## Live Observation

Co-located or live audio-video. Marshal may request camera/tool checks. Evidence follows the Trial.

---

## Flow

1. Contender selects a Trial version and a tool matching its spec.
2. Contender performs Run under live observation.
3. Contender + Marshal sign one Record in the app.
4. Record submitted on-chain.
   - **PASS**: mint Badge.
   - **NO PASS**: record Run; no Badge.
5. Ladders rank verified PASS per Trial.

---

## Record Schema (EIP-712)

**Domain**: `name="PoPW"`, `version="1"`, `chainId`, `verifyingContract`.

**Message fields**:
| Field | Description |
|-------|-------------|
| `trialId` | Trial identifier |
| `version` | Trial version |
| `contender` | Contender address |
| `marshal` | Marshal address |
| `result` | PASS=1, NO_PASS=0 |
| `timestamp` | Run timestamp |
| `nonce` | Per-contender nonce |
| `deadline` | Signature expiry |
| `toolId` | Optional; 0x0 if unused |
| `evidenceHash` | Optional; 0x0 if unused |

---

## Authorization Timing (v1)

Marshal authorization is checked at submission time.

---

## On-chain (minimum)

Trial ID + version, Contender, Marshal, timestamp, PASS / NO PASS.

**Optional**: toolId, evidence hash/pointer (off-chain).

---

## Economics

Fees are paid in $EC or other protocol-approved fee assets.

Fee split: Marshal reward (per Run), Architect royalty (PASS only), protocol ops.

---

## Ladders

Per Trial: rank verified PASS by the Trial's Ladder rule.

Ladders apply to versions marked Ladder-eligible.

---

## Privacy & Safety (v1)

Recording is defined by the Trial and requires mutual consent.

Media stays off-chain; Records may reference media by hash/pointer.

---

## Contract Requirements (v1)

| Contract | Requirement |
|----------|-------------|
| **Marshal Registry** | Phases, vouching, revocation, rate limits |
| **Trials Registry** | Architect + versioned metadata pointer/hash + Ladder eligibility flag |
| **Attest + Mint** | Verifies EIP-712 signatures, nonces, deadlines, registry authorization; records Run; mints Badge on PASS |
| **Badge** | Transfers and approvals disabled |

**Default**: one PASS per (contender, trialId, version).

**Events**: TrialRegistered, MarshalVouched, MarshalRevoked, RecordSubmitted, BadgeMinted.

---

## Out of Scope (v1)

Trustless verification; anonymous proving; automated fraud detection; decentralized disputes; credential revocation.

---

## Future

Multi-marshal Records, staking, dispute flags, automated evidence checks.

---

## Precedents

GTO badges; WoW soulbound; POAP.

---

*Version 1.0.16*
