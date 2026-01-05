# Genesis Certification Session — Live Demo Script (v0.2)
## Slack Board Balance — 60s (slack-board-1m v1)

> **Legend:** 🧾 Trial • 🧱 Spec • 👤 Contender • 🛡️ Marshal • 🏷️ Badge • 🎥 Replay • ⛓️ On-chain • 🏆 Ladder • ✅ PASS • ⛔ NO PASS

### Setup (2 minutes)
- 👤 Contender opens app → selects 🧾 slack-board-1m v1 → session checklist loads
- 🛡️ Marshal confirms they are authorized in-app (registry check)
- Tool check: 👤 Contender shows slack board specs (70-90cm board, 10-15cm cylinder fulcrum per Trial 🧱 spec)
- Environment check: camera frames full body + board + fulcrum; stable, non-slip surface shown
- 🎥 Recording setup: 👤 Contender starts recording (required for ✅ PASS)
- Evidence consent: confirm recording is active (Trial-defined; mutual consent)

### Run (1 minute + buffer)
- 🛡️ Marshal starts live observation and confirms "ready"
- 👤 Contender begins balance hold with both feet on board (🎥 recording in progress)
- 🛡️ Marshal may request a camera adjustment if view is compromised
- 🛡️ Marshal calls "time" at 60 seconds

### Outcome + Record (30 seconds)
- 🛡️ Marshal declares ✅ PASS or ⛔ NO PASS based on Trial pass rule (no ground touch, no external support, no stepping off)
- 👤 Contender uploads 🎥 Replay → receives replayHash + replayRef
- App generates one EIP-712 Record message with:
  trialId/version, contender, marshal, result, timestamp, nonce, deadline,
  replayHash, replayRef (required for ✅ PASS)
- 👤 Contender signs → 🛡️ Marshal signs → app submits ⛓️ on-chain

### Result (instant)
- If ✅ PASS: 🏷️ Badge minted to 👤 Contender wallet (linked to 🎥 Replay); 🏆 Ladder updated (if slack-board-1m v1 is eligible)
- If ⛔ NO PASS: Run recorded; no Badge; 👤 Contender may retry later

### Closing (30 seconds)
- 👤 Contender sees credential page (🏷️ Badge + 🎥 Replay link) or Run history
- 🛡️ Marshal sees session log and earnings summary
