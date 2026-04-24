# 🏆 AI/MLOps & AIOps Challenges

Master the integration of Machine Learning and LLMs into the DevOps lifecycle to build self-healing, intelligent infrastructure.

---

## 🏗️ Challenge 01: The "Self-Healing" Log Analyzer
**Objective**: Build an automated RCA (Root Cause Analysis) pipeline using LLMs.

1.  **Requirement**: A service is flapping. Logs show intermittent errors.
2.  **Task**: Create a Python script that:
    *   Tails a local log file.
    *   Detects the keyword `ERROR`.
    *   Sends the last 10 lines to an LLM for analysis.
3.  **Discovery**: How do you prevent the script from sending sensitive data (PII) to the LLM?
4.  **Verification**: Confirm the script outputs a human-readable "remediation plan" to the console.

---

## 📈 Challenge 02: Drift Detection using Prometheus
**Objective**: Detect model performance degradation in Production.

1.  **Scenario**: Your prediction accuracy is dropping because user behavior has changed (Data Drift).
2.  **Task**: Define a Prometheus alert rule that triggers when the `prediction_accuracy_percentage` metric stays below 85% for more than 5 minutes.
3.  **Action**: How would you automate the "Retrain & Redeploy" workflow using a CI/CD webhook?

---

## 🕵️ Challenge 03: MCP (Model Context Protocol) Integration
**Objective**: Safely grant an AI Agent access to your infrastructure.

1.  **Goal**: Use an MCP server to allow a local LLM agent to list pods in your cluster.
2.  **Task**: Configure a `read-only` ServiceAccount for the MCP server.
3.  **Discovery**: Why is the unidirectional communication of MCP safer than granting the AI direct SSH access?
