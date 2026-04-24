# 📖 01: Blockchain Development Foundations

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Smart Contract CI/CD ➡️](../02-smart-contract-ci-cd/readme.md)**

---

# 📑 Smart Contract Lifecycle & Frameworks

To build on the blockchain, you must transition from traditional server-side logic to **deterministic, immutable execution**. This module covers the core tools and lifecycles used by Blockchain Engineers and SREs.

## 🧠 The Smart Contract Lifecycle

1.  **Drafting (Solidity)**: Writing human-readable code.
2.  **Compilation (Bytecode & ABI)**: Transforming code into a format the Ethereum Virtual Machine (EVM) understands.
    *   **Bytecode**: The actual logic stored on-chain.
    *   **ABI**: The interface used by frontends/scripts to talk to the contract.
3.  **Local Development (Anvil/Hardhat Node)**: Running a private, instant blockchain for rapid testing.
4.  **Deployment (Testnets)**: Pushing to "Sepolia" or "Holesky" to test with public infra without real value.
5.  **Verification (Etherscan)**: Linking the source code to the on-chain bytecode for transparency.

---

## 🛠️ Build Frameworks: Foundry vs. Hardhat

| Feature | **Foundry (Rust)** | **Hardhat (JS/TS)** |
| :--- | :--- | :--- |
| **Speed** | 🚀 Extremely Fast (Rust engine) | 🐢 Slower (Node.js engine) |
| **Testing** | Write tests in **Solidity** | Write tests in **JavaScript** |
| **Philosophy** | CLI-first, minimal config | Plugin-first, highly extensible |
| **Use Case**| Production security & speed | Legacy projects & Frontend integration |

### 🛠️ Foundry Quick Start
We recommend **Foundry** for modern DevOps due to its superior testing speed and CLI tooling (`cast`, `anvil`).

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Initialize a project
forge init my-contract
cd my-contract

# Build & Test
forge build
forge test
```

---

## 📂 Project Structure

Check out our reference implementation in the `src/` directory:
- `Counter.sol`: A basic "Hello World" smart contract.
- `Counter.t.sol`: A Foundry-style test showing how to validate logic in Solidity.

---

## 🧪 Knowledge Check

**1. What is the ABI used for?**
> *Answer: It acts as a bridge, telling your frontend or Python script how to format requests to the contract's functions.*

**2. Why do we test in Solidity using Foundry?**
> *Answer: It eliminates context switching and ensures your tests run exactly the same way the contract does on the EVM.*

**3. What is 'Bytecode'?**
> *Answer: The low-level, machine-readable instructions that are permanently stored on the blockchain.*

---

## 🚀 Take the Challenge
Open **[challenges.md](./challenges.md)** to start your first blockchain build.
