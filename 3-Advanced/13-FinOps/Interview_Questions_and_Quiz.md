# Enterprise Identity & Specialized Tech: Quiz & Scenarios

---

## 🆔 Identity & Governance Questions

1.  **What is the purpose of AWS Service Control Policies (SCPs)?**
    *   *Answer*: SCPs are used to manage permissions in your organization. They offer central control over the maximum available permissions for all accounts in your organization.
2.  **How do you implement "Least Privilege" for automated tasks?**
    *   *Answer*: Use dedicated Service Accounts or IAM Roles for Tasks (IRSA in K8s) with narrowly scoped policies limited only to required APIs/resources.

---

## 🧠 Specialized Tech Quiz (20+ Questions)

1.  **What does 'MLOps' stand for?** (Machine Learning Operations)
2.  **What is 'Continuous Training' (CT) in ML?** (Automatically retraining models when live data drifts)
3.  **True/False: A Private Blockchain is more decentralised than Ethereum.** (False)
4.  **What is a 'Smart Contract'?** (Self-executing code stored on a blockchain)
5.  **What is 'Landing Zone' in cloud architecture?** (A pre-configured, secure, multi-account AWS/Azure environment)
6.  **Which AWS tool is used to monitor compliance across accounts?** (AWS Config)
7.  **What is 'FinOps'?** (Bringing financial accountability to cloud spend)
8.  **What is 'Unit Economics' in cloud?** (Measuring cost per business metric/transaction)
9.  **What is 'Prompt Injection'?** (An attack where malicious input tricks an LLM into ignoring its instructions)
10. **What is 'Chain of Thought' prompting?** (Breaking a complex prompt into logical, sequential steps for the AI)
11. **What is 'MCP' (Model Context Protocol)?** (A standard for connecting local data/tools to LLMs)
12. **Which cloud model gives you the most control?** (IaaS)
13. **What is 'Serverless'?** (Building/running apps without managing server infrastructure)
14. **What is 'Multi-Region' architecture?** (Deploying an app across two or more physical cloud regions)
15. **What is 'RTO' (Recovery Time Objective)?** (Target time to restore service after a disaster)
16. **What is 'RPO' (Recovery Point Objective)?** (Maximum acceptable amount of data loss)
17. **What is 'Cloud Custodian'?** (Policy-as-code for infra governance)
18. **What is 'Web3'?** (Decentralized web powered by blockchain)
19. **What is a 'Model Registry'?** (Centralized store for tracking and versioning ML models)
20. **What is 'Edge Computing'?** (Processing data closer to the source rather than in a central cloud)
21. **True/False: FinOps is only about cutting costs.** (False)

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
