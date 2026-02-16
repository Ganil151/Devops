# 📖 AI Handshake & Operational Guide

This guide details the "Handshake" process between n8n and your local AI services, troubleshooting steps for the common "Restart Loop," and strategies for production hardening.

---

## 🛠️ 1. Troubleshooting & Stability
If your `n8n_automation` container is stuck in a **"Restarting"** state or exiting with **Status 1**, follow these steps:

### A. Permission Denied (Most Common)
n8n runs as user `node` (UID 1000). If the local `./n8n_data` folder was created by root, n8n cannot write to it.
**Fix:**
```bash
sudo chown -R 1000:1000 ./n8n_data
```

### B. Database Connection Failure
Check your logs to confirm the error:
```bash
sudo docker logs n8n_automation
```
Ensure `DB_POSTGRESDB_HOST` in your `.env` is set to `n8n_db` (the container name) and **not** `localhost` or `db`.

---

## 🧠 2. Model Provisioning (Ollama)
While the stack is configured to auto-pull **Qwen3**, you can manually manage models via the CLI.

### Pulling Specific Models
Connect to the Ollama container and pull the desired architecture:
```bash
# Pull Qwen 2.5-Coder (Optimized for n8n Agent workflows)
sudo docker exec -it ollama ollama pull qwen2.5-coder

# Pull DeepSeek-R1 (1.5b/7b/8b)
sudo docker exec -it ollama ollama pull deepseek-r1
```

### Listing Loaded Models
```bash
sudo docker exec -it ollama ollama list
```

---

## 🔗 3. n8n AI Configuration
To unlock AI capabilities in n8n, you must configure the **Ollama Chat Model** node.

### The Connection Settings
1.  **Open n8n**: Go to `http://localhost:5678`.
2.  **Add Node**: Create a new workflow and add an **AI Agent** or **Basic LLM Chain** node.
3.  **Add Model**: Connect an **Ollama Chat Model** node to the AI Agent.
4.  **Internal Handshake**: 
    - **Base URL**: `http://ollama:11434` (This uses Docker's internal DNS).
    - **Model Name**: `qwen3` (or the specific tag you pulled).
5.  **Authentication**: Leave "Credentials" blank as local Ollama is open by default within its network.

---

## 🏗️ 4. Build Your First Workflow
1.  **Trigger**: Use a **Webhook** node to receive data.
2.  **AI Logic**: Use the **AI Agent** node configured in Step 3.
3.  **System Message**: Use a professional DevOps prompt (see below).
4.  **Output**: Use a **Write Binary File** or **HTTP Request** node to save or send the AI's response.

### ✍️ Prompt Engineering 101 for DevOps
Use this robust **System Message** in your AI node:
> "You are an expert DevOps Engineer and SRE. You specialize in Bash scripting, Docker Compose optimization, and n8n workflow design. When asked to generate code, ensure it is secure, idempotent, and follows Linux best practices."

---

## 📁 5. Persistence & Volumes
All your data is mapped to local folders to ensure it survives container restarts:
- `./n8n_data` → Your workflows and local files.
- `./postgres_data` → Your database records.
- `./ollama_data` → Your downloaded AI models.
**Warning**: Never delete these folders unless you want to wipe your setup!

---

## 🛡️ 6. Security & Production Hardening
For production environments, use a Reverse Proxy to handle SSL.

### Reverse Proxy (Caddy Example)
```caddyfile
n8n.your-domain.com {
    reverse_proxy n8n_automation:5678
}
```

### Production Checklist
- [ ] **Encryption Key**: Set a unique `N8N_ENCRYPTION_KEY` in `.env`.
- [ ] **Firewall**: Ensure port `11434` (Ollama) is **NOT** exposed to the public internet.
- [ ] **Resources**: Set memory limits in `docker-compose.yml` to prevent LLMs from crashing the host.

---

## � 7. Troubleshooting Matrix
| Error / Issue | Potential Cause | Fix |
| :--- | :--- | :--- |
| **Status 1 (Exit Code)** | Permissions or missing `.env` | Run `sudo chown -R 1000:1000 ./n8n_data`. |
| **Connection Refused** | n8n cannot talk to Ollama | Use `http://ollama:11434` (NOT localhost). |
| **Out of Memory (OOM)** | Model is too large for RAM | Use a smaller tag (e.g., `qwen3:1.5b`). |
| **n8n Restarting** | Invalid Database Host | Verify `DB_POSTGRESDB_HOST=n8n_db` in `.env`. |
| **Slow Inference** | No GPU Acceleration | Use a smaller model or enable NVIDIA CDI. |
