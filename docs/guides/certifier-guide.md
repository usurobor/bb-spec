# Certifier Guide
## Verifying Physical Achievements

---

## Overview

As a **Certifier**, you verify that Provers have genuinely completed physical achievements. Your attestations enable the minting of Body Bound Tokens (BBTs).

---

## Becoming a Certifier

### Path 1: Genesis Key

Genesis Certifiers are established at protocol launch:
- Selected for demonstrated expertise
- Community standing
- Bootstrap the trust network

### Path 2: 3-Vouch Admission

New Certifiers join via vouching:

1. **Build Reputation**: Demonstrate expertise in your domain
2. **Connect**: Engage with existing Certifiers
3. **Request Vouches**: Ask 3 Certifiers to vouch for you
4. **Automatic Admission**: Once 3 vouches received, you're in

```javascript
// Check your vouch status
const vouches = await certifierRegistry.vouchesReceived(yourAddress);
console.log(`Vouches: ${vouches.length}/3`);
```

---

## Certifier Responsibilities

### Core Duties

1. **Honest Verification**: Only certify genuine achievements
2. **Thorough Review**: Check all Standard requirements
3. **Timely Response**: Respond to Prover requests promptly
4. **Quality Evidence**: Ensure evidence meets standards

### Reputation

Your reputation is tracked:
- Total certifications
- Certifications per Standard
- Community standing

Poor performance affects:
- Vouch weight
- Prover trust
- Potential future staking/slashing

---

## Certification Process

### Step 1: Receive Request

Provers will contact you with:
- Standard they're attempting
- Evidence (video, photos, data)
- Any relevant context

### Step 2: Review Standard

Verify you understand the requirements:

```javascript
const standard = await standardsRegistry.getStandard(standardId);
const metadataURI = standard.metadataURI;
// Fetch and review full requirements from IPFS
```

### Step 3: Examine Evidence

Check that evidence shows:
- [ ] Achievement completed as specified
- [ ] Duration requirements met
- [ ] Equipment matches specifications
- [ ] Continuous recording (no edits)
- [ ] All required angles/views present

### Step 4: Make Decision

**Approve** if:
- All requirements clearly met
- Evidence is unambiguous
- No signs of manipulation

**Reject** if:
- Requirements not met
- Evidence insufficient
- Concerns about authenticity

### Step 5: Sign Attestation

If approving:

```javascript
const attestation = {
  prover: proverAddress,
  certifier: yourAddress,
  standardId: standardId,
  evidenceHash: keccak256(evidenceCID),
  timestamp: Math.floor(Date.now() / 1000),
  score: calculateScore(evidence) // if applicable
};

// Sign using EIP-712
const signature = await signer.signTypedData(domain, types, attestation);
```

### Step 6: Return to Prover

Send the Prover:
- Signed attestation data
- Your signature
- Any feedback

---

## Verification Guidelines

### Video Evidence

**Check for:**
- Continuous footage (no jump cuts)
- Clear view of achievement
- Timer/clock visible
- Equipment specifications met
- No signs of editing/manipulation

**Red Flags:**
- Cuts or transitions
- Obscured key moments
- Inconsistent lighting/shadows
- Audio/video sync issues

### Equipment Verification

- Visible measurements/specifications
- Matches Standard requirements
- Proper setup and safety

### Duration Verification

- Clear start and end points
- Visible timer or reference
- Meets minimum requirements

---

## Scoring (When Applicable)

Some Standards include scoring:

```json
{
  "scoring": {
    "type": "duration",
    "unit": "seconds",
    "min_pass": 60,
    "max_score": 300
  }
}
```

Calculate and include accurate scores in attestations.

---

## Vouching for New Certifiers

As a Certifier, you can vouch for candidates:

```javascript
await certifierRegistry.vouch(candidateAddress);
```

### Vouching Guidelines

**Vouch for candidates who:**
- Have demonstrated expertise
- Show integrity and reliability
- Understand the protocol
- Will uphold standards

**Don't vouch for:**
- Unknown individuals
- Those with conflicts of interest
- Candidates you can't verify

### Revoking Vouches

If circumstances change:

```javascript
await certifierRegistry.revokeVouch(candidateAddress);
```

---

## Economics

### Earning Fees

Per certification, you receive:

```
Certifier Share = Base Fee × Certifier BPS / 10000
```

Typical range: 50-70% of base fee.

### Example

Standard with 100 $EC base fee, 60% certifier share:
```
100 × 6000 / 10000 = 60 $EC per certification
```

---

## Best Practices

### Be Thorough
- Review all requirements before certifying
- Don't rush verifications
- Ask for additional evidence if needed

### Be Fair
- Apply standards consistently
- Don't favor certain Provers
- Judge evidence objectively

### Be Professional
- Respond promptly
- Communicate clearly
- Provide constructive feedback on rejections

### Be Honest
- Never certify unverified achievements
- Report suspicious activity
- Maintain protocol integrity

---

## Common Scenarios

### Borderline Cases

When achievement is close but unclear:
1. Request additional evidence
2. Ask for specific clarification
3. Default to not certifying if uncertain

### Disputes

If Prover disagrees with rejection:
1. Explain specific requirement not met
2. Offer to review additional evidence
3. Suggest they try again with better documentation

### Technical Issues

If evidence has technical problems:
1. Request re-upload
2. Suggest evidence capture improvements
3. Be patient with technical difficulties

---

## Tools & Resources

### Verification Tools
- Video analysis software
- Measurement verification
- Timestamp checking

### References
- Standard definitions: `/standards/`
- Technical spec: `/docs/technical-spec.md`
- Schema reference: `/standards/schema.json`

---

## Support

- Protocol documentation: `/docs/`
- Community channels: [TBD]
- Technical support: [TBD]

---

*Certifier Guide v1.0*
