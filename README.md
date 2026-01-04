# Embodied Coherence Protocol

**Proof-of-Physical-Work (PoPW) certification system for embodied achievements.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Overview

Embodied Coherence is a decentralized protocol for certifying physical achievements and embodied practices. Certified practitioners ("Certifiers") verify real-world feats performed by "Provers," issuing non-transferable Soul Bound Tokens (BBT) as on-chain proof.

### Key Features

- **Proof-of-Physical-Work (PoPW)** — Attestation-based verification of embodied achievements
- **Body Bound Tokens (BBT)** — Non-transferable SBTs representing certified accomplishments
- **Certifier Network** — Genesis Keys + 3-vouch expansion model for trust propagation
- **Standards Registry** — Versioned, community-defined certification standards
- **$EC Token** — Fee and governance token for protocol economics

---

## Repository Structure

```
bodybound/
├── docs/                  # Protocol documentation
│   ├── whitepaper.md      # Full protocol specification
│   ├── CHANGELOG.md       # Version history
│   ├── pitch-deck.md      # Investor/community pitch
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

## Quick Start

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

## Protocol Roles

| Role | Description |
|------|-------------|
| **Creator** | Defines certification standards (e.g., "1-minute sadhu board hold") |
| **Prover** | Performs physical feats and requests certification |
| **Certifier** | Verifies proofs and co-signs attestations |

---

## Documentation

- [Whitepaper](docs/whitepaper.md) — Full protocol specification
- [Technical Spec](docs/technical-spec.md) — Implementation details
- [Creator Guide](docs/guides/creator-guide.md) — How to create standards
- [Prover Guide](docs/guides/prover-guide.md) — How to get certified
- [Certifier Guide](docs/guides/certifier-guide.md) — How to become a certifier

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Links

- Documentation: `/docs`
- Contracts: `/contracts`
- Standards: `/standards`
