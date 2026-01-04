# Prover Guide
## Getting Certified for Physical Achievements

---

## Overview

As a **Prover**, you perform physical feats and receive verifiable on-chain certification. Your achievements are recorded as non-transferable Body Bound Tokens (BBTs).

---

## Getting Started

### Prerequisites

1. **Wallet**: Ethereum-compatible wallet (MetaMask, Rainbow, etc.)
2. **$EC Tokens**: For certification fees
3. **Evidence Capture**: Camera/phone for recording

---

## Certification Flow

```
1. Choose Standard → 2. Prepare → 3. Perform & Record → 4. Find Certifier → 5. Submit → 6. Receive BBT
```

---

## Step 1: Choose a Standard

Browse available Standards in the registry:

```javascript
// Get all active standards
const standards = await standardsRegistry.getActiveStandards();
```

Consider:
- **Difficulty**: Match your current ability
- **Requirements**: Ensure you have necessary equipment
- **Fee**: Check the certification cost

---

## Step 2: Prepare

### Review Requirements

Each Standard specifies exact requirements:
- Duration
- Equipment specifications
- Position/form requirements
- Evidence requirements

### Gather Equipment

Ensure all equipment meets Standard specifications:
- Correct dimensions/weights
- Proper setup
- Safety measures

### Set Up Recording

Evidence requirements typically include:
- Continuous video (no cuts)
- Clear view of the activity
- Visible timer/clock
- Equipment detail shots

---

## Step 3: Perform & Record

### Recording Tips

1. **Start early**: Begin recording before you start
2. **Show setup**: Capture equipment details
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

## Step 4: Find a Certifier

### Browse Certifiers

View authorized Certifiers:

```javascript
// Check if address is a certifier
const isAuthorized = await certifierRegistry.isCertifier(certifierAddress);
```

### Considerations

- **Expertise**: Choose Certifiers familiar with your Standard
- **Reputation**: Check certification history
- **Availability**: Confirm they can review your submission

### Contact

Reach out to your chosen Certifier with:
- The Standard you're attempting
- Your evidence (video link)
- Any relevant context

---

## Step 5: Submit Attestation

### Certifier Review

The Certifier will:
1. Review your evidence
2. Verify requirements are met
3. Create and sign the attestation

### Co-Sign

Once the Certifier approves:

```javascript
const attestation = {
  prover: yourAddress,
  certifier: certifierAddress,
  standardId: standardId,
  evidenceHash: evidenceHash,
  timestamp: timestamp,
  score: score
};

// Sign the attestation
const proverSig = await signer.signTypedData(domain, types, attestation);
```

### Submit to Contract

```javascript
const tx = await popw.attest(
  attestation,
  proverSig,
  certifierSig
);
```

---

## Step 6: Receive Your BBT

Upon successful verification:
- BBT minted to your wallet
- Certification recorded on-chain
- Achievement added to your profile

### View Your BBTs

```javascript
// Get your certification tokens
const balance = await bbt.balanceOf(yourAddress);
const tokenId = await bbt.tokenOfOwnerByIndex(yourAddress, 0);
const data = await bbt.tokenData(tokenId);
```

---

## Fees

### Cost Breakdown

Each certification costs the Standard's base fee:

| Recipient | Typical Share |
|-----------|---------------|
| Certifier | 50-70% |
| Creator | 10-30% |
| Protocol | 10-20% |

### Payment

Fees are paid in $EC tokens:

```javascript
// Approve $EC spending
await ecToken.approve(popwAddress, fee);
```

---

## Your BBT Collection

### Properties

Each BBT contains:
- **Standard ID**: What you achieved
- **Certifier**: Who verified it
- **Evidence Hash**: Proof reference
- **Timestamp**: When certified
- **Score**: Performance score (if applicable)

### Non-Transferable

BBTs are Soul Bound Tokens:
- Cannot be transferred
- Cannot be sold
- Can only be burned by you

---

## Tips for Success

### Preparation
- Practice the achievement multiple times
- Test your recording setup
- Review evidence requirements carefully

### Evidence
- Multiple camera angles (if allowed)
- Good lighting
- Clear audio (if relevant)
- Stable camera position

### Communication
- Be responsive with Certifiers
- Provide context when helpful
- Ask questions if requirements unclear

---

## Troubleshooting

### "Certifier signature invalid"
- Ensure Certifier is still authorized
- Check signature matches attestation data

### "Attestation already used"
- Each attestation can only be submitted once
- Request new attestation from Certifier

### "Insufficient $EC balance"
- Acquire more $EC tokens
- Check current fee for Standard

---

## Support

- Browse Standards: App interface
- Find Certifiers: Leaderboard
- Technical help: Documentation

---

*Prover Guide v1.0*
