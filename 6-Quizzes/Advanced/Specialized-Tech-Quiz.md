# 🏛️ Quiz: Advanced Specialized Tech (Intelligence, Identity & Scale)

Test your knowledge on the frontier of DevOps: MLOps, Blockchain Infrastructure, and AI-Agent Orchestration.

---

## 🤖 Section 1: AI-Ops & MLOps

1. **What is "Feature Store" in an MLOps pipeline?**
   - A) A directory where Docker images are stored.
   - B) A centralized repository for storing and managing curated data features for training.
   - C) A retail shop for AI hardware.
   - D) A type of database only for text files.

2. **In MLOps, what does "Model Drift" refer to?**
   - A) The physical movement of servers in a rack.
   - B) The degradation of predictive performance due to changes in real-world data distributions.
   - C) Upgrading a model from Python 2 to Python 3.
   - D) A load balancing strategy.

---

## ⛓️ Section 2: Blockchain & Web3 Ops

3. **What is the primary role of a "Validator Node" in a Proof-of-Stake network?**
   - A) To mine Bitcoin using GPU energy.
   - B) To verify transactions and propose new blocks to the ledger.
   - C) To act as a NAT gateway.
   - D) To host static websites.

4. **Which security measure is CRITICAL for managing a validator node?**
   - A) Disabling the firewall entirely.
   - B) Using a **Hardware Security Module (HSM)** or Remote Signer to protect private keys.
   - C) Storing private keys in the Docker image.
   - D) Allowing public SSH access for debugging.

---

## 🕵️ Section 3: Identity & Zero Trust

5. **What is SPIFFE/SPIRE primarily used for in a Service Mesh?**
   - A) To increase network throughput by 500%.
   - B) To provide cryptographically secure identities to every workload in the cluster.
   - C) To replace Jenkins with a faster tool.
   - D) To manage cloud billing.

6. **What is the "Zero Trust" security model?**
   - A) A model where no users are allowed on the network.
   - B) A strategy that assumes "breach is inevitable" and requires strict verification for every request, regardless of origin.
   - C) A system where antivirus software is removed.
   - D) A cloud provider that charges $0 for security.

---

## 🧠 Section 4: Model Context Protocol (MCP)

7. **What is the Model Context Protocol (MCP)?**
   - A) A new way to encrypt hard drives.
   - B) A standardized protocol allowing safe, bidirectional communication between AI agents and local/remote tools/data.
   - C) A replacement for the TCP/IP protocol.
   - D) A standard for training large language models.

---

## 🏗️ Real-World Scenario: The Agentic SRE
You are deploying an AI Agent to monitor your production cluster. The agent needs to restart pods but should NOT be able to delete namespaces.

**Question**: Which authorization mechanism is most appropriate for the agent's ServiceAccount?
- A) ClusterAdmin (to ensure it can do everything).
- B) Custom RBAC Role with `verbs: ["update", "patch"]` restricted to pods only.
- C) Storing the root password in the agent's config.
- D) Using a Basic Auth header with `admin:admin`.

---

## 🗝️ Answer Key
1. B
2. B
3. B
4. B
5. B
6. B
7. B

**Scenario Answer**: B (Principle of Least Privilege: only grant the verbs required for the specific task).
