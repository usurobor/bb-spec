# Embodied Coherence Protocol

**Proof-of-Physical-Work (PoPW) — Live-observed certification for physical achievements.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Legend:** 🧾 Standard • 👤 Prover • 🧑‍⚖️ Certifier • 🏷️ BBT • ⛓️ On-chain • 🏆 Leaderboard • ✅ PASS • ⛔ NO PASS

---

## 🎯 Overview

Embodied Coherence is a protocol that issues non-transferable 🏷️ credentials for physical achievements verified by authorized 🧑‍⚖️ Certifiers under shared 🧾 Standards.

### Key Features

- **Proof-of-Physical-Work (PoPW)** — Live-observed, 2-of-2 signed attestations (👤 Prover + 🧑‍⚖️ Certifier)
- **🏷️ Body Bound Tokens (BBT)** — Non-transferable SBTs minted on ✅ PASS; do not expire (v1)
- **🧾 Versioned Standards** — Immutable (standardId, version) definitions with 🏆 leaderboard eligibility
- **🧑‍⚖️ Certifier Network** — Genesis Keys + 3-vouch expansion + revocation (v1 safety valve)
- **$EC Token** — Fee and governance token (other fee assets may be approved)

---

## 👥 Protocol Roles

| Role | Description |
|------|-------------|
| **🧾 Creator** | Registers Standards; earns royalty per ✅ PASS mint |
| **👤 Prover** | Attempts; pays fee |
| **🧑‍⚖️ Certifier** | Authorized; observes live; co-signs; earns fee per attempt |
| **🔑 Genesis Keys** | Initial Certifiers; manage Certifier set in v1 |

---

## 🔁 How It Works

```
🧾 Select → 👀 Observe → ✍️ Co-sign → ⛓️ Submit → 🏷️ Credential + 🏆 Leaderboard
```

1. 👤 Prover selects 🧾 **(standardId, version)** and uses a tool matching the spec
2. 👤 Prover performs under **live observation** (co-located or video)
3. 👤 Prover + 🧑‍⚖️ Certifier co-sign one attestation (2-of-2)
4. ⛓️ Attestation recorded on-chain
   - **✅ PASS**: mint 🏷️ BBT
   - **⛔ NO PASS**: record attempt; no BBT
5. 🏆 Leaderboards rank **verified ✅ PASS** per standard (eligible versions only)

---

## 📁 Repository Structure

```
bodybound/
├── docs/                  # Protocol documentation
│   ├── whitepaper.md      # Full protocol specification (v1.0.16)
│   ├── CHANGELOG.md       # Version history
│   ├── pitch-deck.md      # Investor pitch (v0.7)
│   ├── executive-memo.md  # 1-page decision document
│   ├── demo-script.md     # Live demo script
│   ├── diligence-faq.md   # Investor Q&A
│   ├── technical-spec.md  # Technical implementation details
│   └── guides/            # Role-specific guides
├── contracts/             # Solidity smart contracts (Foundry)
│   ├── src/               # Contract source files
│   ├── test/              # Contract tests
│   └── script/            # Deployment scripts
├── standards/             # Certification standard definitions
│   ├── schema.json        # Standard JSON schema
│   └── v1/                # Version 1 standards
├── app/                   # Frontend application
└── assets/                # Branding and media assets
```

---

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) for smart contract development
- Node.js 18+ for frontend

### Build Contracts

```bash
cd contracts
forge build
```

### Run Tests

```bash
cd contracts
forge test
```

---

## 🛡️ Trust Model (v1)

PoPW v1 is **permissioned** by design.

**🧑‍⚖️ Certifier Authorization**
- **Phase 1 (Genesis):** only 🔑 Genesis Keys certify
- **Phase 2 (Expansion):** candidate becomes 🧑‍⚖️ certifier after **3 on-chain vouches**
- **Revocation:** 🔑 Genesis Keys may revoke certifier status (v1 safety valve)

**Integrity Controls**
- Rate limits: per 🧑‍⚖️ certifier, per 🧾 standard, per time window
- Monitoring: anomalous certifier–prover concentration may be excluded from 🏆 leaderboards

---

## 📚 Documentation

- [Whitepaper](docs/whitepaper.md) — Full protocol specification (v1.0.16)
- [Technical Spec](docs/technical-spec.md) — Implementation details
- [Pitch Deck](docs/pitch-deck.md) — Investor pitch (v0.7)
- [Executive Memo](docs/executive-memo.md) — 1-page decision document
- [Demo Script](docs/demo-script.md) — Live certification demo
- [Diligence FAQ](docs/diligence-faq.md) — Investor Q&A

### Role Guides
- [Creator Guide](docs/guides/creator-guide.md) — How to create 🧾 standards
- [Prover Guide](docs/guides/prover-guide.md) — How to get certified
- [Certifier Guide](docs/guides/certifier-guide.md) — How to become a 🧑‍⚖️ certifier

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 🔗 Links

- Documentation: `/docs`
- Contracts: `/contracts`
- Standards: `/standards`
