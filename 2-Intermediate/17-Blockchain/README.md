# Blockchain DevOps: Smart Contract CI/CD

## Introduction
In the intermediate level, we shift from understanding nodes to **building and deploying applications** on them. For a DevOps engineer, this means treating Smart Contracts like any other code artifact: testing, compiling, and automating deployment.

## 1. The Development Frameworks

Just as Java has Maven/Gradle, Blockchain (specifically EVM) has its own build tools.

### Hardhat (JavaScript/TypeScript)
The industry standard for years.
- **Language**: JavaScript/TypeScript testing.
- **Features**: Console logging, immense plugin ecosystem.
- **Usage**: Used by top protocols like Uniswap and Aave.

### Foundry (Rust)
The modern, blazing-fast alternative.
- **Language**: Solidity testing (write tests in Solidity!).
- **Features**: Fuzzing, Cheatcodes (manipulate time/state), Cast (CLI).
- **Speed**: Compiles and tests 10x-50x faster than Hardhat.

---

## 2. The DevOps Lifecycle for Web3

| Stage | Action | Tooling |
| :--- | :--- | :--- |
| **Commit** | Code push | Git |
| **Build** | Compile Solidity to Bytecode/ABI | `forge build` / `npx hardhat compile` |
| **Test** | Unit & Fuzz Tests | `forge test` |
| **Security** | Static Analysis | **Slither**, **MythX** |
| **Deploy** | Push to Testnet (Sepolia) | GitHub Actions + Private Key (Secrets) |
| **Verify** | Etherscan Verification | `forge verify-contract` |

---

## 3. Hands-On: A GitHub Actions Workflow

Here is a standard pipeline for deploying a Foundry project.

```yaml
name: Smart Contract CI

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
      
      - name: Run Tests
        run: forge test -vv

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Slither Security Scan
        uses: crytic/slither-action@v0.3.0
        with:
          fail-on: none # Don't fail for now, just report
```

---

## 4. Testnets vs. Mainnets

Never deploy straight to Mainnet. Use Testnets which mimic the main chain but use worthless currency.
- **Sepolia**: The recommended testnet for Ethereum application development.
- **Holesky**: For infrastructure/validator testing.

**Faucets**: Places to get free testnet ETH (e.g., Alchemy Faucet, Infura Faucet).

---

## 🏆 Related Certifications

- **Certified Solidity Developer**: Validates proficiency in writing and testing smart contracts.
- **Blockchain Developer (Hyperledger)**: For private/enterprise blockchain skills.

---

## Next Steps
Move to the **[Advanced Level](../../3-Advanced/13-Blockchain/README.md)** to master Node Operations, Monitoring, and Enterprise Security.
