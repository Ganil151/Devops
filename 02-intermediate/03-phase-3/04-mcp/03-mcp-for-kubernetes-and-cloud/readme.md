# 03: MCP for Kubernetes & Cloud Infrastructure

**[⬅️ Back to MCP Module Index](../readme.md)** | **[Next: Security and Auth ➡️](../04-security-and-auth/readme.md)**

---

# ☸️ Scaling Agentic DevOps with Kubernetes & Cloud

The true potential of "Agentic SRE" is unlocked when we bridge the gap between AI reasoning and live infrastructure. This module focuses on connecting MCP to the distributed systems that power modern enterprises: **Kubernetes** and **Cloud APIs**.

## 🏗️ The "Local Gateway" Pattern (Recommended)

For DevOps workflows, the **Local Gateway** is the gold standard for security and speed. Instead of running MCP servers inside the cluster (which complicates networking), we run them **on your laptop**.

### 🌟 Why This Pattern Rules:
1.  **Identity Inheritance**: The MCP server automatically uses your existing `~/.kube/config` and `AWS_PROFILE`. No need to manage secondary service account keys.
2.  **Zero Ingress Required**: The server works as long as you can reach the API (via VPN or Teleport). No public endpoints or complex firewalls.
3.  **Scoped Sessions**: The AI has "eyes" on the cluster only when you, the authorized engineer, are actively working.

---

## 📂 Project Structure

```text
03-mcp-for-kubernetes-and-cloud/
├── readme.md
├── challenges.md        # Hands-on SRE scenarios
└── src/
    ├── k8s_mcp_server.py # Reference Python implementation
    └── requirements.txt  # Project dependencies
```

---

## ☸️ Tool Design: The K8s SRE Helper

A great K8s MCP server doesn't just "expose the API"; it provides **high-level intent**.

| Pattern | MCP Tool Example | Benefit |
| :--- | :--- | :--- |
| **Observability** | `get_pod_logs(name)` | Instant diagnosis without `kubectl logs` syntax hunting. |
| **Inspection** | `describe_deployment(name)` | Seeing replica counts and images in natural language. |
| **Discovery** | `list_crashing_pods(namespace)` | AI can proactively find issues before you ask. |
| **Analysis** | `get_events(resource_type)` | AI correlates events to find root causes for `ImagePullBackOff`. |

> **🚀 PRO-TIP**: View our reference implementation in **`src/k8s_mcp_server.py`** to see how to use the official Kubernetes Python client for these tools.

---

## ☁️ Cloud Bridging (AWS / Azure / GCP)

Cloud MCP servers allow you to query your fleet efficiently. Focus on **Read-Only** auditing first to build trust in the AI's logic.

### Example: The AWS Observer
Using `boto3`, you can create tools that audit your infrastructure:
- `find_untagged_resources()`: Cost control.
- `audit_security_groups()`: Security compliance.
- `list_rds_snapshots()`: Backup verification.

---

## 🛡️ Guardrails: Keeping Production Safe

Giving an AI "Write" or "Delete" access is powerful but requires strict controls.

1.  **Human-in-the-Loop (HITL)**: **NEVER** build a tool that deletes production resources without a manual approval click in the Host UI (Claude/Cursor).
2.  **Dry Runs First**: Implement `get_terraform_plan` or `helm_template` instead of `apply`. Let the AI explain the change before it happens.
3.  **RBAC Scoping**: Ensure the credentials used by your local MCP server are limited to the namespaces or regions you are responsible for.

---

## 🧪 Knowledge Check & Practice

1.  **Q**: Why is it safer to run the MCP server on your local machine?
    - *A: It inherits your local security context and doesn't require permanent, high-privilege service accounts inside the cluster.*
2.  **Q**: What is the most important primitive for an AI trying to fix an outage?
    - *A: Resources (Logs and Metrics) to provide context for diagnosis.*

---

## 🚀 Take the Challenge
Are you ready to be an Agentic SRE? Head over to **[challenges.md](./challenges.md)** to solve real-world infrastructure problems using AI tools.
