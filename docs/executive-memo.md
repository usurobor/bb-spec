# Embodied Coherence — 1-page Executive Memo (v0.1)
## Proof of Physical Work (PoPW)

### What it is
PoPW is a shared standards and credential rail for physical tests. It issues non-transferable credentials for achievements verified by authorized certifiers under versioned, immutable standards.

### Who it's for first
Partner gyms and coaches running grip + balance benchmarks where live observation is normal and sessions/events are already monetized. Members pay for portable proof and credible leaderboards under common rules.

### The product (one attempt)
1) Prover selects a Standard (standardId, version) and uses a tool matching its spec
2) Prover performs under live observation (co-located or video)
3) Prover + Certifier co-sign one shared attestation (2-of-2)
4) On-chain record stores minimal PASS/NO PASS outcome; PASS mints BBT
5) Leaderboards rank verified PASS per leaderboard-eligible Standard versions

### Why blockchain
- Neutral registry of Standard IDs + versions
- Publicly verifiable, non-repudiable attestations (both parties signed)
- Portability across apps/communities via a shared credential graph
- Auditable history without reliance on one operator's database

### Integrity model (v1)
Integrity-first: permissioned certifiers.
- Genesis Keys (multisig recommended) certify in Phase 1
- Expansion via 3 on-chain vouches
- Revocation safety valve in v1
- Rate limits + monitoring; leaderboard eligibility is curated while credentials persist

### Economics (illustrative)
- Attempt fee covers live labor (certifier paid per attempt)
- PASS mint fee funds credential issuance + creator royalty (PASS only)
- Fees priced USD-equivalent; paid in protocol-approved assets

### Status
v1 protocol spec complete (registries + EIP-712 attestations + integrity controls). Seed funds implementation, audit, mobile app, and Genesis pilots.

### The ask
Seed to ship audited v1 and run 10–20 gym pilots with 20–50 active certifiers and 5–10 leaderboard-eligible standard versions.
