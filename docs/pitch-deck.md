# Embodied Coherence
## Proof of Physical Work (PoPW) — v0.8 Investor Pitch Deck (Spec-aligned to v1.0.17)

> **Legend:** 🧾 Trial • 🧱 Spec • 👤 Contender • 🛡️ Marshal • 🏷️ Badge • 🎥 Replay • ⛓️ On-chain • 🏆 Ladder • ✅ PASS • ⛔ NO PASS

---

## 1) 🎯 One-line + wedge
A protocol that issues non-transferable credentials for physical achievements—starting with **grip + balance benchmarks** run by partner gyms and coaches—creating **portable proof and credible rankings** under shared 🧾 Trials.

---

## 2) 🧱 The problem
Physical achievement is high-signal but hard to reuse outside the room.
- Results are hard to compare across gyms because tools and rules differ
- Verification is local (coach / gym / community) and not portable
- Platforms can change policies, rankings, and history (even when acting in good faith)

---

## 3) 🧭 Why this wedge wins first (and who pays)
Grip + balance benchmarks fit live certification and have a clear buyer.
- **Low equipment variance:** tools can be specified tightly
- **Fast sessions:** short Runs, clear pass rules
- **Normal workflow:** coaching + judging already happens live
- **Clear buyer:** gyms/coaches can offer certified benchmarks as a session/event; members pay for portable proof

---

## 4) 🧩 The solution
PoPW provides a shared credential rail for physical tests:
- 🧾 **Trials:** versioned definitions of tests (tool 🧱 spec + rules + 🏆 semantics)
- 🎥 **Replay:** video evidence required for every ✅ PASS (off-chain, hash on-chain)
- 👀 **Live certification:** an authorized 🛡️ Marshal verifies a Run under live observation
- ⛓️ **Publicly verifiable Record:** minimal on-chain attestation of ✅/⛔ outcome
- 🏷️ **Credential:** ✅ PASS mints a Badge linked to the 🎥 Replay

PoPW is not a marketplace for judging—it is a **shared Trials and credential rail** that many Marshals and apps can use.

---

## 5) 📱 Product experience (what a Run looks like)
`🧾 Select Trial → 🎥 Record → 👀 Live Run → ✍️ Co-sign Record → ⛓️ Submit → 🏷️ Badge + 🏆 Ladder`

- App shows a session checklist from the 🧾 Trial (tool check, camera checks, evidence rules)
- 👤 Contender records the Run (🎥 required for ✅ PASS)
- 🛡️ Marshal observes live (co-located or video)
- 👤 Contender + 🛡️ Marshal sign one shared Record (2-of-2) with 🎥 replayHash
- 2-tap signing + auto-submission (EIP-712 under the hood)
- ✅ PASS mints 🏷️ Badge linked to 🎥 Replay; ⛔ NO PASS records the Run

---

## 6) 🧪 Example Trial (serious, repeatable)
**Single-Leg Balance Hold — 60s (🧾 trialId SLB, version 1)**
- **Tool 🧱 spec:** defined balance board geometry (model or tolerances); official or verified-to-spec
- **Setup checks:** show tool ID/marking; show surface; show footwear rule (barefoot/shoes) per 🧾 Trial
- **Camera:** continuous view of full body + tool for full Run
- **Task:** hold single-leg stance for 60s under defined posture constraints
- **Pass rule:** no support contact; no stepping off; no prohibited bracing
- **🏆 Ladder rule:** rank by duration (≥60s counts as ✅ PASS; longer durations rank higher if allowed)
- **🎥 Replay:** required for ✅ PASS; stored off-chain; hash/pointer on-chain

Versioning example: **v2** may tighten camera placement or prohibited bracing without rewriting **v1** history.

---

## 7) 🔗 Why a chain (vs a database)
PoPW uses a chain to provide:
- A neutral registry of 🧾 Trial IDs + versions
- ⛓️ Records that are publicly verifiable and non-repudiable (both parties signed)
- Portability across apps and communities (anyone can read the credential graph)
- Auditable history of Trials and Records
- A durable record not tied to one operator's database

---

## 8) 🛡️ Trust model (v1): integrity-first
PoPW v1 is permissioned to prioritize signal quality.

**🛡️ Marshal authorization**
- **Phase 1 (Genesis):** only Genesis Keys certify (**multisig**, with published signers recommended)
- **Phase 2 (Expansion):** new Marshal after **3 on-chain vouches**
- **Revocation:** Genesis Keys may revoke (v1 safety valve)

