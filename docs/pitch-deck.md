# Embodied Coherence
## Proof of Physical Work (PoPW) — v0.7 Investor Pitch Deck (Spec-aligned to v1.0.16)

> **Legend:** 🧾 Standard • 👤 Prover • 🧑‍⚖️ Certifier • 🏷️ BBT • ⛓️ On-chain • 🏆 Leaderboard • ✅ PASS • ⛔ NO PASS

---

## 1) 🎯 One-line + wedge
A protocol that issues non-transferable credentials for physical achievements—starting with **grip + balance benchmarks** run by partner gyms and coaches—creating **portable proof and credible leaderboards** under shared 🧾 Standards.

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
- **Fast sessions:** short attempts, clear pass rules
- **Normal workflow:** coaching + judging already happens live
- **Clear buyer:** gyms/coaches can offer certified benchmarks as a session/event; members pay for portable proof

---

## 4) 🧩 The solution
PoPW provides a shared credential rail for physical tests:
- 🧾 **Standards:** versioned definitions of tests (tool + rules + 🏆 semantics)
- 👀 **Live certification:** an authorized 🧑‍⚖️ Certifier verifies an attempt under live observation
- ⛓️ **Publicly verifiable record:** minimal on-chain attestation of ✅/⛔ outcome
- 🏷️ **Credential:** ✅ PASS mints a Bodybound Token (BBT) to the 👤 Prover

PoPW is not a marketplace for judging—it is a **shared standards and credential rail** that many certifiers and apps can use.

---

## 5) 📱 Product experience (what a session looks like)
`🧾 Select → 👀 Observe → ✍️ Co-sign → ⛓️ Submit → 🏷️ Credential + 🏆 Leaderboard`

- App shows a session checklist from the 🧾 Standard (tool check, camera checks, evidence rules)
- 🧑‍⚖️ Certifier observes live (co-located or video)
- 👤 Prover + 🧑‍⚖️ Certifier sign one shared attestation (2-of-2)
- 2-tap signing + auto-submission (EIP-712 under the hood)
- ✅ PASS mints 🏷️ BBT; ⛔ NO PASS records the attempt

---

## 6) 🧪 Example Standard (serious, repeatable)
**Single-Leg Balance Hold — 60s (🧾 standardId SLB, version 1)**
- **Tool spec:** defined balance board geometry (model or tolerances); official or verified-to-spec
- **Setup checks:** show tool ID/marking; show surface; show footwear rule (barefoot/shoes) per 🧾 Standard
- **Camera:** continuous view of full body + tool for full attempt
- **Task:** hold single-leg stance for 60s under defined posture constraints
- **Pass rule:** no support contact; no stepping off; no prohibited bracing
- **🏆 Leaderboard rule:** rank by duration (≥60s counts as ✅ PASS; longer durations rank higher if allowed)
- **Evidence:** recording defined per Standard; if recorded, stored off-chain by consent (hash/pointer allowed)

Versioning example: **v2** may tighten camera placement or prohibited bracing without rewriting **v1** history.

---

## 7) 🔗 Why a chain (vs a database)
PoPW uses a chain to provide:
- A neutral registry of 🧾 Standard IDs + versions
- ⛓️ Attestations that are publicly verifiable and non-repudiable (both parties signed)
- Portability across apps and communities (anyone can read the credential graph)
- Auditable history of standards and attestations
- A durable record not tied to one operator's database

---

## 8) 🛡️ Trust model (v1): integrity-first
PoPW v1 is permissioned to prioritize signal quality.

**🧑‍⚖️ Certifier authorization**
- **Phase 1 (Genesis):** only Genesis Keys certify (**multisig**, with published signers recommended)
- **Phase 2 (Expansion):** new Certifier after **3 on-chain vouches**
- **Revocation:** Genesis Keys may revoke (v1 safety valve)

**Controls**
- Rate limits per certifier / standard / time window
- Monitoring: anomalous certifier–prover concentration may be excluded from 🏆 leaderboards
- 🏆 Leaderboard eligibility is a standards-registry flag (credentials still exist)
- Onboarding playbooks + periodic review of certifier activity patterns

