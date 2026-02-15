# 🕵️ 03: Security & Analysis

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Testing & Testnets ➡️](../04-testing-and-testnets/readme.md)**

---

# 🛡️ Trust, but Formally Verify

Security is not a feature in Web3; it is the **foundation**. If your contract logic fails, there is no "Technical Support" to reverse the transaction. This module covers the tools used to find vulnerabilities before they are exploited.

## 🔍 Static Analysis (Slither)

Static analysis scans your source code for dangerous patterns without actually running it. 

### Slither Core Capabilities:
- **Detection**: Finds Reentrancy, Shadowing, and Uninitialized Variables.
- **Reporting**: Generates visual dependency graphs and inheritance trees.
- **CI Integration**: Fail your GitHub Actions if Slither finds "High" risk items.

```bash
# Run slither on the current project
slither .

# Run and ignore libraries
slither . --exclude-dependencies
```

---

## 🧪 Fuzz Testing (Foundry Invariants)

Standard unit tests check "Happy Paths." **Fuzzing** checks the "Impossible Paths."

- **Invariants**: You define a rule that must *always* be true (e.g., `totalDeposit == sum(userBalances)`).
- **The Engine**: Foundry will generate 10,000+ random transactions to try and find a sequence that breaks your rule.

---

## 📜 High-Level Security Checklist

1.  **Checks-Effects-Interactions (CEI)**: Always update your internal status *before* sending money out.
2.  **Access Control**: Ensure only the `owner` can call sensitive functions (using OpenZeppelin `Ownable`).
3.  **Audit History**: Never deploy un-audited code to Mainnet. 
4.  **Bytecode Verification**: Provenance is key. Verify your code on Etherscan.

---

## 📂 Project Structure

Check out the `src/` directory for security examples:
- `VulnerableBank.sol`: A contract containing a classic **Reentrancy** bug.
- `SecureBank.sol`: The corrected version using the CEI pattern and OpenZeppelin's `ReentrancyGuard`.

---

## 🧪 Security Challenge

**Goal**: Identify and resolve a security vulnerability using Slither.

1.  Install Slither (`pip install slither-analyzer`).
2.  Run Slither on the `src/VulnerableBank.sol` file.
3.  Analyze the output. What color is the Reentrancy warning?
4.  Apply the fix from `SecureBank.sol` and run Slither again. Did the warning disappear?

---
### 🏁 Continue the Journey
Proceed to **[04: Testing & Testnets](../04-testing-and-testnets/readme.md)**.
