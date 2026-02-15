# 📖 HOWTO: Connecting n8n to MCP Clients

This guide provides the technical "Handshake" instructions for exposing your n8n workflows as tools to MCP-enabled clients (like Claude Desktop).

## 🛠️ 1. The n8n-MCP Setup
To act as an MCP server, n8n utilizes **SSE (Server-Sent Events)** and the **MCP Server Trigger** node.

### Step 1.1: Configure the MCP Server Trigger
1. Add the **MCP Server Trigger** node to a new workflow.
2. Set the **Auth Mode** to `Header` (Recommended).
3. Under **Tools**, define the name and description exactly as you want the AI to see it.
4. Set the **SSE URL** to `http://n8n_automation:5678/rest/mcp`.

### Step 1.2: Authentication Hardening
Never expose AI tools without a Bearer Token.
- **Header Name**: `Authorization`
- **Header Value**: `Bearer your_secure_token_here`
*Configure this in the node settings to prevent unauthorized AI tool execution.*

---

## 🧠 2. Local AI Integration (Ollama)
Our stack integrates **Ollama** for local inference.

### Pulling the Optimized Models
For DevOps and coding tasks, we use the verified coder-specialized models:
```bash
# Pull the reasoning engine
docker exec -it ollama ollama pull deepseek-r1

# Pull the coding specialist
docker exec -it ollama ollama pull qwen2.5-coder
```

---

## 🖇️ 3. The Claude Desktop Configuration
Add the following to your `claude_desktop_config.json` to bridge to your Docker stack:

```json
{
  "mcpServers": {
    "n8n-automation": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-n8n"],
      "env": {
        "N8N_URL": "http://localhost:5678",
        "N8N_API_KEY": "YOUR_N8N_API_KEY"
      }
    }
  }
}
```

---

## 📁 4. Volume Management & Permissions
To avoid the notorious "n8n_automation" crash loop:
```bash
# Ensure the node user owns the data directory
sudo chown -R 1000:1000 /home/gsmash/Documents/n8n_docker/n8n_data
```
*Persistent volumes ensure that your AI tool definitions survive container restarts.*
