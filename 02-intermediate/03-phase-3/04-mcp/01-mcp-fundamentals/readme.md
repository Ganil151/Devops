# 01: MCP Fundamentals

**[⬅️ Back to MCP Module Index](../readme.md)** | **[Next: Building MCP Servers ➡️](../02-building-mcp-servers/readme.md)**

---

# 📖 Model Context Protocol (MCP) Fundamentals

The **Model Context Protocol (MCP)** is an open-standard specifications that solves the "Last Mile" problem of AI: connecting Large Language Models (LLMs) to the systems they need to control. It is a universal protocol that standardizes how AI assistants discover, read, and interact with data and tools.

> **Analogy**: Think of MCP as "USB for AI". Just as USB allows any peripheral (mouse, keyboard, drive) to plug into any computer without custom drivers, MCP allows any AI model to "plug in" to any data source or tool (Postgres, GitHub, Slack, Kubernetes) without custom integrations.

---

## 🎯 Learning Objectives

By the end of this module, you will be able to:
*   **Define** the three primary roles in MCP architecture: Host, Client, and Server.
*   **Differentiate** between the key primitives: Resources, Tools, and Prompts.
*   **Explain** the transport mechanisms (Stdio vs. SSE) and when to use each.
*   **Understand** the JSON-RPC 2.0 foundation of the protocol.
*   **Articulate** why MCP is critical for moving from "Chatbots" to "Agentic Systems" in DevOps.

---

## 🏗️ Core Architecture Deep Dive

MCP operates on a client-server architecture, but with a unique twist: the "User" interacts with a **Host**, which contains the **Client**.

### The Components

1.  **MCP Host**: The application the human users interface with.
    *   *Examples*: Claude Desktop, Cursor IDE, VS Code, or a custom internal CLI tool.
    *   *Role*: It provides the UI and the "Brain" (the LLM).
2.  **MCP Client**: The protocol implementation within the Host.
    *   *Role*: It maintains 1:1 connections with servers, routing the LLM's requests to the correct tool.
3.  **MCP Server**: A lightweight executable or gateway.
    *   *Role*: It wraps a specific data source or toolset. It does **not** contain an LLM. It simply says, "Here are the tools I have, and here is how you use them."
4.  **Local Resource**: The actual data or system being managed.
    *   *Examples*: A PostgreSQL database, a Kubernetes Cluster, the local filesystem, or the AWS CLI.

### Architectural Diagram

```mermaid
graph TD
    subgraph "User Environment"
        User[👤 User] --> Host[🖥️ MCP Host (e.g., Cursor/Claude)]
        
        subgraph "Protocol Layer"
            Host --> Client[🔌 MCP Client]
        end
    end

    subgraph "Local or Remote Infrastructure"
        Client <== "JSON-RPC (Stdio/SSE)" ==> Server1[📦 Git MCP Server]
        Client <== "JSON-RPC (Stdio/SSE)" ==> Server2[☸️ Kubernetes MCP Server]
        Client <== "JSON-RPC (Stdio/SSE)" ==> Server3[🐘 Postgres MCP Server]
    end

    Server1 --> git[git CLI]
    Server2 --> k8s[K8s API]
    Server3 --> db[SQL Database]
    
    style Host fill:#f9f,stroke:#333,stroke-width:2px
    style Server1 fill:#bbf,stroke:#333,stroke-width:2px
    style Server2 fill:#bbf,stroke:#333,stroke-width:2px
    style Server3 fill:#bbf,stroke:#333,stroke-width:2px
```

---

## 🧩 The Three Primitives

MCP standardizes interaction into three distinct capabilities. An MCP server can implement any or all of these.

### 1. Resources (The "Eyes")
Resources are **data** that the AI can read. They are like file attachments, but dynamic.
*   **Purpose**: Giving the LLM context.
*   **Mechanism**: The server exposes a URI (e.g., `postgres://users/schema`). The LLM can "read" this resource to see the table schema.
*   **DevOps Use Case**:
    *   `logs://prod/app-server-1/latest`: Reading real-time logs.
    *   `k8s://pods/default/nginx-pod`: Reading a Pod's YAML configuration.

