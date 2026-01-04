# Creator Guide
## Defining Certification Standards

---

## Overview

As a **Creator**, you define the Standards that Provers can achieve and Certifiers can verify. Standards are the building blocks of the Embodied Coherence protocol.

---

## What is a Standard?

A Standard is a JSON definition that specifies:
- **What** physical achievement is being certified
- **How** it should be verified
- **What** evidence is required
- **How** creators are compensated

---

## Creating a Standard

### Step 1: Define the Achievement

Be specific and measurable:

```json
{
  "name": "Sadhu Board Hold - 1 Minute",
  "description": "Maintain standing position on sadhu board (10mm nails, 10mm spacing) for 60 continuous seconds",
  "category": "endurance",
  "difficulty": "intermediate"
}
```

### Step 2: Specify Requirements

Detail the exact conditions:

```json
{
  "requirements": {
    "duration_seconds": 60,
    "equipment": {
      "type": "sadhu_board",
      "nail_height_mm": 10,
      "nail_spacing_mm": 10
    },
    "position": "standing",
    "allowed_support": "none"
  }
}
```

### Step 3: Define Evidence Schema

Specify what proof is needed:

```json
{
  "evidence": {
    "required": ["video"],
    "video": {
      "min_duration_seconds": 65,
      "must_show": ["full_body", "timer", "board_detail"],
      "continuous": true
    },
    "optional": ["witness_attestation", "sensor_data"]
  }
}
```

### Step 4: Set Economics

Define your royalty share:

```json
{
  "economics": {
    "base_fee_ec": 100,
    "creator_royalty_bps": 2000
  }
}
```

- `base_fee_ec`: Fee in $EC tokens
- `creator_royalty_bps`: Your share in basis points (2000 = 20%)

---

## Submitting Your Standard

### 1. Validate Against Schema

```bash
# Validate your standard JSON
npx ajv validate -s standards/schema.json -d your-standard.json
```

### 2. Upload Metadata

Upload your standard JSON to IPFS:

```bash
ipfs add your-standard.json
# Returns: QmYourStandardHash
```

### 3. Register On-Chain

Call `StandardsRegistry.createStandard()`:

```javascript
const tx = await standardsRegistry.createStandard(
  "ipfs://QmYourStandardHash",  // metadataURI
  2000,                          // royaltyBps (20%)
  ethers.parseEther("100")       // baseFee in $EC
);
```

---

## Best Practices

### Be Precise
- Ambiguous standards lead to disputes
- Specify exact measurements, durations, conditions

### Be Achievable
- Standards should be challenging but attainable
- Consider progression paths (beginner → advanced)

### Be Verifiable
- Evidence requirements must be practical
- Consider what Certifiers can reasonably verify

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

Your earnings per certification:

```
Your Royalty = Base Fee × (Royalty BPS / 10000)
```

Example with 100 $EC base fee and 20% royalty:
```
100 × (2000 / 10000) = 20 $EC per certification
```

---

## Updating Standards

Standards are **immutable** once published. To update:

1. Create a new version with updated parameters
2. Deactivate the old version (optional)
3. The new version gets a new `standardId`

---

## Support

- Schema reference: `/standards/schema.json`
- Example standards: `/standards/v1/`
- Technical spec: `/docs/technical-spec.md`

---

*Creator Guide v1.0*
