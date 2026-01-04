# Embodied Coherence Contracts

Solidity smart contracts for the Embodied Coherence protocol.

## Contracts

| Contract | Description |
|----------|-------------|
| `CertifierRegistry.sol` | Genesis keys + 3-vouch certifier admission |
| `StandardsRegistry.sol` | Certification standard definitions |
| `PoPW.sol` | Proof-of-Physical-Work attestation & minting |
| `Attestation.sol` | EIP-712 typed data schema |
| `BBT.sol` | Non-transferable Soul Bound Token |
| `EC.sol` | ERC-20 fee/governance token |

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Install Dependencies

```bash
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std
```

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Deploy

```bash
# Set environment variables
export PRIVATE_KEY=0x...
export TREASURY_ADDRESS=0x...
export GENESIS_KEY_1=0x...

# Deploy to network
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
```

## Architecture

```
                    ┌─────────────────┐
                    │  CertifierReg   │
                    └────────┬────────┘
                             │
┌─────────────────┐          │          ┌─────────────────┐
│  StandardsReg   │──────────┼──────────│      PoPW       │
└─────────────────┘          │          └────────┬────────┘
                             │                   │
                    ┌────────┴────────┐          │
                    │       BBT       │◄─────────┘
                    │     (SBT)       │
                    └─────────────────┘
                             │
                    ┌────────┴────────┐
                    │       EC        │
                    │    (ERC-20)     │
                    └─────────────────┘
```

## License

MIT
