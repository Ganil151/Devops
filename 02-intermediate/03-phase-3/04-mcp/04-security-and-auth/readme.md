# 04: Security & Authorization for AI Agents

**[⬅️ Back to MCP Module Index](../readme.md)** | **[Next: Interview Questions ➡️](../05-interview-questions-and-quizzes/readme.md)**

---

# 🛡️ Hardening the AI Nervous System

Connecting an LLM to your infrastructure bridges the gap between intelligence and action, but it also creates a new attack surface. This module covers the **Defense-in-Depth** strategies required to ensure your AI assistant represents an asset, not a liability.

## 🛑 The UX Defense: Human-in-the-Loop (HITL)

The most robust security in MCP is not a firewall; it is the **Approval Paradox**. By default, the protocol requires a client-side acknowledgment for actions.

### The HITL Lifecycle:
1.  **AI Request**: Machine generates a tool call JSON.
2.  **Interception**: The Host (Claude/Cursor) halts execution.
3.  **Human Validation**: You review the target, arguments, and intent.
4.  **Authorized Execution**: The server only receives the request **after** your manual click.

---

## 🦠 Modern Threats to Agentic Systems

| Threat | The "Junior" Trap | The "Architect" Defense |
| :--- | :--- | :--- |
| **Prompt Injection** | AI reads a malicious log file and "hallucinates" a delete command. | **Structured Inputs**. We pass objects/IDs, never raw CLI strings. |
| **Path Traversal** | AI tries to read `../../etc/shadow`. | **Strict Sanitization**. Use `os.path.abspath` and prefix checks. |
| **Hallucination** | AI invents a `--force` flag on a tool that doesn't support it. | **Schema Enforcement**. The MCP Host validates args against the server's spec first. |
| **Blast Radius** | AI has ClusterAdmin rights. | **Least Privilege**. The MCP server process uses a scoped IAM/K8s Role. |

---

## 📂 Project Structure

```text
04-security-and-auth/
├── readme.md
├── challenges.md        # Security auditing scenarios
└── src/
    ├── guardian_server.py # Multi-layer validation example
    └── requirements.txt
```

---

## 👷 Architectural Guardrails

### 1. The "Sandbox" Pattern
Always scope your server to a specific subdirectory.
> **Example**: See the `is_safe_path` implementation in **`src/guardian_server.py`**.

### 2. No Shell Execution
**BAD code (Vulnerable to injection):**
```python
subprocess.run(f"check_service {service_name}", shell=True)
```
**GOOD code (Secure):**
```python
subprocess.run(["check_service", service_name], shell=False)
```

### 3. Read-Only Baseline
Start every SRE assistant as a **Read-Only** agent. Only promote specific tools to "Write" access after rigorous testing and with mandatory HITL controls.

---

## 📋 The Production Readiness Checklist

Before any MCP server is deployed to your team's configuration:
- [ ] **Static Analysis**: Verify no `eval()` or `os.system()` calls are present.
- [ ] **Input Sanitization**: Ensure all tool arguments are validated against regex or enums.
- [ ] **Credential Safety**: Does the server handle creds securely (via env vars) or just leak them?
- [ ] **Isolation**: Is the server running in a container with a non-root user?

---

## 🧪 Experience the Challenges
Think you can break our "Guardian" server? Try your hand at the **[Security Challenges](./challenges.md)** and see if your defenses hold up.
