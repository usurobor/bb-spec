# Changelog

All notable changes to the Embodied Coherence protocol.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

---

## [1.0.13] - 2026-01-04

### Protocol Spec (Whitepaper)
- Converged whitepaper after Bohmian dialogue iteration
- Defined: Goal, Motivation, Primitives, Roles, Certifier Authorization, Flow, On-chain fields, Economics, Leaderboards, Contract Requirements, Precedents
- Certifier authorization: Genesis Keys → 3-vouch expansion
- BBT: non-transferable (SBT)
- $EC: fee/governance token

### Contracts (Scaffolded)
- CertifierRegistry.sol — Genesis + 3-vouch admission
- StandardsRegistry.sol — Standard definitions + royalty params
- PoPW.sol — Attest + Mint wiring
- BBT.sol — non-transferable SBT placeholder
- EC.sol — ERC-20 placeholder

### Standards (v1)
- sadhu-board-1m.json
- heavy-cup.json
- slack-board-1m.json
- lotus-wheels-1m.json

---

## [Unreleased]

### TODO
- [ ] 2-of-2 signature verification in PoPW.sol
- [ ] Fee splitting logic ($EC)
- [ ] Evidence hash/pointer support
- [ ] Leaderboard indexing
- [ ] Frontend certification flow
