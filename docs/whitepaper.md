# Embodied Coherence (v1.0.13)
## Proof of Physical Work (PoPW)

---

## Goal

Issue durable, non-transferable credentials for physical achievements verified by authorized Certifiers under shared Standards.

---

## Motivation

- Portable proof of physical achievement.
- Comparable results under common rules.

---

## Primitives

| Primitive | Description |
|-----------|-------------|
| **Standard** (ID, version) | Tool spec, task, pass rule, leaderboard rule |
| **Attestation** | 2-of-2 signed attempt record (Prover + Certifier) |
| **Bodybound Token (BBT)** | Non-transferable SBT credential minted on PASS |
| **$EC** | Fee / governance token |

---

## Roles

| Role | Description |
|------|-------------|
| **Creator** | Registers Standards; earns royalty per mint |
| **Prover** | Attempts; pays fee |
| **Certifier** | Authorized; observes live; co-signs; earns fee |
| **Genesis Keys** | Initial Certifiers; control Certifier admission in v1 |

---

## Certifier Authorization (v1)

- **Phase 1 (Genesis)**: Only Genesis Keys may act as Certifiers.
- **Phase 2 (Expansion)**: Candidate becomes Certifier after 3 distinct Certifiers vouch on-chain.

---

## Live Observation

Co-located or live audio-video. Certifier may request camera/tool checks.

---

## Flow

1. Prover selects a Standard and a tool matching its spec.
2. Prover performs live with a Certifier.
3. Prover + Certifier sign one attestation in the app.
4. Attestation recorded on-chain; PASS mints BBT.

---

## On-chain (minimum)

Standard ID + version, Prover, Certifier, timestamp, PASS / NO PASS.

**Optional**: tool ID, evidence hash/pointer (off-chain).

---

## Economics

$EC fees split: certifier reward, creator royalty, protocol ops.

---

## Leaderboards

Per Standard: rank verified passes by the Standard's leaderboard rule.

---

## Contract Requirements (v1)

| Contract | Requirement |
|----------|-------------|
| **Certifier Registry** | Gates who can certify; enforces Genesis phase + 3-vouch admission |
| **Attest + Mint** | Rejects attestations unless Certifier is authorized in registry |
| **Attestation** | One shared message signed by both parties (2-of-2) |
| **BBT** | Non-transferable (transfers/approvals disabled) |

---

## Precedents

GTO badges; WoW soulbound; POAP.

---

*Version 1.0.13*
