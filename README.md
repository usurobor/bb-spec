# Embodied Coherence Protocol

**Proof-of-Physical-Work (PoPW) — Live-observed certification for physical achievements.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Legend:** 🧾 Trial • 👤 Contender • 🧑‍⚖️ Marshal • 🏷️ Badge • ⛓️ On-chain • 🏆 Ladder • ✅ PASS • ⛔ NO PASS

---

## 🎯 Overview

Embodied Coherence is a protocol that issues non-transferable 🏷️ credentials for physical achievements verified by authorized 🧑‍⚖️ Marshals under shared 🧾 Trials.

### Key Features

- **Proof-of-Physical-Work (PoPW)** — Live-observed, 2-of-2 signed Records (👤 Contender + 🧑‍⚖️ Marshal)
- **🏷️ Badges** — Non-transferable SBTs minted on ✅ PASS; do not expire (v1)
- **🧾 Versioned Trials** — Immutable (trialId, version) definitions with 🏆 Ladder eligibility
- **🧑‍⚖️ Marshal Network** — Genesis Keys + 3-vouch expansion + revocation (v1 safety valve)
- **$EC Token** — Fee and governance token (other fee assets may be approved)

---

## 👥 Protocol Roles

| Role | Description |
|------|-------------|
| **🧾 Architect** | Defines Trials; earns royalty per ✅ PASS mint |
| **👤 Contender** | Attempts Runs; pays fee |
| **🧑‍⚖️ Marshal** | Authorized; observes live; co-signs; earns fee per Run |
| **🔑 Genesis Keys** | Initial Marshals; manage Marshal set in v1 |

---

## 🔁 How It Works

```
🧾 Select Trial → 👀 Live Run → ✍️ Co-sign Record → ⛓️ Submit → 🏷️ Badge + 🏆 Ladder
```

1. 👤 Contender selects 🧾 **(trialId, version)** and uses a tool matching the spec
2. 👤 Contender performs a Run under **live observation** (co-located or video)
3. 👤 Contender + 🧑‍⚖️ Marshal co-sign one Record (2-of-2)
4. ⛓️ Record submitted on-chain
   - **✅ PASS**: mint 🏷️ Badge
   - **⛔ NO PASS**: record Run; no Badge
5. 🏆 Ladders rank **verified ✅ PASS** per Trial (eligible versions only)

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
├── standards/             # Trial definitions
│   ├── schema.json        # Trial JSON schema
│   └── v1/                # Version 1 Trials
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

**🧑‍⚖️ Marshal Authorization**
- **Phase 1 (Genesis):** only 🔑 Genesis Keys certify
- **Phase 2 (Expansion):** candidate becomes 🧑‍⚖️ Marshal after **3 on-chain vouches**
- **Revocation:** 🔑 Genesis Keys may revoke Marshal status (v1 safety valve)

**Integrity Controls**
- Rate limits: per 🧑‍⚖️ Marshal, per 🧾 Trial, per time window
- Monitoring: anomalous Marshal–Contender concentration may be excluded from 🏆 Ladders

---

## 📚 Documentation

- [Whitepaper](docs/whitepaper.md) — Full protocol specification (v1.0.16)
- [Technical Spec](docs/technical-spec.md) — Implementation details
- [Pitch Deck](docs/pitch-deck.md) — Investor pitch (v0.7)
- [Executive Memo](docs/executive-memo.md) — 1-page decision document
- [Demo Script](docs/demo-script.md) — Live certification demo
- [Diligence FAQ](docs/diligence-faq.md) — Investor Q&A

### Role Guides
- [Architect Guide](docs/guides/architect-guide.md) — How to define 🧾 Trials
- [Contender Guide](docs/guides/contender-guide.md) — How to earn 🏷️ Badges
- [Marshal Guide](docs/guides/marshal-guide.md) — How to become a 🧑‍⚖️ Marshal

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 🔗 Links

- Documentation: `/docs`
- Contracts: `/contracts`
- Trials: `/standards`