**Controls**
- Rate limits per Marshal / Trial / time window
- Monitoring: anomalous Marshal–Contender concentration may be excluded from 🏆 Ladders
- 🏆 Ladder eligibility is a Trial-registry flag (credentials still exist)
- Onboarding playbooks + periodic review of Marshal activity patterns

---

## 9) ✅🛡️ Integrity v1: prevent / deter / defer
| Category | Status in v1 |
|---|---|
| Replay / signature reuse | Prevented (EIP-712 + nonce + deadline) |
| Unauthorized certification | Prevented (registry-gated; checked at submission) |
| Silent Trial changes | Prevented (immutable versions) |
| Missing evidence | Prevented (🎥 Replay required for ✅ PASS) |
| Farming throughput | Deterred (rate limits) |
| Collusion / bribery | Mitigated / detectable for 🏆 Ladders (permissioning + monitoring + eligibility) |
| Disputes / slashing / courts | Deferred (out of scope v1) |
| Anonymous proving / "one human" identity | Deferred (out of scope v1) |

---

## 10) 💸 Economics (one coherent example)
Fees are priced in USD-equivalent and paid in protocol-approved assets (v1 supports $EC; stable assets can be added as approved fee assets).

**Illustrative example**
- **Run fee: $10** (covers live labor)
  - $7 🛡️ Marshal reward (per Run)
  - $3 Protocol ops
- **✅ PASS mint fee: $5** (funds issuance + Architect royalties)
  - $3 Architect royalty (PASS only)
  - $2 Protocol ops

---

## 11) 🚀 Go-to-market (bootstrapping the network)
**Genesis**
- Founders run certification sessions with partner gyms/coaches
- Publish initial 🧾 Trial catalog and mark a small set as 🏆 Ladder-eligible

**Expansion**
- 🛡️ Marshal supply grows via 3-vouch admission
- 🧾 Trials spread through Architects who want portable benchmarks
- Loop: Runs → 🏷️ Badge → sharing → new members → more sessions

---

## 12) 🧭 Competitive landscape (positioning)
| Option | Verification | Portability | Standardization | Composability |
|---|---:|---:|---:|---:|
| Platform leaderboards (Web2) | Varies | Low | Mixed | Low |
| Local certifications (gyms/orgs) | High | Low | Medium | Low |
| Attendance badges (POAP-like) | Medium (presence varies) | High | N/A | Medium |
| PoPW (Embodied Coherence) | High (authorized live Marshal + 🎥 Replay) | High | High (versioned) | High |

---

## 13) 🏰 Defensibility
- 🧾 **Trials network effects:** common trialId/version becomes the shared benchmark
- 🛡️ **Marshal network:** coverage + admission rules + reputation over time
- 🎥 **Replay requirement:** every ✅ PASS has verifiable video evidence
- 🛡️ **Integrity controls:** 🏆 eligibility + monitoring + rate limits
- 🧬 **Trials lineage + credential graph:** shared public reference dataset that others build on

---

## 14) 🗺️ Roadmap (measurable)
**v1 ship**
- Contracts implemented + tested
- Testnet deployment
- Audit
- Mobile certification app (session checklist + signing + submission)

**Pilot targets (first 6–12 months)**
- 10–20 partner gyms/coaches
- 20–50 active 🛡️ Marshals (scales with partner density; playbooks + monitoring)
- 5–10 🏆 Ladder-eligible 🧾 Trial versions
- 10k–50k Runs recorded (mix of ✅/⛔)

---

## 15) 🧱 Readiness (what exists now)
- Protocol spec: v1.0.17 complete (registries + EIP-712 schema + integrity controls + 🎥 Replay requirement)
- Monorepo plan defined (contracts / app / trials / docs)
- Trial format defined: versioned metadata pointer/hash; 🏆 Ladder eligibility flag
- Genesis plan defined: partner gym sessions + Marshal onboarding workflow

---

## 16) 🤝 Ask + end-of-runway goal
**Seed round (target): $2.5M** for ~18 months runway to reach:
- Audited v1 + mobile app shipped
- 10–20 gym pilots live
- 20–50 active 🛡️ Marshals
- 5–10 🏆 Ladder-eligible 🧾 Trial versions
- 10k–50k Runs recorded

Contact: `/bodybound` • `/docs`
