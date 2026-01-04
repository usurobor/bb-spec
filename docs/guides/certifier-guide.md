# Certifier Guide
## Verifying Physical Achievements (v1.0.16)

---

## Overview

As a **Certifier**, you verify that Provers have genuinely completed physical achievements through **live observation**. Your attestations enable the minting of Body Bound Tokens (BBTs) on PASS.

---

## Becoming a Certifier

### Phase 1: Genesis Key

Genesis Certifiers are established at protocol launch:
- Selected for demonstrated expertise
- Community standing
- Bootstrap the trust network
- Can revoke other Certifiers (v1 safety valve)

### Phase 2: 3-Vouch Admission

New Certifiers join via vouching:

1. **Build Reputation**: Demonstrate expertise in your domain
2. **Connect**: Engage with existing Certifiers
3. **Receive Vouches**: Get **3 distinct Certifiers** to vouch for you on-chain
4. **Automatic Admission**: Once 3 vouches received, you're in

```javascript
// Check your vouch status
const vouches = await certifierRegistry.vouchesReceived(yourAddress);
console.log(`Vouches: ${vouches.length}/3`);
```

---

## Certifier Responsibilities

### Core Duties

1. **Live Observation**: Observe attempts in real-time (co-located or video)
2. **Honest Verification**: Only certify genuine achievements
3. **Thorough Review**: Check all Standard requirements
4. **Timely Response**: Respond to Prover requests promptly
5. **Maintain Integrity**: Uphold protocol standards

### Revocation (v1 Safety Valve)

Genesis Keys may revoke Certifier status:

```javascript
// Only Genesis Keys can call this
await certifierRegistry.revokeCertifier(certifierAddress);
```

A revoked Certifier cannot submit new attestations.

---

## Rate Limits

The registry may enforce rate limits per Certifier per Standard per time window:

```javascript
// Check if you're within rate limit
const withinLimit = await certifierRegistry.checkRateLimit(yourAddress, standardId);
```

This prevents excessive certifications and maintains quality.

---

## Certification Process

### Step 1: Receive Request

Provers will contact you with:
- Standard (standardId, version) they're attempting
- Request for live observation session

### Step 2: Review Standard

Verify you understand the requirements:

```javascript
const standard = await standardsRegistry.getStandard(standardId);
const version = await standardsRegistry.getVersion(standardId, versionNum);
// Fetch and review full requirements from metadata
```

Key elements to review:
- **Tool spec**: equipment requirements
- **Task**: what must be accomplished
- **Evidence requirements**: what you need to observe
- **Pass rule**: criteria for PASS vs NO PASS

### Step 3: Live Observation

**Observation Methods**:
- **Co-located**: Present in person with the Prover
- **Live video**: Real-time audio-video call

**During Observation**:
- Verify equipment matches tool spec
- Watch the entire attempt in real-time
- Note timestamps and key moments
- Confirm evidence requirements are captured

Recording is defined by the Standard and requires **mutual consent**.

### Step 4: Make Decision

**PASS (result=1)** if:
- All requirements clearly met
- Evidence is unambiguous
- No signs of manipulation
- Observed live as required

**NO PASS (result=0)** if:
- Requirements not met
- Evidence insufficient
- Concerns about authenticity
- Observation was not truly live

### Step 5: Co-sign Attestation

If decision made, co-sign the attestation:

```javascript
const attestation = {
  standardId: standardId,
  version: standardVersion,
  prover: proverAddress,
  certifier: yourAddress,
  result: 1,  // PASS=1, NO_PASS=0
  timestamp: attemptTimestamp,
  nonce: await popw.getCurrentNonce(proverAddress),
  deadline: Math.floor(Date.now() / 1000) + 3600,
  toolId: toolId,           // Optional
  evidenceHash: evidenceHash // Optional
};

// Sign using EIP-712
const domain = {
  name: "PoPW",
  version: "1",
  chainId: chainId,
  verifyingContract: popwAddress
};

const signature = await signer.signTypedData(domain, types, attestation);
```

### Step 6: Return to Prover

Send the Prover:
- Signed attestation data
- Your signature
- Any feedback

---

## Verification Guidelines

### Live Observation Checklist

- [ ] Observation is real-time (not recorded)
- [ ] Equipment matches Standard tool spec
- [ ] Achievement completed as specified
- [ ] Duration requirements met
- [ ] All required views captured
- [ ] No signs of manipulation

### Red Flags

- Pre-recorded submissions claiming to be live
- Equipment not matching specifications
- Cuts or transitions in recording
- Obscured key moments
- Inconsistent timestamps

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

Certifiers earn a fee **per attempt** (both PASS and NO PASS):

```
Certifier Reward = Base Fee × Certifier BPS / 10000
```

This is paid for every attempt you certify, regardless of outcome.

### Example

Standard with 100 $EC base fee, 60% certifier share:
```
100 × 6000 / 10000 = 60 $EC per attempt
```

---

## Best Practices

### Be Thorough
- Review all requirements before certifying
- Don't rush verifications
- Ask for clarification if needed

### Be Fair
- Apply standards consistently
- Don't favor certain Provers
- Judge evidence objectively

### Be Professional
- Respond promptly
- Communicate clearly
- Provide constructive feedback on NO PASS

### Be Honest
- Never certify unverified achievements
- Report suspicious activity
- Maintain protocol integrity

### Monitor Your Limits
- Be aware of rate limits per standard
- Don't exceed sustainable certification volume
- Maintain quality over quantity

---

## Common Scenarios

### Borderline Cases

When achievement is close but unclear:
1. Request additional evidence
2. Ask for specific clarification
3. Default to NO PASS if uncertain

### Technical Issues

If observation has technical problems:
1. Reschedule the live session
2. Ensure better connection/setup
3. Don't certify based on incomplete observation

### Disputes

If Prover disagrees with NO PASS:
1. Explain specific requirement not met
2. Offer to observe another attempt
3. Suggest improvements for next time

---

## Monitoring

Anomalous Certifier–Prover concentration may be excluded from leaderboard eligibility. Maintain diverse certification patterns.

---

## Support

- Protocol documentation: `/docs/`
- Technical spec: `/docs/technical-spec.md`
- Community channels: [TBD]

---

*Certifier Guide v1.0.16*
