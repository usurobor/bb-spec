# Embodied Coherence (v1.0.17)
## Proof of Physical Work (PoPW)

---

## Goal

Issue durable, non-transferable badges for physical achievements verified by authorized marshals under shared, versioned trials, with a required video replay for every minted badge.

---

## Primitives

| Primitive | Description |
|-----------|-------------|
| **Trial** (trialId, version) | Tool spec, task, evidence requirements, pass rule, ladder rule |
| **Record** | 2-of-2 signed run record (Contender + Marshal), PASS / NO PASS |
| **Badge** | Non-transferable credential minted on PASS; linked to the PASS record and its replay |
| **Replay** | Off-chain video evidence referenced by hash/pointer in the record |
| **$EC** | Fee / governance token (fee assets may expand) |

---

## Roles

| Role | Description |
|------|-------------|
| **Architect** | Registers trials; earns royalty per PASS mint |
| **Contender** | Attempts a run; pays fees |
| **Marshal** | Authorized; observes live; co-signs; earns fees |
| **Genesis Keys** | Initial marshal set; manage marshal registry in v1 |

---

## Registries (v1)

### Trial Registry
- Stores: architect, (trialId, version), metadata pointer/hash.
- Versions are immutable.
- Registry may mark a trial version "ladder-eligible".

### Marshal Registry
- **Phase 1 (Genesis)**: Only Genesis Keys marshal.
- **Phase 2 (Expansion)**: Candidate becomes marshal after 3 distinct marshals vouch on-chain.
- **Revocation**: Genesis Keys may revoke marshal status (v1 safety valve).
- **Limits**: Registry may enforce rate limits per marshal per trial per time window.
- **Monitoring**: Anomalous marshal–contender concentration may be excluded from ladder eligibility.

---

## Live Observation

Co-located or live audio-video. Marshal may request camera/tool checks. Evidence requirements follow the trial.

---

## Flow

1. Contender selects a trial version and tool matching its spec.
2. Contender records the run and performs under live observation.
3. Contender + marshal sign one record (2-of-2).
4. Record submitted on-chain.
   - **PASS**: requires replay reference; mint badge.
   - **NO PASS**: record attempt; no badge.
5. Ladders rank verified PASS per ladder-eligible trial version.

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
| `replayHash` | Required for PASS; 0x0 allowed for NO_PASS |
| `replayRef` | Required for PASS; empty allowed for NO_PASS |

---

## Authorization Timing (v1)

Marshal authorization is checked at submission time.

---

## On-chain (minimum)

Trial ID + version, Contender, Marshal, timestamp, PASS / NO PASS.

**For PASS**: `replayHash` + `replayRef` MUST be present (stored or emitted for indexing).

---

## Economics

Fees priced USD-equivalent and paid in protocol-approved assets.

Fee split: marshal reward (per attempt), architect royalty (PASS only), protocol ops.

---

## Ladders

Per trial version: rank verified PASS by the trial's ladder rule.

Ladders apply to versions marked ladder-eligible.

---

## Privacy & Safety (v1)

- Replay is required for PASS badge issuance.
- Media stays off-chain; on-chain stores only hash/pointer.
- Access control (public/unlisted/encrypted) is defined by the trial and product policy.

---

## Contract Requirements (v1)

| Contract | Requirement |
|----------|-------------|
| **Marshal Registry** | Phases, vouching, revocation, rate limits |
| **Trial Registry** | Architect + versioned metadata pointer/hash + ladder eligibility flag |
| **Record + Mint** | Verifies EIP-712 signatures, nonces, deadlines, registry authorization; records result; enforces replay requirement on PASS; mints badge on PASS |
| **Badge** | Transfers and approvals disabled |

**Default**: one PASS badge per (contender, trialId, version).

**Events**: TrialRegistered, MarshalVouched, MarshalRevoked, RecordSubmitted, BadgeMinted.

---

## Out of Scope (v1)

Trustless verification; anonymous proving; automated fraud detection; decentralized disputes; badge revocation.

---

## Future

Multi-marshal records, staking, dispute flags, automated evidence checks.

---

*Version 1.0.17*
