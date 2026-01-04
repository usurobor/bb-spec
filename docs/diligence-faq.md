# Diligence FAQ (v0.1)

> **Legend:** 🧾 Trial • 👤 Contender • 🧑‍⚖️ Marshal • 🏷️ Badge • ⛓️ On-chain • 🏆 Ladder • ✅ PASS • ⛔ NO PASS

## What is PoPW?
A protocol for issuing non-transferable 🏷️ credentials for physical achievements verified by authorized 🧑‍⚖️ Marshals under shared, versioned 🧾 Trials.

## Why not a database?
A database proves "a platform says it happened." PoPW provides a neutral registry of Trials and non-repudiable Records signed by both parties, portable across apps and communities.

## Is v1 trustless?
No. v1 is integrity-first and permissioned. 🧑‍⚖️ Marshals are authorized via registry. Decentralization mechanisms are future work.

## What prevents collusion?
v1 controls focus on protecting prestige:
- permissioned 🧑‍⚖️ Marshals + vouch-based expansion
- rate limits per Marshal / Trial / time window
- monitoring for anomalous 👤 Contender–🧑‍⚖️ Marshal concentration
- 🏆 Ladder eligibility is curated; credentials can exist without earning Ladder prestige

## Who are Genesis Keys?
The initial 🧑‍⚖️ Marshals who bootstrap the network; multisig recommended with published signers and a defined operating policy.

## How do Trials work?
🧾 Trials are registered as (trialId, version) with immutable versions. A Trial defines tool spec, task, evidence requirements, pass rule, and 🏆 Ladder rule. New rules ship as new versions.

## What is recorded on-chain?
Minimum: trialId+version, 👤 contender, 🧑‍⚖️ marshal, timestamp, ✅ PASS / ⛔ NO PASS. Optional: toolId and off-chain evidence hash/pointer.

## Are recordings required?
Only if the 🧾 Trial requires it and both parties consent. Media is off-chain; the chain stores at most a hash/pointer.

## How are Marshals paid?
Default is per-Run compensation (reduces perverse incentives to PASS). 🧾 Architect royalty applies on ✅ PASS mints.

## Why have a token ($EC)?
Fees are priced USD-equivalent and paid in protocol-approved assets. $EC supports fee routing and governance; stable assets can be supported as approved fee assets.

## What are the v1 milestones?
Audited contracts, mobile certification app, 10–20 gym pilots, 20–50 active 🧑‍⚖️ Marshals, 5–10 🏆 Ladder-eligible 🧾 Trials, 10k–50k Runs.
