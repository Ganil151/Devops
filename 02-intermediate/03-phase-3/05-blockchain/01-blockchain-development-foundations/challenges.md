# 🧪 Foundation Challenges: Your First Blocks

These challenges will walk you through the compilation and interaction phase of a smart contract.

---

## 🏗️ Challenge 1: The Compiler's Eye
**Scenario**: You have a smart contract `Counter.sol`. You need to generate the artifacts.

**Task**:
1.  Review `src/Counter.sol`.
2.  If you have Foundry installed, run `forge build`.
3.  Locate the `out/Counter.sol/Counter.json` file.
4.  Identify the `abi` and `bytecode` fields in the JSON. Explain why the `bytecode` is so much larger than the `abi`.

---

## 🛠️ Challenge 2: Local Deployment
**Scenario**: You need to test the contract on a local node.

**Task**:
1.  Start a local Ethereum node using `anvil` (Foundry) or `npx hardhat node`.
2.  Deploy the `Counter` contract to your local node.
3.  Note the **Contract Address**.
4.  Why does the contract address change if you redeploy it from a different wallet?

---

## 🧪 Challenge 3: Test-Driven Development (TDD)
**Scenario**: We need to add a `decrement` function to our `Counter` contract.

**Task**:
1.  Open `src/Counter.sol`.
2.  Add a function `decrement()` that reduces `number` by 1.
3.  Update `src/Counter.t.sol` to include a test called `testDecrement()`.
4.  Ensure it handles **Underflow** (what happens if `number` is 0 and you decrement it in Solidity 0.8+?).

---

## 🛡️ Challenge 4: Gas Auditor
**Scenario**: Every update to the blockchain costs money (Gas).

**Task**:
1.  Run `forge test --gas-report`.
2.  Which function in `Counter.sol` is the most expensive to run?
3.  Why is `setNumber` generally more expensive than `increment` if the number being set is very large?

---
### 🏁 Done?
When you've finished these, proceed to **[02: Smart Contract CI/CD](../02-smart-contract-ci-cd/readme.md)**.
