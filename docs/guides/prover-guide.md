# Prover Guide
## Getting Certified for Physical Achievements (v1.0.16)

---

## Overview

As a **Prover**, you perform physical feats under **live observation** and receive verifiable on-chain certification. Your achievements are recorded as non-transferable Body Bound Tokens (BBTs) on PASS, or as attempt records on NO PASS.

---

## Getting Started

### Prerequisites

1. **Wallet**: Ethereum-compatible wallet (MetaMask, Rainbow, etc.)
2. **$EC Tokens**: For certification fees
3. **Evidence Capture**: Camera/phone for live observation recording

---

## Certification Flow

```
1) Select Standard → 2) Observe Live → 3) Co-sign → 4) On-chain → 5) Leaderboard
```

---

## Step 1: Select a Standard

Browse available Standards in the registry:

```javascript
// Get a standard by ID and version
const standard = await standardsRegistry.getStandard(standardId);
const version = await standardsRegistry.getVersion(standardId, versionNum);
```

Consider:
- **Standard version**: Select a specific (standardId, version)
- **Requirements**: Ensure you have matching equipment (tool spec)
- **Fee**: Check the certification cost
- **Leaderboard eligibility**: Check if version is eligible for rankings

---

## Step 2: Live Observation

Certification requires **live observation** by an authorized Certifier.

### Observation Methods
- **Co-located**: Certifier present in person
- **Live video**: Real-time audio-video call

### Recording Requirements
Recording is defined by the Standard and requires **mutual consent**.

Evidence requirements typically include:
- Continuous video (no cuts)
- Clear view of the activity
- Visible timer/clock
- Equipment detail matching tool spec
- Full body visible throughout

---

## Step 3: Perform the Attempt

### During Live Observation

1. **Start recording** before you begin
2. **Show setup**: Capture equipment details matching Standard spec
3. **Stay in frame**: Full body visible throughout
4. **Include timer**: Visible countdown/stopwatch
5. **Continue after**: Record a few seconds past completion

### Evidence Quality

Good evidence should:
- Be continuous (no edits)
- Clearly show the achievement
- Meet all Standard requirements
- Be high enough quality to verify

---

## Step 4: Co-sign Attestation

After the attempt, you and the Certifier co-sign one attestation (2-of-2):

```javascript
const attestation = {
  standardId: standardId,
  version: standardVersion,
  prover: yourAddress,
  certifier: certifierAddress,
  result: 1,  // PASS=1, NO_PASS=0
  timestamp: attemptTimestamp,
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

const proverSig = await signer.signTypedData(domain, types, attestation);
```

---

## Step 5: Submit to Contract

```javascript
const tx = await popw.attest(
  attestation,
  proverSig,
  certifierSig
);
```

### Outcomes

**PASS (result=1)**:
- BBT minted to your wallet
- Certification recorded on-chain
- Added to leaderboard (if version eligible)

**NO PASS (result=0)**:
- Attempt recorded on-chain
- No BBT minted
- You can try again

---

## Step 6: View Your BBTs

```javascript
// Get your certification tokens
const balance = await bbt.balanceOf(yourAddress);
const tokenId = await bbt.tokenOfOwnerByIndex(yourAddress, 0);
const data = await bbt.tokenData(tokenId);
// Returns: { standardId, version, certifier, evidenceHash, certifiedAt }
```

### BBT Properties

- **Non-transferable**: Cannot be transferred or sold
- **Does not expire**: BBTs do not expire in v1
- **One per version**: Default is one PASS per (prover, standardId, version)

---

## Fees

### Cost Breakdown

Each attempt costs the Standard's base fee:

| Recipient | When Paid |
|-----------|-----------|
| Certifier | Per attempt (PASS or NO PASS) |
| Creator | PASS only |
| Protocol | Remainder |

### Payment

Fees are paid in $EC tokens (or other approved fee assets):

```javascript
// Approve $EC spending before attestation
await ecToken.approve(popwAddress, fee);
```

---

## Leaderboards

Per Standard version: rank verified PASS by the Standard's leaderboard rule (e.g., time, reps, load class).

Only versions marked **leaderboard-eligible** appear on leaderboards.

---

## Tips for Success

### Preparation
- Practice the achievement multiple times
- Test your recording setup
- Review Standard requirements carefully
- Ensure equipment matches tool spec exactly

### Evidence
- Good lighting
- Stable camera position
- Clear view of all requirements
- Visible timer

### Communication
- Coordinate with Certifier for live observation
- Be responsive during the session
- Ask questions if requirements unclear

---

## Troubleshooting

### "Deadline expired"
- The attestation deadline passed before submission
- Request new attestation with fresh deadline

### "Invalid nonce"
- Nonce mismatch; get current nonce and re-sign

### "Not authorized"
- Certifier was revoked or not authorized at submission time
- Find an active authorized Certifier

### "Already passed"
- You already have a PASS for this (standardId, version)
- Try a different version or standard

### "Rate limit exceeded"
- Certifier hit their rate limit for this standard
- Wait or find another Certifier

---

## Support

- Browse Standards: App interface
- Find Certifiers: Leaderboard
- Technical help: Documentation

---

*Prover Guide v1.0.16*
