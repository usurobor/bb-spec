# Genesis Certification Session — Live Demo Script (v0.1)
## Single-Leg Balance Hold — 60s (SLB v1)

### Setup (2 minutes)
- Prover opens app → selects SLB v1 → session checklist loads
- Certifier confirms they are authorized in-app (registry check)
- Tool check: Prover shows board marking / model or tolerance reference (per Standard)
- Environment check: camera frames full body + tool; stable surface shown
- Evidence consent: confirm whether recording will occur (Standard-defined; mutual consent)

### Attempt (1 minute + buffer)
- Certifier starts live observation and confirms "ready"
- Prover begins hold
- Certifier may request a camera adjustment if view is compromised
- Certifier calls "time" at 60 seconds

### Outcome + Attestation (30 seconds)
- Certifier declares PASS or NO PASS based on Standard pass rule
- App generates one EIP-712 attestation message with:
  standardId/version, prover, certifier, result, timestamp, nonce, deadline
  (optional toolId/evidenceHash if used)
- Prover signs → Certifier signs → app submits on-chain

### Result (instant)
- If PASS: BBT minted to prover wallet; leaderboard updated (if SLB v1 is eligible)
- If NO PASS: attempt recorded; no BBT; prover may retry later

### Closing (30 seconds)
- Prover sees credential page (BBT) or attempt history
- Certifier sees session log and earnings summary
