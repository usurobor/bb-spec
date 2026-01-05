# Marshal Guide
## Verifying Physical Achievements (v1.0.17)

> **Vocabulary:** Architect (defines Trials) • Contender (attempts) • Marshal (observes) • Trial (the test) • Run (one attempt) • Record (signed attestation) • Badge (credential) • Replay (video evidence) • Ladder (rankings)

---

## Overview

As a **Marshal**, you verify that Contenders have genuinely completed physical achievements through **live observation**. Your Records enable the minting of Badges on PASS, with each Badge linked to a required Replay.

---

## Becoming a Marshal

### Phase 1: Genesis Key

Genesis Marshals are established at protocol launch:
- Selected for demonstrated expertise
- Community standing
- Bootstrap the trust network
- Can revoke other Marshals (v1 safety valve)

### Phase 2: 3-Vouch Admission

New Marshals join via vouching:

1. **Build Reputation**: Demonstrate expertise in your domain
2. **Connect**: Engage with existing Marshals
3. **Receive Vouches**: Get **3 distinct Marshals** to vouch for you on-chain
4. **Automatic Admission**: Once 3 vouches received, you're in

```javascript
// Check your vouch status
const vouches = await marshalRegistry.vouchesReceived(yourAddress);
console.log(`Vouches: ${vouches.length}/3`);
```

---

## Marshal Responsibilities

### Core Duties

1. **Live Observation**: Observe Runs in real-time (co-located or video)
2. **Honest Verification**: Only sign genuine achievements
3. **Thorough Review**: Check all Trial requirements
4. **Verify Replay**: Confirm Contender is recording (required for PASS)
5. **Timely Response**: Respond to Contender requests promptly
6. **Maintain Integrity**: Uphold protocol Trials

### Revocation (v1 Safety Valve)

Genesis Keys may revoke Marshal status:

```javascript
// Only Genesis Keys can call this
await marshalRegistry.revokeMarshal(marshalAddress);
```

A revoked Marshal cannot submit new Records.

---

## Rate Limits

The registry may enforce rate limits per Marshal per Trial per time window:

```javascript
// Check if you're within rate limit
const withinLimit = await marshalRegistry.checkRateLimit(yourAddress, trialId);
```

This prevents excessive certifications and maintains quality.

---

## Certification Process

### Step 1: Receive Request

Contenders will contact you with:
- Trial (trialId, version) they're attempting
- Request for live observation session

### Step 2: Review Trial

Verify you understand the requirements:

```javascript
const trial = await trialsRegistry.getTrial(trialId);
const version = await trialsRegistry.getVersion(trialId, versionNum);
// Fetch and review full requirements from metadata
```

Key elements to review:
- **Tool spec**: equipment requirements
- **Task**: what must be accomplished
- **Evidence requirements**: what you need to observe
- **Pass rule**: criteria for PASS vs NO PASS

### Step 3: Live Observation

**Observation Methods**:
- **Co-located**: Present in person with the Contender
- **Live video**: Real-time audio-video call

**During Observation**:
- Verify Contender is recording (Replay is required for PASS)
- Verify equipment matches tool spec
- Watch the entire Run in real-time
- Note timestamps and key moments
- Confirm evidence requirements are captured

Recording is defined by the Trial and requires **mutual consent**.

### Step 4: Make Decision

**PASS (result=1)** if:
- All requirements clearly met
- Evidence is unambiguous
- No signs of manipulation
- Observed live as required
- **Replay was captured** (required for Badge)

**NO PASS (result=0)** if:
- Requirements not met
- Evidence insufficient
- Concerns about authenticity
- Observation was not truly live
- Replay was not properly captured (if claiming PASS)

### Step 5: Co-sign Record

If decision made, co-sign the Record:

```javascript
const record = {
  trialId: trialId,
  version: trialVersion,
  contender: contenderAddress,
  marshal: yourAddress,
  result: 1,  // PASS=1, NO_PASS=0
  timestamp: runTimestamp,
  nonce: await popw.getCurrentNonce(contenderAddress),
  deadline: Math.floor(Date.now() / 1000) + 3600,
  toolId: toolId,           // Optional
  replayHash: replayHash,   // Required for PASS
  replayRef: replayRef      // Required for PASS
};

// Sign using EIP-712
const domain = {
  name: "PoPW",
  version: "1",
  chainId: chainId,
  verifyingContract: popwAddress
};

const signature = await signer.signTypedData(domain, types, record);
```

### Step 6: Return to Contender

Send the Contender:
- Signed Record data
- Your signature
- Any feedback
- Confirmation of Replay details

---

## Verification Guidelines

### Live Observation Checklist

- [ ] Observation is real-time (not recorded)
- [ ] Contender is recording (Replay required for PASS)
- [ ] Equipment matches Trial tool spec
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
- Contender not recording (cannot issue PASS)

---

## Vouching for New Marshals

As a Marshal, you can vouch for candidates:

```javascript
await marshalRegistry.vouch(candidateAddress);
```

### Vouching Guidelines

**Vouch for candidates who:**
- Have demonstrated expertise
- Show integrity and reliability
- Understand the protocol
- Will uphold Trials

**Don't vouch for:**
- Unknown individuals
- Those with conflicts of interest
- Candidates you can't verify

### Revoking Vouches

If circumstances change:

```javascript
await marshalRegistry.revokeVouch(candidateAddress);
```

---

## Economics

### Earning Fees

Marshals earn a fee **per Run** (both PASS and NO PASS):

```
Marshal Reward = Base Fee × Marshal BPS / 10000
```

This is paid for every Run you observe, regardless of outcome.

### Example

Trial with 100 $EC base fee, 60% Marshal share:
```
100 × 6000 / 10000 = 60 $EC per Run
```

---

## Best Practices

### Be Thorough
- Review all requirements before signing
- Don't rush verifications
- Ask for clarification if needed
- Verify Replay is being captured

### Be Fair
- Apply Trials consistently
- Don't favor certain Contenders
- Judge evidence objectively

### Be Professional
- Respond promptly
- Communicate clearly
- Provide constructive feedback on NO PASS

### Be Honest
- Never sign unverified achievements
- Report suspicious activity
- Maintain protocol integrity
- Don't sign PASS without valid Replay

### Monitor Your Limits
- Be aware of rate limits per Trial
- Don't exceed sustainable Run volume
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
3. Don't sign based on incomplete observation

### Missing Replay

If Contender didn't record or recording failed:
1. Cannot issue PASS (Replay required for Badge)
2. May issue NO PASS to record the Run
3. Schedule another Run with proper recording

### Disputes

If Contender disagrees with NO PASS:
1. Explain specific requirement not met
2. Offer to observe another Run
3. Suggest improvements for next time

---

## Monitoring

Anomalous Marshal–Contender concentration may be excluded from Ladder eligibility. Maintain diverse certification patterns.

---

## Support

- Protocol documentation: `/docs/`
- Technical spec: `/docs/technical-spec.md`
- Community channels: [TBD]

---

*Marshal Guide v1.0.17*
