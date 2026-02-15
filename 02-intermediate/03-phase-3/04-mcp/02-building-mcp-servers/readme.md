# 02: Building MCP Servers

**[⬅️ Back to MCP Module Index](../readme.md)** | **[Next: MCP for Kubernetes ➡️](../03-mcp-for-kubernetes-and-cloud/readme.md)**

---

# 🏗️ Architecting Your Custom MCP Server

Welcome to the core of the Model Context Protocol module. While pre-built servers exist for common tools, the true power of MCP lies in **custom server development**. For a DevOps Engineer, this means transforming your scripts, internal APIs, and infrastructure data into actionable AI tools.

## 🌟 Why Build Custom MCP Servers?

- **Context Sovereignty**: Give the AI access to *your* private documentation, CI/CD status, and internal metrics.
- **Workflow Automation**: Turn complex multi-step CLI operations into a single natural language command.
- **Security Control**: Filter and sanitize the data exposed to the AI, ensuring only safe operations are executable.

---

## 📂 Project Structure

We have provided reference implementations in both **Python** and **Node.js**:

```text
02-building-mcp-servers/
├── readme.md
├── n8n/                      # Low-code MCP Bridge (Advanced)
└── src/
    ├── simple_devops_server.py # Python Implementation (FastMCP)
    ├── index.js                # Node.js Implementation (SDK)
    ├── package.json            # Node.js dependencies
    └── requirements.txt        # Python dependencies
```

---

## 🐍 Option A: Python Implementation (Recommended)

Python is the fastest way to build MCP servers thanks to the `FastMCP` library.

### 1. Installation
```bash
cd src
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Core Concepts
Open `src/simple_devops_server.py`. We use decorators to define capabilities:

- **Tools (`@mcp.tool`)**: Functions the AI executes (e.g., `check_http_health`).
- **Resources (`@mcp.resource`)**: Data the AI reads (e.g., `config://app-settings`).
- **Prompts (`@mcp.prompt`)**: Templates for AI interactions (Advanced).

---

## 🟢 Option B: Node.js Implementation

For teams preferring JavaScript/TypeScript or integrating with existing Node.js utilities.

### 1. Installation
```bash
cd src
npm install
```

### 2. Execution
Unlike the high-level FastMCP, the Node.js SDK gives you granular control over the JSON-RPC lifecycle.
```bash
node index.js
```

---

## 🔌 Connecting to AI Clients (Claude / Cursor)

To bridge your server to an AI client, update your local configuration file with the **absolute path** to your script.

### Configuration Location
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

### Example Config (Python)
```json
{
  "mcpServers": {
    "devops-nexus": {
      "command": "/path/to/your/venv/bin/python",
      "args": ["/home/user/Devops/02-intermediate/03-phase-3/04-mcp/02-building-mcp-servers/src/simple_devops_server.py"]
    }
  }
}
```

---

## 🛠️ Troubleshooting & Debugging

MCP servers can be tricky to configure. If your server isn't showing up or tools are failing:

1.  **Check the [Troubleshooting Hub](./troubleshooting.md)** for common fixes.
2.  **Use the Inspector**: `npx @modelcontextprotocol/inspector python src/simple_devops_server.py`.
3.  **Logs**: Look for errors in `stderr`.

---

## 🚀 Advanced: Low-Code with n8n

For complex workflows involving external integrations (Slack, Jira, AWS), check out our **[n8n-MCP Bridge Guide](./n8n/README.md)**. It allows you to build MCP tools using a visual canvas.

---

## 🧪 DevOps Challenge

**Goal**: Extend `src/simple_devops_server.py` to include a "Security Auditor" tool.

1. Add a tool named `check_file_permissions` that takes a `file_path`.
2. Report if the file is world-writable (security risk).
3. Test your tool using the Inspector.

> **Pro-Tip**: Use the `os.stat()` and `stat.S_IWOTH` in Python to check permissions.
