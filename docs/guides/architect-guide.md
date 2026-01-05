# Architect Guide
## Defining Trials (v1.0.17)

> **Vocabulary:** Architect (defines Trials) • Contender (attempts) • Marshal (observes) • Trial (the test) • Run (one attempt) • Record (signed attestation) • Badge (credential) • Replay (video evidence) • Ladder (rankings)

---

## Overview

As an **Architect**, you define the Trials that Contenders can attempt and Marshals can verify. Trials are versioned and immutable once published. Every PASS mints a Badge linked to a Replay.

---

## What is a Trial?

A Trial (trialId, version) specifies:
- **Tool spec**: equipment requirements
- **Task**: what achievement is being certified
- **Evidence requirements**: what proof is needed (including Replay)
- **Pass rule**: criteria for PASS vs NO PASS
- **Ladder rule**: how to rank verified PASS results

---

## Creating a Trial

### Step 1: Define the Achievement

Be specific and measurable:

```json
{
  "name": "Sadhu Board Hold - 1 Minute",
  "version": "1.0.0",
  "description": "Maintain standing position on sadhu board (10mm nails, 10mm spacing) for 60 continuous seconds",
  "category": "endurance",
  "difficulty": "intermediate"
}
```

### Step 2: Specify Requirements (Tool Spec)

Detail the exact conditions:

```json
{
  "requirements": {
    "duration_seconds": 60,
    "equipment": {
      "type": "sadhu_board",
      "specifications": {
        "nail_height_mm": 10,
        "nail_spacing_mm": 10
      }
    },
    "position": "standing",
    "restrictions": ["no_external_support"]
  }
}
```

### Step 3: Define Evidence Schema (Including Replay)

Specify what proof is needed for live observation. **Replay is required for PASS.**

```json
{
  "evidence": {
    "required": ["video"],
    "replay": {
      "required_for_pass": true,
      "min_duration_seconds": 65,
      "must_show": ["full_body", "timer", "board_detail"],
      "continuous": true,
      "min_resolution": "720p"
    },
    "optional": ["witness"]
  }
}
```

### Step 4: Define Pass Rule and Scoring

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

### Step 5: Set Economics

Define your royalty share (earned on PASS only):

```json
{
  "economics": {
    "base_fee_ec": 100,
    "architect_royalty_bps": 2000
  }
}
```

- `base_fee_ec`: Fee in $EC tokens
- `architect_royalty_bps`: Your share in basis points (2000 = 20%), paid only on PASS

---

## Submitting Your Trial

### 1. Validate Against Schema

```bash
# Validate your Trial JSON
npx ajv validate -s standards/schema.json -d your-trial.json
```

### 2. Compute Metadata Hash

Hash your Trial JSON for on-chain reference:

```javascript
const metadataHash = keccak256(trialJsonBytes);
```

### 3. Register On-Chain

Call `TrialsRegistry.createTrial()`:

```javascript
const tx = await trialsRegistry.createTrial(
  metadataHash,                        // bytes32 metadata hash
  2000,                                // royaltyBps (20%)
  ethers.parseEther("100")             // baseFee in $EC
);
// Returns: trialId (bytes32)
```

---

## Adding New Versions

Trials are versioned. Each version is immutable.

```javascript
// Add a new version to an existing Trial
const tx = await trialsRegistry.addVersion(
  trialId,         // existing Trial ID
  newMetadataHash  // hash of updated JSON
);
// Returns: version number (uint32)
```

---

## Ladder Eligibility

The registry may mark a Trial version as **Ladder-eligible**:

```javascript
// Only protocol governance can set this
await trialsRegistry.setLadderEligible(trialId, version, true);
```

Ladders rank verified PASS results by your Trial's Ladder rule.

---

## Replay Requirements

**v1.0.17**: Replay (video evidence) is required for PASS / Badge issuance.

When designing Trials, specify:
- Minimum video duration
- Required camera angles
- What must be visible (equipment, timer, full body, etc.)
- Resolution requirements

The protocol enforces that `replayHash` and `replayRef` are present for every PASS.

---

## Best Practices

### Be Precise
- Ambiguous Trials lead to disputes
- Specify exact measurements, durations, conditions

### Be Achievable
- Trials should be challenging but attainable
- Consider progression paths (beginner → advanced)

### Be Verifiable
- Evidence requirements must be practical for live observation
- Consider what Marshals can reasonably verify in real-time
- Define clear Replay requirements

### Consider Safety
- Include safety requirements where appropriate
- Note any contraindications or warnings

---

## Example Trials

### Physical Endurance
- Sadhu board holds (various durations)
- Plank holds
- Cold exposure

### Skill Demonstration
- Martial arts forms
- Yoga sequences
- Dance choreography

### Strength Achievements
- Weighted movements
- Bodyweight skills
- Lifting milestones

---

## Royalty Economics

Your earnings per PASS:

```
Your Royalty = Base Fee × (Royalty BPS / 10000)
```

Example with 100 $EC base fee and 20% royalty:
```
100 × (2000 / 10000) = 20 $EC per PASS
```

Note: Architect royalty is only paid on PASS. NO PASS Runs do not generate Architect royalty.

---

## Updating Trials

Versions are **immutable** once published. To update:

1. Create a new version with `addVersion()`
2. The new version gets an incremented version number
3. Both versions remain valid; Ladder eligibility is set per version

---

## Support

- Schema reference: `/standards/schema.json`
- Example Trials: `/standards/v1/`
- Technical spec: `/docs/technical-spec.md`

---

*Architect Guide v1.0.17*
