# 🧪 K8s & Cloud MCP Challenges

Take your agentic infrastructure skills to the next level with these hands-on and architectural challenges.

---

## ☸️ Challenge 1: The CrashLoop Detective
**Scenario**: A deployment named `api-server` in the `production` namespace is stuck in `CrashLoopBackOff`. 

**Task**: Using only natural language via your AI Host (connected to the K8s MCP server):
1.  Locate the problematic pod.
2.  Extract the logs from the last 100 lines.
3.  Identify the error (e.g., Missing Env Var, Database Connection Refused).
4.  Propose the exact `kubectl patch` command to fix it.

---

## ☁️ Challenge 2: AWS Security Auditor
**Scenario**: You suspect there are open SSH ports (22) to the world (0.0.0.0/0) in your AWS account.

**Task**: Extend the `k8s_mcp_server.py` concept to AWS:
1.  Define a tool named `audit_security_groups`.
2.  The tool should use `boto3` to describe security groups.
3.  Filter for any group that allows ingress on port 22 from anywhere.
4.  Standardize the output for the AI to easily parse.

---

## 🛡️ Challenge 3: Guardrail Design
**Scenario**: Your manager is worried that the AI might accidentally delete the production EKS cluster if the MCP server has `ClusterAdmin` permissions.

**Task**: Propose a "Safety First" configuration:
1.  What Kubernetes **RBAC Role** would you create specifically for the MCP server?
2.  How would you configure the MCP server to ensure it *never* allows a `delete` operation on specific namespaces?
3.  Explain the concept of **Human-in-the-Loop** and how it applies to this scenario.

---

## 🚀 Challenge 4: Multi-Cloud Master
**Scenario**: Your company uses both AWS and GCP. You want a single AI assistant that can help with both.

**Task**:
1.  Describe how you would configure your `claude_desktop_config.json` to handle multiple MCP servers (one for AWS, one for GCP).
2.  How does the AI Host know which server to talk to when you ask: *"Show me the status of my cloud instances"*?

---
### 🏁 Ready for the next stage?
Once you've explored these challenges, move on to **[04: Security and Auth](../04-security-and-auth/readme.md)** to learn how to lock down your agentic systems.
