# Diligence FAQ (v0.1)

## What is PoPW?
A protocol for issuing non-transferable credentials for physical achievements verified by authorized certifiers under shared, versioned standards.

## Why not a database?
A database proves "a platform says it happened." PoPW provides a neutral registry of standards and non-repudiable attestations signed by both parties, portable across apps and communities.

## Is v1 trustless?
No. v1 is integrity-first and permissioned. Certifiers are authorized via registry. Decentralization mechanisms are future work.

## What prevents collusion?
v1 controls focus on protecting prestige:
- permissioned certifiers + vouch-based expansion
- rate limits per certifier/standard/time window
- monitoring for anomalous prover–certifier concentration
- leaderboard eligibility is curated; credentials can exist without earning leaderboard prestige

## Who are Genesis Keys?
The initial certifiers who bootstrap the network; multisig recommended with published signers and a defined operating policy.

## How do Standards work?
Standards are registered as (standardId, version) with immutable versions. A standard defines tool spec, task, evidence requirements, pass rule, and leaderboard rule. New rules ship as new versions.

## What is recorded on-chain?
Minimum: standardId+version, prover, certifier, timestamp, PASS/NO PASS. Optional: toolId and off-chain evidence hash/pointer.

## Are recordings required?
Only if the Standard requires it and both parties consent. Media is off-chain; the chain stores at most a hash/pointer.

## How are certifiers paid?
Default is per-attempt compensation (reduces perverse incentives to PASS). Creator royalty applies on PASS mints.

## Why have a token ($EC)?
Fees are priced USD-equivalent and paid in protocol-approved assets. $EC supports fee routing and governance; stable assets can be supported as approved fee assets.

## What are the v1 milestones?
Audited contracts, mobile certification app, 10–20 gym pilots, 20–50 active certifiers, 5–10 leaderboard-eligible standards, 10k–50k attempts.
