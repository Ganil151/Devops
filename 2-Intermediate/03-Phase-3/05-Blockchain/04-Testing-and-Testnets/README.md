# 04: Testing and Testnets

Testing in Blockchain happens in phases, moving from local speed to public realism.

## 🧪 Testing Levels

1.  **Unit Tests**: Testing individual functions in isolation.
2.  **Integration Tests**: Testing how multiple contracts interact (e.g., a Token interacting with a DEX).
3.  **Forks**: Testing your code against a "Fork" of the real mainnet (using Foundry or Hardhat). This allows you to interact with real contracts (like Uniswap) using local fake ETH.
4.  **Testnet Deployment**: The final stage before Mainnet.

---

## 🌍 Popular Testnets

- **Sepolia**: The current standard for Ethereum application development. It is fast and has a reliable faucet.
- **Holesky**: Designed for infrastructure and validator testing.
- **Mumbai / Amoy**: The testnets for the Polygon network.

---

## 🚰 Faucets and Test ETH

To deploy to a public testnet, you need "Test ETH". Since it has no monetary value, you get it from **Faucets**.

- **Alchemy Faucet**: Reliable but requires an account.
- **Infura Faucet**: Another major provider.
- **Sepolia-PoW-Faucet**: Where you "mine" test ETH in your browser.

---

## 🔍 Contract Verification

Deploying is not enough. You must **Verify** your contract on block explorers like Etherscan.
- Verification uploads the source code and matches it against the deployed bytecode.
- It allows users to read and interact with your contract through the Etherscan UI.
- **DevOps Tip**: Automate this in your pipeline using `--verify` flags in Foundry or the Hardhat-etherscan plugin.
