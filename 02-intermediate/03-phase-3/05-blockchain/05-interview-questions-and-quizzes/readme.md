# 🎓 05: Interview Mastery & Knowledge Audit

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Real-Life Scenarios ➡️](../06-real-life-scenarios/readme.md)**

---

# 🎤 Top 20 Blockchain DevOps Interview Questions

Prepare for your role as a **Web3 Reliability Engineer**. These questions track your progress from Junior fundamentals to Architect-level system design.

### 🏛️ Tier 1: Foundations
1.  **What is the difference between Bytecode and ABI?**
    *   *Answer*: Bytecode is the machine code on the EVM; ABI is the JSON interface for human/frontend interaction.
2.  **Why is testing more critical in Web3 than in Web2?**
    *   *Answer*: Immutability. Bugs on mainnet are permanent and often involve direct financial value.
3.  **Name the current standard Ethereum testnet.**
    *   *Answer*: Sepolia.
4.  **Explain the role of Foundry in a DevOps workflow.**
    *   *Answer*: Compilation, rapid testing in Solidity, and deployment orchestration.
5.  **What is 'Contract Verification' on Etherscan?**
    *   *Answer*: Matching source code to on-chain bytecode for transparency and interaction.

### 🤖 Tier 2: Automation & Security
6.  **How do you securely manage Private Keys in CI/CD?**
    *   *Answer*: Use GitHub Secrets for Testnets and Cloud KMS (AWS/GCP) for Production.
7.  **What is 'Fuzz Testing' (Foundry Invariants)?**
    *   *Answer*: Generating thousands of random inputs to break logic and find edge cases.
8.  **Compare Hardhat vs. Foundry for a new project.**
    *   *Answer*: Hardhat is plugin-rich and uses JS; Foundry is Rust-fast and uses Solidity for tests.
9.  **Explain 'Slither' and its place in the pipeline.**
    *   *Answer*: A static analyzer that finds vulnerabilities like Reentrancy during the CI stage.
10. **What is 'Mainnet Forking' and why do we use it?**
    *   *Answer*: Local simulation of the entire mainnet state to test against real protocol interactions.

### 🏗️ Tier 3: Architect Level
11. **Explain the 'Checks-Effects-Interactions' pattern.**
12. **How would you implement an 'Emergency Pause' mechanism in a contract?**
13. **What is an 'Upgradeable Proxy' and how does it bypass immutability?**
14. **Describe a scenario where 'Gas Snapshotting' in CI would save a project money.**
15. **How do you handle 'Chain Reorgs' in your deployment scripts?**

---

# 📝 The Blockchain Architect Exam (Self-Assessment)

<details>
<summary><b>1. Which file contains the function signatures needed for interaction?</b></summary>
The **ABI** (Application Binary Interface).
</details>

<details>
<summary><b>2. Smart contracts have a size limit of...?</b></summary>
**24KB** (EIP-170). CI should always check this using `forge build --sizes`.
</details>

<details>
<summary><b>3. True or False: Adding a private key to .gitignore makes it safe for production.</b></summary>
**False**. It prevents accidental commits, but production keys should never exist in plain text on a developer's machine; use an HSM or KMS.
</details>

---

# 🏆 The Final Challenge: The Security Auditor

**Scenario**: You are reviewing a PR where a developer added a new withdrawal function but forgot to use a `nonReentrant` modifier.

**Task**: 
1.  Which tool in your CI would catch this automatically?
2.  Write the one-sentence explanation you would leave on the GitHub PR to explain why this is a high-risk change.

---
### 🏁 Ready for the wild?
Proceed to **[06: Real-Life Scenarios](../06-real-life-scenarios/readme.md)** to see these principles in production.