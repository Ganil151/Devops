# 🌐 n8n + MCP: The AI Automation Bridge

Welcome to the production-grade documentation for building **MCP (Model Context Protocol)** servers using **n8n**. This documentation bridges the gap between theoretical AI tool exposure and live, Docker-orchestrated deployment.

## 🏗️ Architecture Stack
Our deployment uses a unified, three-tier architecture:
- **🔄 n8n Orchestrator**: Hosting the MCP Server Trigger and Tool Logic.
- **🐘 PostgreSQL**: High-performance state persistence.
- **🧠 Ollama Engine**: Local inference for DeepSeek-R1/Qwen2.5-Coder.

## 📁 Documentation Roadmap
```text
.
├── README.md               <-- You are here
├── HOWTO.md                <-- Setup & AI Handshake Guide
├── TROUBLESHOOTING.md      <-- Fixes for loops & connectivity
├── deployment/
│   ├── docker-compose.yml  <-- Standardized Production Stack
│   └── .env.example        <-- Encrypted Var Template
└── guides/
    └── mcp-server-bridge.md <-- SSE & Tool Exposure Logic
```

## 🚀 Key Advantages
1. **Privacy First**: Local AI models via Ollama ensure zero data leakage.
2. **Tool Sovereignty**: Expose internal databases and scripts as AI tools via SSE.
3. **Resilient Infrastructure**: Automated recovery from crash loops and permission conflicts.

---
*Maintained by the Principal DevOps Architect.*
