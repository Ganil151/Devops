# 📖 01: MCP Fundamentals

**[⬅️ Back to MCP Module Index](../readme.md)** | **[Next: Building MCP Servers ➡️](../02-building-mcp-servers/readme.md)**

---

# 🧠 Model Context Protocol (MCP) Fundamentals

The **Model Context Protocol (MCP)** is the universal language for AI agents. It standardizes how AI assistants discover, read, and interact with data and tools, solving the "Last Mile" problem of AI: moving beyond chat and into **autonomous operation**.

> **🔌 The "USB" Analogy**: 
> Think of MCP as **USB for AI**. Just as USB allowed any peripheral to plug into any computer without custom drivers, MCP allows any AI model (Claude, GPT, Gemini) to "plug in" to any data source (Postgres, GitHub, Kubernetes, AWS) through a standardized interface.

---

## 🎯 Learning Objectives

By the end of this module, you will master:
- [x] **Architecture**: Understand the Host-Client-Server relationship.
- [x] **Primitives**: Differentiate between **Resources**, **Tools**, and **Prompts**.
- [x] **Transports**: Know when to use **Stdio** vs. **SSE**.
- [x] **Protocols**: Grasp the **JSON-RPC 2.0** foundation.
- [x] **DevOps Impact**: Articulate how MCP shifts us from "Chatbots" to "Agentic SREs".

---

## 🏗️ Core Architecture Deep Dive

MCP uses a unique three-tier model designed for security and local execution.

| Component | Responsibility | Examples |
| :--- | :--- | :--- |
| **🧠 Host** | Orchestrates the LLM and UI. The "Brain". | Claude Desktop, Cursor, VS Code. |
| **🔌 Client** | Manages the protocol connection within the Host. | MCP SDK integration. |
| **📦 Server** | Exposes specific API/Data as tools. The "Hands". | `postgres-mcp`, `github-mcp`. |
| **🏗️ Resource** | The actual system being controlled. | SSH, K8s API, Local SQLite. |

### 🛰️ The "Nervous System" Diagram

```mermaid
graph TB
    subgraph User_Space ["👤 User Control Plane"]
        User([Principal Engineer])
        Host[🧠 AI Host <br/><i>(Claude, Cursor)</i>]
    end

    subgraph Protocol_Layer ["🔌 Model Context Protocol"]
        Client[🔌 MCP Client]
    end

    subgraph Server_Layer ["📦 MCP Servers (The Hands)"]
        S1[📦 Git Server]
        S2[☸️ K8s Server]
        S3[☁️ AWS Server]
    end

    subgraph Infrastructure ["🏗️ Infrastructure"]
        git[Local Git CLI]
        k8s[K8s API]
        aws[AWS SDK]
    end

    User -->|Prompts| Host
    Host -->|Connects| Client
    Client <== "JSON-RPC (Stdio/SSE)" ==> S1
    Client <== "JSON-RPC (Stdio/SSE)" ==> S2
    Client <== "JSON-RPC (Stdio/SSE)" ==> S3

    S1 --> git
    S2 --> k8s
    S3 --> aws
```

---

## 🧩 The Three Primitives

The atomic units of MCP. A server defines its capabilities using these three types.

### 👁️ 1. Resources (Data)
Resources are **read-only** data sources. They provide the AI with grounded context.
- **URI Based**: `file:///logs/nginx.log` or `postgres://schema/users`.
- **Use Case**: Reading a configuration file, inspecting a database schema, or viewing current cluster status.

### 🛠️ 2. Tools (Actions)
Tools are **executable functions**. They allow the AI to change the state of the world.
- **Action Oriented**: `restart_pod(id)`, `create_pr(title, branch)`.
- **Schema Defined**: Uses JSON Schema to tell the AI what arguments are required.
- **Safety**: Usually requires **Human-in-the-Loop (HITL)** approval for mutating actions.

### 📝 3. Prompts (Templates)
Prompts are **Reusable instructions**. They standardize how the AI approaches a specific task.
- **Workflow Oriented**: A "Review Security Group" prompt that automatically calls the necessary tools.
- **Use Case**: Onboarding a new engineer with a "System Walkthrough" prompt.

---

## 🔌 Transport Layers

| Transport | Connection Type | Best For |
| :--- | :--- | :--- |
| **Stdio** | Standard I/O (Subprocess) | **Local DevOps**. Inherits your SSH keys, AWS creds, and Kubeconfig. |
| **SSE** | Server-Sent Events (HTTP) | **Remote/Cloud**. Connecting to shared team servers or SaaS tools. |

---

## 📜 Protocol Logic (JSON-RPC)

MCP is built on **JSON-RPC 2.0**. It's lightweight, language-agnostic, and asynchronously handles requests.

**Example Request (List Tools):**
```json
{
  "jsonrpc": "2.0",
  "id": "1",
  "method": "tools/list",
  "params": {}
}
```

---

## 🛡️ Security by Design

MCP doesn't give an AI "Admin" access. It gives the AI **specifically scoped capability**.

1.  **Least Privilege**: A server might expose `read_logs` but not `delete_db`.
2.  **Input Validation**: The MCP Server (written by YOU) validates all input before execution.
3.  **Human Approval**: The Host application prompts the user: *"The AI wants to scale the cluster to 10 nodes. Approve?"*

---

## 🚦 Knowledge Check

**Q1: Which component is responsible for running the actual code/logic of a tool?**
> *Answer: The MCP Server.*

**Q2: Why is Stdio better for a DevOps Engineer working locally?**
> *Answer: Because it runs as a subprocess, inheriting the engineer's existing terminal permissions (Identity & Access).*

**Q3: What is the primary difference between a Tool and a Resource?**
> *Answer: Resources are for reading data (Context); Tools are for taking actions (Mutations).*

---

## 🔗 Next Steps
Ready to build? 
1. 🧪 Check out the **[Fundamentals Challenges](./challenges.md)** to test your knowledge.
2. 🏗️ Proceed to **[02: Building MCP Servers](../02-building-mcp-servers/readme.md)** to write your first line of code.
