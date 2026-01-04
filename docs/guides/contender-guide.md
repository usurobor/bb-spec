# Contender Guide
## Earning Badges for Physical Achievements (v1.0.16)

> **Vocabulary:** Architect (defines Trials) • Contender (attempts) • Marshal (observes) • Trial (the test) • Run (one attempt) • Record (signed attestation) • Badge (credential) • Ladder (rankings)

---

## Overview

As a **Contender**, you perform physical feats under **live observation** and receive verifiable on-chain credentials. Your achievements are recorded as non-transferable Badges on PASS, or as Run records on NO PASS.

---

## Getting Started

### Prerequisites

1. **Wallet**: Ethereum-compatible wallet (MetaMask, Rainbow, etc.)
2. **$EC Tokens**: For Run fees
3. **Evidence Capture**: Camera/phone for live observation recording

---

## Certification Flow

```
🧾 Select Trial → 👀 Live Run → ✍️ Co-sign Record → ⛓️ Submit → 🏷️ Badge + 🏆 Ladder
```

---

## Step 1: Select a Trial

Browse available Trials in the registry:

```javascript
// Get a Trial by ID and version
const trial = await trialsRegistry.getTrial(trialId);
const version = await trialsRegistry.getVersion(trialId, versionNum);
```

Consider:
- **Trial version**: Select a specific (trialId, version)
- **Requirements**: Ensure you have matching equipment (tool spec)
- **Fee**: Check the Run cost
- **Ladder eligibility**: Check if version is eligible for rankings

---

## Step 2: Live Observation

Runs require **live observation** by an authorized Marshal.

### Observation Methods
- **Co-located**: Marshal present in person
- **Live video**: Real-time audio-video call

### Recording Requirements
Recording is defined by the Trial and requires **mutual consent**.

Evidence requirements typically include:
- Continuous video (no cuts)
- Clear view of the activity
- Visible timer/clock
- Equipment detail matching tool spec
- Full body visible throughout

---

## Step 3: Perform the Run

### During Live Observation

1. **Start recording** before you begin
2. **Show setup**: Capture equipment details matching Trial spec
3. **Stay in frame**: Full body visible throughout
4. **Include timer**: Visible countdown/stopwatch
5. **Continue after**: Record a few seconds past completion

### Evidence Quality

Good evidence should:
- Be continuous (no edits)
- Clearly show the achievement
- Meet all Trial requirements
- Be high enough quality to verify

---

## Step 4: Co-sign Record

After the Run, you and the Marshal co-sign one Record (2-of-2):

```javascript
const record = {
  trialId: trialId,
  version: trialVersion,
  contender: yourAddress,
  marshal: marshalAddress,
  result: 1,  // PASS=1, NO_PASS=0
  timestamp: runTimestamp,
  nonce: await popw.getCurrentNonce(yourAddress),
  deadline: Math.floor(Date.now() / 1000) + 3600, // 1 hour expiry
  toolId: toolId,           // Optional: 0x0 if unused
  evidenceHash: evidenceHash // Optional: 0x0 if unused
};

// Both sign the same EIP-712 message
const domain = {
  name: "PoPW",
  version: "1",
  chainId: chainId,
  verifyingContract: popwAddress
};

const contenderSig = await signer.signTypedData(domain, types, record);
```

---

## Step 5: Submit to Contract

```javascript
const tx = await popw.submitRecord(
  record,
  contenderSig,
  marshalSig
);
```

### Outcomes

**PASS (result=1)**:
- Badge minted to your wallet
- Run recorded on-chain
- Added to Ladder (if version eligible)

**NO PASS (result=0)**:
- Run recorded on-chain
- No Badge minted
- You can try again

---

## Step 6: View Your Badges

```javascript
// Get your credential tokens
const balance = await badge.balanceOf(yourAddress);
const tokenId = await badge.tokenOfOwnerByIndex(yourAddress, 0);
const data = await badge.tokenData(tokenId);
// Returns: { trialId, version, marshal, evidenceHash, earnedAt }
```

### Badge Properties

- **Non-transferable**: Cannot be transferred or sold
- **Does not expire**: Badges do not expire in v1
- **One per version**: Default is one PASS per (contender, trialId, version)

---

## Fees

### Cost Breakdown

Each Run costs the Trial's base fee:

| Recipient | When Paid |
|-----------|-----------|
| Marshal | Per Run (PASS or NO PASS) |
| Architect | PASS only |
| Protocol | Remainder |

### Payment

Fees are paid in $EC tokens (or other approved fee assets):

```javascript
// Approve $EC spending before submission
await ecToken.approve(popwAddress, fee);
```

---

## Ladders

Per Trial version: rank verified PASS by the Trial's Ladder rule (e.g., time, reps, load class).

Only versions marked **Ladder-eligible** appear on Ladders.

---

## Tips for Success

### Preparation
- Practice the achievement multiple times
- Test your recording setup
- Review Trial requirements carefully
- Ensure equipment matches tool spec exactly

### Evidence
- Good lighting
- Stable camera position
- Clear view of all requirements
- Visible timer

### Communication
- Coordinate with Marshal for live observation
- Be responsive during the session
- Ask questions if requirements unclear

---

## Troubleshooting

### "Deadline expired"
- The Record deadline passed before submission
- Request new Record with fresh deadline

### "Invalid nonce"
- Nonce mismatch; get current nonce and re-sign

### "Not authorized"
- Marshal was revoked or not authorized at submission time
- Find an active authorized Marshal

### "Already passed"
- You already have a PASS for this (trialId, version)
- Try a different version or Trial

### "Rate limit exceeded"
- Marshal hit their rate limit for this Trial
- Wait or find another Marshal

---

## Support

- Browse Trials: App interface
- Find Marshals: Ladder
- Technical help: Documentation

---

*Contender Guide v1.0.16*
