# 🌉 The n8n-MCP Bridge: Tool Exposure Guide

Exposing your n8n workflows as Model Context Protocol (MCP) tools allows clients like Claude Desktop to execute complex automations through natural language.

## 📡 1. SSE Mechanism
n8n uses **Server-Sent Events (SSE)** to provide a persistent connection for MCP tools.

### Endpoint Configuration
The internal SSE endpoint is typically:
`http://n8n_automation:5678/rest/mcp`

### Request Flow
1. **Client** (Claude) sends a JSON-RPC request.
2. **n8n MCP Trigger** parses the request and initiates the workflow.
3. **Workflow** executes logic (e.g., query DB, call Ollama, run script).
4. **n8n** streams the result back to the client via SSE.

---

## 🛠️ 2. MCP Server Trigger Node
This is the heart of the integration.

### Configuration Best Practices:
- **Tool Name**: Use `snake_case` (e.g., `query_production_logs`).
- **Description**: Be descriptive! The AI uses this to decide when to call the tool.
- **Input Schema**: Define the JSON schema for arguments clearly.

Example Tool Description:
> "Queries the local PostgreSQL database for service alerts and summarizes them using the connected DeepSeek model."

---

## 🛡️ 3. Security Hardening
Since MCP tools can perform destructive actions (e.g., `delete_resource`), security is non-negotiable.

### Authentication Strategy:
1. **Bearer Tokens**: Configure the trigger node to require a static token.
2. **Internal Proxy**: If exposing to the public internet, use Caddy/Nginx for SSL and basic auth.
3. **IAM**: Use n8n's internal user management to restrict who can edit MCP workflows.

---
*Created by the Principal DevOps Architect.*
