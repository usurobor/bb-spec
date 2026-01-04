# Creator Guide
## Defining Certification Standards (v1.0.16)

---

## Overview

As a **Creator**, you define the Standards that Provers can achieve and Certifiers can verify. Standards are versioned and immutable once published.

---

## What is a Standard?

A Standard (standardId, version) specifies:
- **Tool spec**: equipment requirements
- **Task**: what achievement is being certified
- **Evidence requirements**: what proof is needed
- **Pass rule**: criteria for PASS vs NO PASS
- **Leaderboard rule**: how to rank verified PASS results

---

## Creating a Standard

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

### Step 3: Define Evidence Schema

Specify what proof is needed for live observation:

```json
{
  "evidence": {
    "required": ["video"],
    "video": {
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
    "creator_royalty_bps": 2000
  }
}
```

- `base_fee_ec`: Fee in $EC tokens
- `creator_royalty_bps`: Your share in basis points (2000 = 20%), paid only on PASS

---

## Submitting Your Standard

### 1. Validate Against Schema

```bash
# Validate your standard JSON
npx ajv validate -s standards/schema.json -d your-standard.json
```

### 2. Compute Metadata Hash

Hash your standard JSON for on-chain reference:

```javascript
const metadataHash = keccak256(standardJsonBytes);
```

### 3. Register On-Chain

Call `StandardsRegistry.createStandard()`:

```javascript
const tx = await standardsRegistry.createStandard(
  metadataHash,                        // bytes32 metadata hash
  2000,                                // royaltyBps (20%)
  ethers.parseEther("100")             // baseFee in $EC
);
// Returns: standardId (bytes32)
```

---

## Adding New Versions

Standards are versioned. Each version is immutable.

```javascript
// Add a new version to an existing standard
const tx = await standardsRegistry.addVersion(
  standardId,      // existing standard ID
  newMetadataHash  // hash of updated JSON
);
// Returns: version number (uint32)
```

---

## Leaderboard Eligibility

The registry may mark a Standard version as **leaderboard-eligible**:

```javascript
// Only protocol governance can set this
await standardsRegistry.setLeaderboardEligible(standardId, version, true);
```

Leaderboards rank verified PASS results by your Standard's leaderboard rule.

---

## Best Practices

### Be Precise
- Ambiguous standards lead to disputes
- Specify exact measurements, durations, conditions

### Be Achievable
- Standards should be challenging but attainable
- Consider progression paths (beginner → advanced)

### Be Verifiable
- Evidence requirements must be practical for live observation
- Consider what Certifiers can reasonably verify in real-time

### Consider Safety
- Include safety requirements where appropriate
- Note any contraindications or warnings

---

## Example Standards

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

Your earnings per PASS certification:

```
Your Royalty = Base Fee × (Royalty BPS / 10000)
```

Example with 100 $EC base fee and 20% royalty:
```
100 × (2000 / 10000) = 20 $EC per PASS
```

Note: Creator royalty is only paid on PASS. NO PASS attempts do not generate creator royalty.

---

## Updating Standards

Versions are **immutable** once published. To update:

1. Create a new version with `addVersion()`
2. The new version gets an incremented version number
3. Both versions remain valid; leaderboard eligibility is set per version

---

## Support

- Schema reference: `/standards/schema.json`
- Example standards: `/standards/v1/`
- Technical spec: `/docs/technical-spec.md`

---

*Creator Guide v1.0.16*
