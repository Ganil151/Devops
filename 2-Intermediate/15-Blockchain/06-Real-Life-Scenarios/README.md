# 06: Real-Life Scenarios

Explore how Blockchain DevOps principles are applied to real-world Web3 challenges.

## 🛠️ Scenario 1: Preventing a Reentrancy Hack in CI
**Context**: A developer is adding a new "Withdraw" function to a DeFi lending contract. They accidentally put the state update *after* the external call, creating a Reentrancy vulnerability.
**Challenge**: Catch the bug before it reaches the public testnet.
**Solution**:
1. **CI Integration**: The GitHub Actions pipeline runs **Slither** on every pull request.
2. **Detection**: Slither detects the Reentrancy vulnerability and flags the PR with a "HIGH" severity error.
3. **Prevention**: The CI job fails, preventing the code from being merged or deployed. The developer receives a report pointing directly to the unsafe line of code.

---

## 📈 Scenario 2: Emergency "Hotfix" for an Upgradeable Contract
**Context**: A critical bug is found in an already deployed "Proxy" contract on Mainnet that prevents users from swapping tokens.
**Challenge**: Deploy a fix and upgrade the proxy as quickly and safely as possible.
**Solution**:
1. **Preparation**: Use a pre-built **Upgrade Script** in Foundry to deploy the new implementation contract.
2. **Testing**: Run the upgrade locally against a **Mainnet Fork** to ensure the new logic works with the existing state (storage layout).
3. **Execution**: Deploy the new implementation to Mainnet.
4. **Governance**: Use the team's **Multisig (Gnosis Safe)** to call the `upgradeTo()` function on the proxy, pointing it to the new implementation.

---

## 🔑 Scenario 3: Secure Zero-Downtime Deployment
**Context**: You need to deploy a suite of 10 interconnected smart contracts (e.g., an NFT Marketplace). If one fails to deploy or verify, the whole system is broken.
**Challenge**: Ensure an atomic-like deployment and verification process.
**Solution**:
1. **Automation**: Use a **Foundry Script** that orchestrates the deployment order and captures the addresses of deployed contracts.
2. **Validation**: The script includes checks to ensure each contract is properly initialized.
3. **Verification**: After deployment, the script automatically triggers the `forge verify-contract` command for all 10 contracts using the Etherscan API key stored in GitHub Secrets.

---

## 🏗️ Scenario 4: Managing Faucets for Large-Scale Testing
**Context**: Your QA team needs to run 100 end-to-end tests every day on the Sepolia testnet, requiring 10 ETH in gas fees per week. Most faucets only give 0.5 ETH per day.
**Challenge**: Sustain the testing environment without manual faucet hunting.
**Solution**:
1. **Management**: Create a "Faucet Account" that collects ETH from multiple sources.
2. **Distribution**: Use a script to distribute small amounts of test ETH to individual "Worker" accounts used by the CI pipeline.
3. **Optimization**: Optimize the contracts to use less gas and use a private "Devnet" (like Anvil) for 90% of the tests, only using the public testnet for the final "Pre-flight" check.

---

## ⚡ Scenario 5: Handling a "Chain Reorg" in CI/CD
**Context**: Your deployment script reported success, but 5 minutes later, the transaction "disappeared" because of a blockchain reorganization (reorg).
**Challenge**: Ensure the deployment is actually finalized before proceeding with frontend updates.
**Solution**:
1. **Confirmation**: Update the deployment script to wait for **12+ confirmations** (on Ethereum) before considering the transaction "Success".
2. **Verification Loop**: Add a step in the pipeline that queries the chain 10 minutes after deployment to verify the contract bytecode is still present at the expected address.
3. **Idempotency**: Ensure the deployment script is idempotent so it can be safely re-run if it fails due to a reorg.
