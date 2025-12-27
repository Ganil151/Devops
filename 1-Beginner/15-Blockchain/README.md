# Blockchain DevOps: Fundamentals

## Introduction
Blockchain is a shared, immutable ledger that facilitates the process of recording transactions and tracking assets in a business network. For DevOps engineers, understanding the underlying infrastructure—nodes, networks, and consensus mechanisms—is the first step.

![Blockchain Structure](../Images/blockchain-structure.png)

## 1. Core Concepts

### Distributed Ledger Technology (DLT)
Unlike a centralized database (SQL), a blockchain is distributed across many computers (nodes).
- **Decentralization**: No single point of failure.
- **Immutability**: Once data is written, it cannot be changed (easily).
- **Transparency**: All participants see the same data.

### The "Node"
A node is simply a server running the blockchain client software.
- **Full Node**: Stores the entire history of the blockchain (Hundreds of GBs).
- **Light Node**: Stores only headers; relies on full nodes for data.
- **Miner/Validator Node**: Participates in consensus to add new blocks.

### Consensus Mechanisms
How nodes agree on the truth.
- **Proof of Work (PoW)**: Computational power (Bitcoin). High energy, high security.
- **Proof of Stake (PoS)**: Economic stake (Ethereum). Energy efficient, widely used in modern chains.

---

## 2. The Blockchain Stack for DevOps

| Layer | Component | DevOps Relevance |
| :--- | :--- | :--- |
| **Layer 1 (L1)** | The Blockchain (Eth, Sol, BTC) | Running nodes, managing uptime, storage (IOPS) |
| **Layer 2 (L2)** | Scaling (Arbitrum, Optimism) | Running sequencers, bridging infrastructure |
| **RPC Layer** | API Access (Infura, Alchemy) | Load balancing requests, API key management |
| **Application** | DApps (Web3 Sites) | CI/CD for frontends, IPFS deployment |

---

## 3. Essential Tools

### Wallets
You need a wallet to sign transactions (deploy code).
- **Metamask**: Browser extension wallet.
- **Hardware Wallets**: Ledger/Trezor for secure key storage.

### Block Explorers
The fundamental debugging tool.
- **Etherscan**: For Ethereum.
- **Solscan**: For Solana.
- **Btc.com**: For Bitcoin.

### Node Clients
The software you verify and run.
- **Geth (Go-Ethereum)**: Most popular EL client.
- **Prysm**: Consensus layer client for Ethereum.
- **Solana CLI**: For Solana interaction.

---

## 4. Hands-On: Interacting with a Chain

You don't need to run a node to start. Use a public RPC endpoint.

```bash
# Install Cast (part of Foundry) to interact with EVM chains
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Get the latest block number from Ethereum Mainnet
cast block-number --rpc-url https://eth.llamarpc.com
```

---

## 🏆 Related Certifications

- **Certified Blockchain Expert (CBE)**: Validates understanding of blockchain fundamentals and use cases.
- **Certified Cryptocurrency Expert (CCE)**: Focuses on the crypto-asset side of the technology.

---

## Next Steps
Move to the **[Intermediate Level](../../2-Intermediate/15-Blockchain/README.md)** to learn how to build and deploy Smart Contracts using CI/CD pipelines.
