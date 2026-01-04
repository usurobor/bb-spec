# Embodied Coherence
## Proof of Physical Work (PoPW) — v0.2 Pitch Deck (Spec-aligned to v1.0.16)

---

## 1) One-line
A protocol that issues non-transferable credentials for physical achievements verified by authorized certifiers under shared standards.

---

## 2) Why now
- Physical achievement is hard to verify and compare across contexts.
- Most records are platform-bound and not portable.
- Standards and lineages are fragmented.

---

## 3) What PoPW does
PoPW provides:
- **Standards**: versioned definitions of tests (tool + rules + leaderboard semantics)
- **Live certification**: an authorized certifier observes an attempt live
- **On-chain record**: minimal, durable attestation of the outcome
- **Credential minting**: PASS mints a non-transferable token to the prover

---

## 4) Core objects (terms used consistently)
- **Standard (standardId, version)**: tool spec, task, evidence requirements, pass rule, leaderboard rule
- **Attestation**: 2-of-2 signed attempt record (Prover + Certifier), PASS / NO PASS
- **BBT (SBT)**: non-transferable credential minted on PASS; does not expire in v1
- **$EC**: fee / governance token (fee assets may expand)

---

## 5) Roles
- **Creator**: registers standards; earns royalty per PASS mint
- **Prover**: attempts; pays fee
- **Certifier**: authorized; observes live; co-signs; earns fee
- **Genesis Keys**: initial certifiers; manage certifier set in v1

---

## 6) How it works (per attempt)
`1) Select Standard → 2) Observe Live → 3) Co-sign → 4) On-chain → 5) Leaderboard`

1. Prover selects **(standardId, version)** and uses a tool matching the spec
2. Prover performs under **live observation** (co-located or video)
3. Prover + Certifier co-sign one attestation (2-of-2)
4. Attestation recorded on-chain
   - **PASS**: mint BBT
   - **NO PASS**: record attempt; no BBT
5. Leaderboards rank **verified PASS** per standard (eligible versions only)

---

## 7) Trust model (v1)
PoPW v1 is **permissioned** by design.

**Certifier authorization**
- **Phase 1 (Genesis):** only Genesis Keys certify
- **Phase 2 (Expansion):** candidate becomes certifier after **3 on-chain vouches**
- **Revocation:** Genesis Keys may revoke certifier status (v1 safety valve)

**Integrity controls**
- Rate limits: per certifier, per standard, per time window
- Monitoring: anomalous certifier–prover concentration may be excluded from leaderboards
- Leaderboard eligibility is an explicit standards-registry flag

---

## 8) Technical highlights (v1)
**Attestation (EIP-712)**
- Domain separation + nonce + deadline
- One canonical message signed by both parties

**Authorization timing**
- Certifier authorization checked at **submission time**

**Data minimization**
- On-chain: standardId+version, prover, certifier, timestamp, PASS/NO PASS
- Optional: toolId, evidence hash/pointer (off-chain)

**Credential behavior**
- BBT is non-transferable (transfers + approvals disabled)
- Default: one PASS per (prover, standardId, version)

---

## 9) Standards and leaderboards
**Standards Registry (v1)**
- Stores creator + versioned metadata pointer/hash
- Versions immutable
- Registry may mark a version **leaderboard-eligible**

**Leaderboards**
- Per standard version: rank verified PASS by the standard's leaderboard rule
  (examples: time, reps, load class)

---

## 10) Privacy & safety baseline (v1)
- Recording is defined by the standard and requires **mutual consent**
- Media stays **off-chain**
- Attestation may reference media by hash/pointer

---

## 11) Economics (v1)
Fees (in $EC or other protocol-approved fee assets) split to:
- **Certifier reward** (default: per attempt)
- **Creator royalty** (PASS only)
- **Protocol ops**

*(Exact splits are parameters; not part of the core protocol definition.)*

---

## 12) What PoPW v1 is (and is not)
**PoPW v1 is:**
- A live-observed, registry-gated credential issuance protocol
- Standards-driven, versioned, auditable, minimal on-chain

**PoPW v1 is not:**
- Trustless / fully decentralized verification
- Anonymous proving (no "one human = one identity" in v1)
- A dispute court or decentralized adjudication system
- Automated fraud detection or sensor-based proof
- A revocable credential system (BBTs do not expire in v1)

---

## 13) Implementation modules (monorepo view)
- **Certifier Registry**: phases, vouching, revocation, rate limits
- **Standards Registry**: versioned metadata + leaderboard eligibility
- **Attest + Mint (PoPW)**: signature checks, nonces, deadlines, authorization gate, mint on PASS
- **BBT**: non-transferable token
- **Client app**: session checklist + signing flow + submission

---

## 14) Rollout plan
**Phase 1: Genesis**
- Founders operate as certifiers
- Publish initial standards and run certification sessions

**Phase 2: Expansion**
- Admit certifiers via 3-vouch rule
- Turn on rate limits and leaderboard eligibility curation

**Phase 3: Hardening**
- Monitoring + anomaly handling for leaderboards
- Add multi-certifier options for select standards (future versions)

---

## 15) Roadmap
**Now (v1.0.16)**
- Protocol spec complete
- Contract architecture defined

**Next**
- Implement + test contracts (Foundry)
- Testnet deployment
- Security audit
- Certification app (mobile-first)

**Future**
- Multi-certifier attestations
- Staking + dispute flags
- Automated evidence checks (assistive)

---

## 16) The ask
Seed to ship v1:
- Contract implementation + audit
- App development
- Genesis certifier operations + onboarding

---

## 17) Links
Repo: `/bodybound`
Docs: `/docs`
