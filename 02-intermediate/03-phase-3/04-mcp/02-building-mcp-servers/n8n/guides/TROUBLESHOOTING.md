# 🛠️ TROUBLESHOOTING: AI Tool & Documentation Recovery

This matrix focuses on resolving connectivity and performance issues common in local n8n-MCP deployments.

## 🔄 1. Infrastructure Issues

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| **n8n Restart Loop** | Permission Conflict | `sudo chown -R 1000:1000 ./n8n_data` |
| **Port 5678 Conflict** | Ghost Process | `sudo fuser -k 5678/tcp` |
| **DB Connection Timeout** | Invalid Hostname | Ensure `DB_POSTGRESDB_HOST=n8n_db` (Container Name) |

## 🔌 2. MCP Connectivity

### ❌ Error: "Failed to Fetch MCP Tools"
- **Internal Check**: Ensure the workflow with the **MCP Server Trigger** is **Active**.
- **Network Check**: Verify n8n can reach Ollama: `curl http://ollama:11434`.
- **Auth Check**: If using SSE, ensure your Bearer token in the client config matches the n8n node config.

## 🧠 3. AI Performance (Internal Models)

### ❌ Error: "Ollama: Pull Model Manifest - File Not Found"
- **Cause**: Using invalid tags (e.g., `qwen3:coder`).
- **Fix**: Use verified tags: `qwen2.5-coder` or `deepseek-r1`.
- **Command**: `docker exec -it ollama ollama list` to verify.

### ❌ Issue: Extreme Latency / OOM
- **Diagnosis**: Local LLMs exceeding system RAM.
- **Fix**: Quantize models down or use smaller parameter counts (e.g., `qwen2.5-coder:1.5b` instead of `7b`).

---
*If you need to completely reset the sandbox, refer to the "Nuke" option in the Deployment Guide.*