### 2. Tools (The "Hands")
Tools are **functions** the AI can execute.
*   **Purpose**: Taking action.
*   **Mechanism**: The server exposes a JSON Schema for a function (e.g., `restart_service(service_name: string)`). The LLM calls this tool, the server executes it, and returns the result.
*   **DevOps Use Case**:
    *   `deploy_revision(version: "v1.2.0")`: Triggering a deployment.
    *   `scale_cluster(nodes: 5)`: Scaling infrastructure.

### 3. Prompts (The "Instructions")
Prompts are **templates** embedded in the server.
*   **Purpose**: Standardizing workflows.
*   **Mechanism**: A server can offer a prompt explicitly designed for its tools.
*   **DevOps Use Case**:
    *   A "Debug Incident" prompt that automatically pulls `logs` resources and calls `health_check` tools when activated.

---

## 🔌 Transport Layers

How do the Client and Server actually talk? MCP defines two main transport types:

| Transport | Description | Best For |
| :--- | :--- | :--- |
| **Stdio** | Standard Input/Output. The Client launches the Server as a subprocess and talks via `stdin`/`stdout`. | Local tools, extensive security isolation, private servers running on a developer's laptop. |
| **SSE (Server-Sent Events)** | HTTP based. The Client connects to a URL endpoint. | Remote servers, shared tools in a team environment, cloud-hosted agents. |

> **Note**: For almost all local DevOps workflows (like controlling Docker or local K8s), **Stdio** is the preferred method because it inherits the user's local authentication and permissions (e.g., `~/.kube/config` or `~/.aws/credentials`).

---

## 📜 Protocol Logic (JSON-RPC)

Under the hood, MCP uses **JSON-RPC 2.0**. It's stateless and asynchronous.

**Example: Listing Tools Request**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list",
  "params": {}
}
```

**Example: Server Response**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "tools": [
      {
        "name": "check_disk_space",
        "description": "Checks available disk space on the host",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": { "type": "string" }
            }
        }
      }
    ]
  }
}
```

---

## 📖 Real-World Story: The "SRE Sidekick"

**The Situation**:
At *TechCorp*, on-call engineers dreaded getting alerted at 3 AM. They would have to SSH into a bastion host, run `kubectl get pods`, grep logs, check Datadog, and finally restart a service. The context switching was brutal.

**The Solution**:
The Platform Engineering team built a **Kubernetes MCP Server**.
1.  They installed the MCP Server locally on every engineer's laptop.
2.  The engineer opens their AI IDE (Host) and simply types: *"The payments service is throwing 500s. Investigate."*
3.  The **Resource** primitive pulls the last 100 lines of logs.
4.  The AI analyzes them and sees a memory leak.
5.  The AI proposes using the **Tool** `restart_deployment(name="payments")`.
6.  The engineer clicks "Approve".

**The Outcome**:
MTTR (Mean Time To Resolution) dropped by 60%. Engineers no longer had to remember complex kubectl syntax at 3 AM; the AI handled the syntax, while the human handled the decision.

---

## 🚦 Knowledge Check

**1. Which component actually contains the LLM (Large Language Model)?**
*   [ ] The MCP Server
*   [ ] The MCP Client/Host
*   [ ] The Resource
*   [ ] The Transport Layer

**2. Which primitive would you use to let the AI read a configuration file?**
*   [ ] Tool
*   [ ] Prompt
*   [ ] Resource
*   [ ] Stdio

**3. Why is Stdio transport preferred for local DevOps tasks?**
*   [ ] It is faster over the network.
*   [ ] It supports more users.
*   [ ] It inherits the local user's security credentials and permissions.
*   [ ] It works better with Python.

---

## 🙋 Interview Preparation

**Q: Can an MCP Server initiate an action on its own?**
> **A:** No. MCP is client-driven. The Server waits for a request from the Client (driven by the LLM/User). However, servers can send notifications (like log updates) if the client has subscribed to a resource.

**Q: How does MCP handle security?**
> **A:** MCP isolates the prompt injection risk. The AI cannot reach *outside* the tools exposed by the MCP server. If the server only exposes `read_logs` and NOT `delete_database`, no amount of "jailbreaking" the LLM can cause it to delete the database. The security boundary is code, not just a system prompt.

**Q: Compare MCP to OpenAI Actions/Plugins.**
> **A:** OpenAI Actions are proprietary and tied to the ChatGPT ecosystem. MCP is an open standard that works with Claude, IDEs, and any other conforming client, allowing "write once, run anywhere" for tool definitions.

