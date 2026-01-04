# Genesis Certification Session — Live Demo Script (v0.1)
## Single-Leg Balance Hold — 60s (SLB v1)

> **Legend:** 🧾 Trial • 👤 Contender • 🧑‍⚖️ Marshal • 🏷️ Badge • ⛓️ On-chain • 🏆 Ladder • ✅ PASS • ⛔ NO PASS

### Setup (2 minutes)
- 👤 Contender opens app → selects 🧾 SLB v1 → session checklist loads
- 🧑‍⚖️ Marshal confirms they are authorized in-app (registry check)
- Tool check: 👤 Contender shows board marking / model or tolerance reference (per Trial)
- Environment check: camera frames full body + tool; stable surface shown
- Evidence consent: confirm whether recording will occur (Trial-defined; mutual consent)

### Run (1 minute + buffer)
- 🧑‍⚖️ Marshal starts live observation and confirms "ready"
- 👤 Contender begins hold
- 🧑‍⚖️ Marshal may request a camera adjustment if view is compromised
- 🧑‍⚖️ Marshal calls "time" at 60 seconds

### Outcome + Record (30 seconds)
- 🧑‍⚖️ Marshal declares ✅ PASS or ⛔ NO PASS based on Trial pass rule
- App generates one EIP-712 Record message with:
  trialId/version, contender, marshal, result, timestamp, nonce, deadline
  (optional toolId/evidenceHash if used)
- 👤 Contender signs → 🧑‍⚖️ Marshal signs → app submits ⛓️ on-chain

### Result (instant)
- If ✅ PASS: 🏷️ Badge minted to 👤 Contender wallet; 🏆 Ladder updated (if SLB v1 is eligible)
- If ⛔ NO PASS: Run recorded; no Badge; 👤 Contender may retry later

### Closing (30 seconds)
- 👤 Contender sees credential page (🏷️ Badge) or Run history
- 🧑‍⚖️ Marshal sees session log and earnings summary
