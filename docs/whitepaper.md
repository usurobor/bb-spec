# Embodied Coherence (v1.0.14)
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
| **Standard** (ID, version) | Tool spec, task, evidence requirements, pass rule, leaderboard rule |
| **Attestation** | 2-of-2 signed attempt record (Prover + Certifier), PASS / NO PASS |
| **Bodybound Token (BBT)** | Non-transferable SBT credential minted on PASS; does not expire (v1) |
| **$EC** | Fee / governance token (fee assets may expand) |

---

## Roles

| Role | Description |
|------|-------------|
| **Creator** | Registers Standards; earns royalty per PASS mint |
| **Prover** | Attempts; pays fee |
| **Certifier** | Authorized; observes live; co-signs; earns fee |
| **Genesis Keys** | Initial Certifiers; manage Certifier set in v1 |

---

## Certifier Authorization (v1)

- **Phase 1 (Genesis)**: Only Genesis Keys certify.
- **Phase 2 (Expansion)**: Candidate becomes Certifier after 3 distinct Certifiers vouch on-chain.
- **Revocation**: Genesis Keys may revoke Certifier status (v1 safety valve).

---

## Live Observation

Co-located or live audio-video. Certifier may request camera/tool checks. Evidence follows the Standard.

---

## Flow

1. Prover selects a Standard and a tool matching its spec.
2. Prover performs under live observation.
3. Prover + Certifier sign one attestation in the app.
4. Attestation recorded on-chain; PASS mints BBT.
5. Leaderboards rank verified PASS per Standard.

---

## On-chain (minimum)

Standard ID + version, Prover, Certifier, timestamp, PASS / NO PASS.

**Optional**: tool ID, evidence hash/pointer (off-chain).

---

## Economics

$EC fees split: certifier reward, creator royalty, protocol ops.

---

## Leaderboards

Per Standard: rank verified PASS by the Standard leaderboard rule.

---

## Contract Requirements (v1)

| Contract | Requirement |
|----------|-------------|
| **Certifier Registry** | Gates certification; enforces phases, vouches, revocation |
| **Attest + Mint** | Rejects attestations unless Certifier is authorized in registry |
| **Attestation** | One shared message signed by both parties (2-of-2) |
| **BBT** | Blocks transfers and approvals |

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

*Version 1.0.14*
