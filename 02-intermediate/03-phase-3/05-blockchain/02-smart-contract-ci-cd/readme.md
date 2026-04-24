# 🚀 02: Smart Contract CI/CD

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Security & Analysis ➡️](../03-security-and-analysis/readme.md)**

---

# 🤖 Automation for the Decentralized Web

In Blockchain DevOps, your CI/CD pipeline is the **Only Line of Defense**. Because code on the mainnet is immutable, any bug that passes the pipeline is potentially permanent.

## 🌉 The "Immutable" Pipeline Flow

A production-grade Web3 pipeline must do more than just build; it must **audit** and **verify**.

1.  **Format & Lint**: Ensure `solhint` and `prettier-plugin-solidity` are satisfied.
2.  **Compilation Check**: Verify `forge build` succeeds across target EVM versions.
3.  **Unit Tests**: Run `forge test` with high verbosity (`-vvv`).
4.  **Static Analysis**: Trigger a **Slither** scan to find common vulnerabilities.
5.  **Gas Snapshot**: Track execution costs. If a PR increases gas usage by 10%, it needs manual review.
6.  **Testnet Handoff**: Automate deployment to **Sepolia** for staging.

---

## 🔑 Secure Secret Management

The #1 cause of lost funds in DevOps is **leaked private keys**.

| Strategy | Risk Level | Best For |
| :--- | :--- | :--- |
| **`.env` files** | 💀 **DEADLY** | Local development (add to `.gitignore`!) |
| **GitHub Secrets** | ⚠️ Moderate | CI testing and Testnet deployments. |
| **Cloud KMS** | ✅ Low | Production deployments. Signs transactions without raw key access. |
| **Multi-Sig (Gnosis)** | 🔓 Safest | Handling actual treasury funds or code upgrades. |

---

## 📂 Project Structure

Check out the `src/` directory for automation templates:
- `foundry-ci.yml`: A complete GitHub Action for building and testing.
- `deploy-sepolia.sh`: A shell script for automated testnet deployment with verification.

---

## 🛡️ DevOps Best Practices

1.  **Strict Compilers**: Never use floating pragmas (e.g., `^0.8.0`) in production. Lock it to a specific version (e.g., `0.8.20`).
2.  **Size Limits**: Smart contracts have a **24KB size limit**. Your CI should fail if the contract exceeds this limit (use `forge build --sizes`).
3.  **Self-Verification**: Always use the `--verify` flag during deployment to ensure your code is readable on Etherscan.

---

## 🧪 DevOps Challenge

**Goal**: Configure a CI pipeline that blocks merging if gas costs increase.

1.  Look at the `foundry-ci.yml` in `src/`.
2.  Research the `forge snapshot` command.
3.  How would you set up a GitHub Action to compare the current gas snapshot with the one on the `main` branch?

---
### 🏁 Continue the Journey
Proceed to **[03: Security & Analysis](../03-security-and-analysis/readme.md)**.
