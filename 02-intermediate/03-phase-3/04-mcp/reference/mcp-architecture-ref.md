# Model Context Protocol (MCP) Architecture & Standards Reference

**Doc Version:** 1.0.0
**Role:** AI Operations Engineer / Platform Architect
**Scope:** MCP Standards, Toolsets, and Agentic Safety

---

## 1. The MCP Three-Tier Model

The Model Context Protocol (MCP) defines a standardized way for AI models to interact with data and tools.

- **The Host**: The application where the LLM resides (e.g., Claude Desktop, IDE extensions, or a custom wrapper).
- **The Client**: The component inside the Host that initiates requests and handles the transport.
- **The Server**: The service that provides specific capabilities (Tools, Resources, and Prompts).

**Mechanism**: The Client and Server communicate via **JSON-RPC 2.0** over a transport layer like Standard Input/Output (stdio) or Server-Sent Events (SSE).

---

## 2. Server Primitives: Tools, Resources, and Prompts

MCP servers expose three primary types of interfaces to the LLM:

- **Tools (Action)**: Executable functions that allow the AI to *do* something (e.g., `run_kubectl_command`, `read_log_file`).
- **Resources (Data)**: Static or dynamic data the AI can *read* (e.g., `cluster_config`, `system_metrics`).
- **Prompts (Context)**: Pre-defined templates that guide the AI's behavior for specific tasks (e.g., `debug_outage_template`).

---

## 3. The "Agentic" DevOps Workflow

MCP enables **Agentic Workflows** where the AI moves from "Answering Questions" to "Solving Problems."

1.  **Investigation**: AI uses *Resources* to read the current system state (e.g., pod logs).
2.  **Reasoning**: AI applies logic (using Chain-of-Thought) to identify the root cause.
3.  **Proposal**: AI uses a *Prompt* to generate a fix (e.g., a YAML patch).
4.  **Action**: AI uses a *Tool* to apply the fix (after human approval).

---

## 4. Visualizing the MCP Loop

```mermaid
graph LR
    User[User / SRE] --> Host[Host: AI Interface]
    Host --> Client[Client]
    Client --> Server[MCP Server]
    Server --> Infra[Infrastructure: K8s / Cloud]
    
    style Server fill:#4285f4,color:#fff
    style Infra fill:#00b894,color:#fff
```

---

## 5. Security and Governance (AI Safety)

Granting an AI access to infrastructure requires extreme caution.

- **Human-in-the-Loop (HITL)**: Mandatory manual approval for any tool execution that mutates the system state (e.g., `apply`, `delete`, `terminate`).
- **Zero-Trust Identity**: The MCP server should use its own restricted IAM role/ServiceAccount with the minimum permissions needed for its specific tools.
- **Input Sanitization**: The MCP server must validate and sanitize all inputs provided by the LLM to prevent "Prompt Injection" attacks against the infrastructure.
- **Audit Logging**: Every action taken by the AI assistant via MCP must be logged with the full context (Prompt, Reasoning, Command, Result, and Approver).

---

## 6. Enterprise Integration Patterns

- **Sidekick Servers**: Deploying a specialized MCP server for each domain (e.g., a 'FinOps Server', a 'Security Server', a 'Kubernetes Server').
- **Standardized Toolsets**: Defining a corporate library of "Safe Tools" that any internal AI assistant can use.
- **Discovery**: Using Centralized Server Directories so that different AI agents can find and connect to the tools they need.

> **Enterprise Pattern**: Implement **Read-Only Discovery**. In the 'Investigation' phase, the AI can have broad read access via MCP *Resources*. However, the moment it attempts to invoke a *Tool* that changes state, the system must trigger a formal approval workflow in Slack or Jira.
