# 🧪 04: Testing & Testnets

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Interview Mastery ➡️](../05-interview-questions-and-quizzes/readme.md)**

---

# 🌍 Real-World Validation

Blockchain testing moves from internal unit tests to high-fidelity **Mainnet Forks** and public **Testnets**. This module ensures your code behaves correctly when interacting with other protocols (like Uniswap or Aave).

## 🍴 The Power of Forking

**Fork Testing** is the secret weapon of Blockchain DevOps. It allows you to create a local copy of the entire Ethereum mainnet state at a specific block.

- **Why**: You can test how your contract interacts with real liquidity and real protocols without spending $1.
- **Tooling**: Foundry's `forge test --fork-url <RPC_URL>` is the fastest implementation of this pattern.

---

## 🏗️ Public Testnets: The Final Stage

Before the "Main Event" (Mainnet), you must deploy to a public Testnet.

1.  **Sepolia**: The current gold standard. Fast, reliable, and separate from Mainnet state.
2.  **Holesky**: Ideal for testing validator infrastructure and large-scale deployments.
3.  **Amoy (Polygon)**: For layer-2 enthusiasts.

---

## 🚰 Faucet Hygiene

To deploy, you need **Test ETH**. Since it is free but limited, follow these rules:
- **Don't Hiss**: Only take what you need for the deployment.
- **Use Multi-Faucets**: Alchemy, Infura, and Sepolia-PoW are reliable sources.
- **Automate**: For CI/CD, use a persistent Testnet account with a small balance rather than requesting from a faucet every time.

---

## 📂 Project Structure

Check out the `src/` directory for testing examples:
- `ForkTest.t.sol`: A advanced Foundry test showing how to "Fork" the real Ethereum mainnet and interact with the **WETH** contract.

---

## 🧪 Testing Challenge

**Goal**: Run your first Mainnet Fork test.

1. Get a free RPC URL from [Alchemy](https://alchemy.com) or [Infura](https://infura.io).
2. Run the command:
   ```bash
   forge test --match-path src/ForkTest.t.sol --fork-url <YOUR_RPC_URL>
   ```
3. Why does the test fail if you don't provide a `--fork-url`? 
4. How would you "cheat" in this test to give yourself 1000 ETH using Foundry's `vm.deal` cheatcode?

---
### 🏁 Finishing Up
You've mastered the lifecycle! Proceed to **[05: Interview Mastery](../05-interview-questions-and-quizzes/readme.md)** to prepare for your career.