---

## 9) ✅🛡️ Integrity v1: prevent / deter / defer
| Category | Status in v1 |
|---|---|
| Replay / signature reuse | Prevented (EIP-712 + nonce + deadline) |
| Unauthorized certification | Prevented (registry-gated; checked at submission) |
| Silent standard changes | Prevented (immutable versions) |
| Farming throughput | Deterred (rate limits) |
| Collusion / bribery | Mitigated / detectable for 🏆 leaderboards (permissioning + monitoring + eligibility) |
| Disputes / slashing / courts | Deferred (out of scope v1) |
| Anonymous proving / "one human" identity | Deferred (out of scope v1) |

---

## 10) 💸 Economics (one coherent example)
Fees are priced in USD-equivalent and paid in protocol-approved assets (v1 supports $EC; stable assets can be added as approved fee assets).

**Illustrative example**
- **Attempt fee: $10** (covers live labor)
  - $7 🧑‍⚖️ Certifier reward (per attempt)
  - $3 Protocol ops
- **✅ PASS mint fee: $5** (funds issuance + creator royalties)
  - $3 Creator royalty (PASS only)
  - $2 Protocol ops

---

## 11) 🚀 Go-to-market (bootstrapping the network)
**Genesis**
- Founders run certification sessions with partner gyms/coaches
- Publish initial 🧾 Standard catalog and mark a small set as 🏆 leaderboard-eligible

**Expansion**
- 🧑‍⚖️ Certifier supply grows via 3-vouch admission
- 🧾 Standards spread through creators who want portable benchmarks
- Loop: attempts → 🏷️ credential → sharing → new members → more sessions

---

## 12) 🧭 Competitive landscape (positioning)
| Option | Verification | Portability | Standardization | Composability |
|---|---:|---:|---:|---:|
| Platform leaderboards (Web2) | Varies | Low | Mixed | Low |
| Local certifications (gyms/orgs) | High | Low | Medium | Low |
| Attendance badges (POAP-like) | Medium (presence varies) | High | N/A | Medium |
| PoPW (Embodied Coherence) | High (authorized live certifier) | High | High (versioned) | High |

---

## 13) 🏰 Defensibility
- 🧾 **Standards network effects:** common standardId/version becomes the shared benchmark
- 🧑‍⚖️ **Certifier network:** coverage + admission rules + reputation over time
- 🛡️ **Integrity controls:** 🏆 eligibility + monitoring + rate limits
- 🧬 **Standards lineage + credential graph:** shared public reference dataset that others build on

---

## 14) 🗺️ Roadmap (measurable)
**v1 ship**
- Contracts implemented + tested
- Testnet deployment
- Audit
- Mobile certification app (session checklist + signing + submission)

**Pilot targets (first 6–12 months)**
- 10–20 partner gyms/coaches
- 20–50 active 🧑‍⚖️ certifiers (scales with partner density; playbooks + monitoring)
- 5–10 🏆 leaderboard-eligible 🧾 Standard versions
- 10k–50k attempts recorded (mix of ✅/⛔)

---

## 15) 🧱 Readiness (what exists now)
- Protocol spec: v1.0.16 complete (registries + EIP-712 schema + integrity controls)
- Monorepo plan defined (contracts / app / standards / docs)
- Standard format defined: versioned metadata pointer/hash; 🏆 leaderboard eligibility flag
- Genesis plan defined: partner gym sessions + certifier onboarding workflow

---

## 16) 🤝 Ask + end-of-runway goal
**Seed round (target): $2.5M** for ~18 months runway to reach:
- Audited v1 + mobile app shipped
- 10–20 gym pilots live
- 20–50 active 🧑‍⚖️ certifiers
- 5–10 🏆 leaderboard-eligible 🧾 Standard versions
- 10k–50k attempts recorded

Contact: `/bodybound` • `/docs`
