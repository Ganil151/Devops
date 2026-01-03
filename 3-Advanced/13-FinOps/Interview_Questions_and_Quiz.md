# Enterprise Identity & Specialized Tech: Quiz & Scenarios

---

## 🆔 Identity & Governance Questions

1.  **What is the purpose of AWS Service Control Policies (SCPs)?**
    *   *Answer*: SCPs are used to manage permissions in your organization. They offer central control over the maximum available permissions for all accounts in your organization.
2.  **How do you implement "Least Privilege" for automated tasks?**
    *   *Answer*: Use dedicated Service Accounts or IAM Roles for Tasks (IRSA in K8s) with narrowly scoped policies limited only to required APIs/resources.

---

## 🧠 Specialized Tech Quiz (20+ Questions)

<b>1. What does 'MLOps' stand for?</b>
<details>
<summary>Show Answer</summary>
Answer: Machine Learning Operations
</details>

<b>2. What is 'Continuous Training'</b>
<details>
<summary>Show Answer</summary>
Answer: CT) in ML?** (Automatically retraining models when live data drifts
</details>

<b>3. True/False: A Private Blockchain is more decentralised than Ethereum.</b>
<details>
<summary>Show Answer</summary>
Answer: False
</details>

<b>4. What is a 'Smart Contract'?</b>
<details>
<summary>Show Answer</summary>
Answer: Self-executing code stored on a blockchain
</details>

<b>5. What is 'Landing Zone' in cloud architecture?</b>
<details>
<summary>Show Answer</summary>
Answer: A pre-configured, secure, multi-account AWS/Azure environment
</details>

<b>6. Which AWS tool is used to monitor compliance across accounts?</b>
<details>
<summary>Show Answer</summary>
Answer: AWS Config
</details>

<b>7. What is 'FinOps'?</b>
<details>
<summary>Show Answer</summary>
Answer: Bringing financial accountability to cloud spend
</details>

<b>8. What is 'Unit Economics' in cloud?</b>
<details>
<summary>Show Answer</summary>
Answer: Measuring cost per business metric/transaction
</details>

<b>9. What is 'Prompt Injection'?</b>
<details>
<summary>Show Answer</summary>
Answer: An attack where malicious input tricks an LLM into ignoring its instructions
</details>

<b>10. What is 'Chain of Thought' prompting?</b>
<details>
<summary>Show Answer</summary>
Answer: Breaking a complex prompt into logical, sequential steps for the AI
</details>

<b>11. What is 'MCP'</b>
<details>
<summary>Show Answer</summary>
Answer: Model Context Protocol)?** (A standard for connecting local data/tools to LLMs
</details>

<b>12. Which cloud model gives you the most control?</b>
<details>
<summary>Show Answer</summary>
Answer: IaaS
</details>

<b>13. What is 'Serverless'?</b>
<details>
<summary>Show Answer</summary>
Answer: Building/running apps without managing server infrastructure
</details>

<b>14. What is 'Multi-Region' architecture?</b>
<details>
<summary>Show Answer</summary>
Answer: Deploying an app across two or more physical cloud regions
</details>

<b>15. What is 'RTO'</b>
<details>
<summary>Show Answer</summary>
Answer: Recovery Time Objective)?** (Target time to restore service after a disaster
</details>

<b>16. What is 'RPO'</b>
<details>
<summary>Show Answer</summary>
Answer: Recovery Point Objective)?** (Maximum acceptable amount of data loss
</details>

<b>17. What is 'Cloud Custodian'?</b>
<details>
<summary>Show Answer</summary>
Answer: Policy-as-code for infra governance
</details>

<b>18. What is 'Web3'?</b>
<details>
<summary>Show Answer</summary>
Answer: Decentralized web powered by blockchain
</details>

<b>19. What is a 'Model Registry'?</b>
<details>
<summary>Show Answer</summary>
Answer: Centralized store for tracking and versioning ML models
</details>

<b>20. What is 'Edge Computing'?</b>
<details>
<summary>Show Answer</summary>
Answer: Processing data closer to the source rather than in a central cloud
</details>

<b>21. True/False: FinOps is only about cutting costs.</b>
<details>
<summary>Show Answer</summary>
Answer: False
</details>


---

## 🏗️ Real-Life Scenarios

### Scenario 1: The Multi-Account Audit
**Problem**: An auditor requested a list of all AWS resources with "Public" access across 50 different sub-accounts.
**Solution**: Used **AWS Config Aggregator** to pull compliance data into a central security account, generating the report in minutes instead of weeks.

### Scenario 2: The ML Model Drift
**Problem**: A price-prediction model started giving inaccurate results as market conditions changed.
**Solution**: The **MLOps pipeline** detected "Data Drift" (live data vs training data). It automatically triggered a retraining job with the new data and redeployed the updated model via GitOps.

### Scenario 3: The FinOps Surprise
**Problem**: A development team accidentally left a massive G5-type instance running over the weekend, costing $500.
**Solution**: Implemented a **Cloud Custodian** policy that terminates any instance without a "Production" tag every Friday at 7 PM.