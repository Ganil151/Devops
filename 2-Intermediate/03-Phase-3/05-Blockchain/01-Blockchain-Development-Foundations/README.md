# 01: Blockchain Development Foundations

To build and deploy on a blockchain (EVM-compatible chains like Ethereum, Polygon, or Arbitrum), you need a structured development environment and build tools.

## 🛠️ Build Frameworks

Just as you use Maven for Java or npm for Node.js, Web3 has specialized frameworks for compiling, testing, and deploying Solidity code.

### 1. Hardhat (JavaScript/TypeScript)
The most mature framework in the ecosystem.
- **Features**: Rich plugin system, excellent debugging (console.log in Solidity), and seamless Ethers.js integration.
- **Workflow**: `npx hardhat compile`, `npx hardhat test`, `npx hardhat deploy`.

### 2. Foundry (Rust)
The modern choice for high-performance teams.
- **Features**: Written in Rust, extremely fast, and allows you to write tests in Solidity instead of JS.
- **Workflow**: `forge build`, `forge test`, `forge script`.
- **Tools**: Includes `cast` (CLI tool for interacting with the chain) and `anvil` (local test node).

---

## 🏗️ Development Lifecycle

1.  **Code**: Write Smart Contracts in **Solidity** or **Vyper**.
2.  **Compile**: Turn human-readable code into **Bytecode** (execution) and **ABI** (Application Binary Interface - for interaction).
3.  **Local Node**: Run a local blockchain (Hardhat Network or Anvil) to test without spending real money.
4.  **Testnet**: Deploy to a network like **Sepolia** for public testing.
5.  **Verification**: Upload your source code to Etherscan so users can verify the contract's logic.

---

## 📈 Comparison

| Feature | Hardhat | Foundry |
| :--- | :--- | :--- |
| **Test Language** | JS / TS | Solidity |
| **Speed** | Slow (JS Overhead) | Fast (Rust Engine) |
| **Complexity** | High (Config Files) | Low (CLI driven) |
| **Maturity** | Industry Standard | Rapidly Growing |
