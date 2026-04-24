# 🎓 05: Interview Mastery & Knowledge Audit

**[⬅️ Back to MCP Module Index](../readme.md)** | **[Next: Real-Life Scenarios ➡️](../06-real-life-scenarios/readme.md)**

---

# 🎤 Top 20 MCP Interview Questions

Prepare for your Next-Gen DevOps role. These questions range from Junior-level fundamentals to Staff-level architectural patterns.

### 🏛️ Tier 1: Fundamentals
1.  **What is the "Last Mile" problem in AI, and how does MCP solve it?**
    *   *Answer*: Standardizing the connection between logic (LLM) and action (Infrastructure APIs).
2.  **Differentiate between a Tool and a Resource.**
    *   *Answer*: Tools are for Mutation (Write/Action); Resources are for Grounding (Read/Context).
3.  **Explain the Host-Client-Server model.**
    *   *Answer*: Host (UI/LLM), Client (Protocol Manager), Server (Capability Provider).
4.  **What is JSON-RPC 2.0 and why was it chosen?**
    *   *Answer*: A lightweight, language-agnostic, and asynchronous communication protocol.
5.  **What happens during the 'Discovery' phase of an MCP session?**
    *   *Answer*: The client requests a list of capabilities, and the server returns its tool/resource schemas.

### 🛡️ Tier 2: Security & Architecture
6.  **Explain 'Human-in-the-Loop' (HITL) in MCP.**
    *   *Answer*: A safety pattern where the AI Host requires manual approval before sending a tool request to the server.
7.  **Why is Stdio the preferred transport for SRE tools?**
    *   *Answer*: Subprocess isolation and inheritance of the local user's security context (Identity).
8.  **How do you prevent 'Prompt Injection' attacks at the server level?**
    *   *Answer*: Strict input validation using JSON Schema and avoiding shell execution (`shell=True`).
9.  **What is the 'Local Gateway' pattern?**
    *   *Answer*: Running the MCP server on the client machine to bridge local credentials to the AI.
10. **Explain 'Context Window management' in the context of MCP.**
    *   *Answer*: Using resources to provide targeted information instead of overfilling the LLM's memory.

### 🚀 Tier 3: Advanced Implementation
11. **What is 'Sampling' and how does it move logic to the Host?**
12. **How would you horizontally scale an MCP server?**
13. **Compare MCP to OpenAI's proprietary 'Actions'.**
14. **How do you debug an MCP server that produces an infinite loop?**
15. **Describe an Agentic Workflow using MCP for incident response.**

---

# 📝 The MCP Architect Exam (Self-Assessment)

<details>
<summary><b>1. Who developed the MCP open standard?</b></summary>
Anthropic (Open Sourced in 2024).
</details>

<details>
<summary><b>2. Which transport is HTTP-based?</b></summary>
SSE (Server-Sent Events).
</details>

<details>
<summary><b>3. A 'destructive' tool call should always require:</b></summary>
User Confirmation / Approval.
</details>

<details>
<summary><b>4. True or False: An MCP server must contain an LLM.</b></summary>
False. It is a lightweight bridge.
</details>

---

# 🏆 The Final Challenge: The Architect's Blueprint

**Scenario**: You need to build an AI assistant that can help developers rotate their own AWS IAM keys.

**Task**: Sketch out the MCP Primitives for this server:
1.  **Resource**: `aws://iam/user-policy` (Read current permissions).
2.  **Tool**: `list_access_keys` (Discovery).
3.  **Tool**: `rotate_access_key` (Action - requires confirmation).
4.  **Prompt**: `rotation-guide` (Template for the AI).

---
### 🏁 Ready to see MCP in Action?
Proceed to **[06: Real-Life Scenarios](../06-real-life-scenarios/readme.md)** to see how these concepts are applied in production environments.