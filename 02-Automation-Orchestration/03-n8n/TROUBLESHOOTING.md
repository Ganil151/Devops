# 🛠️ Troubleshooting & Project Recovery Guide

This guide compiles real-world solutions for the issues encountered during the setup of the n8n + Local AI stack.

---

## 🏗️ 1. Docker & Infrastructure Issues

### ❌ Error: "version is obsolete"
**Symptom:** Warning: `the attribute version is obsolete, it will be ignored`.
**Solution:** Modern Docker Compose (V2) no longer requires the `version` tag. 
*   **Fix:** Remove the `version: '3.x'` line from the top of `docker-compose.yml`.

### ❌ Error: "Conflict. The container name is already in use"
**Symptom:** `Error response from daemon: Conflict. The container name "/n8n_automation" is already in use`.
**Reason:** A container with that name exists on the system but is not managed by your current compose file (an "orphan").
**Fix:**
```bash
sudo docker rm -f n8n_automation
```

### ❌ Error: "failed to set up container networking"
**Symptom:** `driver failed programming external connectivity on endpoint n8n_automation ... port 5678 is already in use`.
**Reason:** Another process (potentially a hidden Docker container or a manual n8n installation) is already using port 5678.

**Force Fix:**
1. **Find exactly what is using the port:**
   ```bash
   sudo lsof -i :5678
   ```
2. **Identify the PID (Process ID) and kill it:**
   ```bash
   # Replace <PID> with the number found in the lsof command
   sudo kill -9 <PID>
   ```
3. **If it's a "zombie" Docker bridge:**
   ```bash
   sudo systemctl restart docker
   ```
4. **Clean up all orphaned networks:**
   ```bash
   sudo docker network prune -f
   ```

### ❌ Error: "permission denied while trying to connect to the Docker daemon"
**Symptom:** Error connecting to `docker.sock`.
**Fix:** Run the command with `sudo` OR add your user to the docker group:
```bash
sudo usermod -aG docker $USER
# Then log out and back in
```

---

## 🔄 2. n8n Specific Issues

### ❌ Issue: n8n is stuck in a "Restarting" Loop
**Symptom:** `docker ps` show n8n status as `Restarting (1)`.

#### A. Permission Denied (Most Common)
n8n runs as user `node` (UID 1000). If the host folder `./n8n_data` is owned by root, n8n will crash.
**Fix:**
```bash
sudo chown -R 1000:1000 ./n8n_data
```

#### B. Database Connection Failure
n8n cannot talk to the Postgres container.
**Fix:** Check your `.env` and ensure `DB_POSTGRESDB_HOST` is set to `n8n_db` (the service name in compose), NOT `localhost`.

---

## 🧠 3. AI & Ollama Issues

### ❌ Issue: AI Node "Connection Refused"
**Symptom:** n8n error: `ECONNREFUSED` when calling the Ollama node.
**Fix:** In the n8n UI, ensures the **Base URL** for Ollama is set to `http://ollama:11434`. Do not use `localhost` because n8n is searching inside its own container.

### ❌ Issue: "Out of Memory" (OOM)
**Symptom:** The AI model crashes or is extremely slow.
**Reason:** Local LLMs (especially 7B+ models) require significant RAM.
**Fix:** Use smaller model tags, e.g., `qwen3:1.5b` instead of `qwen3:7b`.

### 🧪 Specialized Model Issues
If the standard models don't work as expected for technical tasks:
**Try the verified coder-optimized model:**
```bash
sudo docker exec -it ollama ollama pull qwen2.5-coder
```
**Note:** `qwen3:coder` and `codellama/qwen3` are not valid Ollama tags. Always use `ollama list` to check your downloaded models.

---

## 🧨 4. The "Nuke" Option: Factory Reset
If the stack is completely broken and you want to start fresh from a zero state. 

**⚠️ WARNING: This deletes all workflows, database records, and AI models.**

```bash
# 1. Kill and prune everything
sudo docker compose down -v --rmi all --remove-orphans

# 2. Clear local data folders
sudo rm -rf n8n_data postgres_data ollama_data

# 3. Re-initialize
mkdir -p n8n_data postgres_data ollama_data
sudo chown -R 1000:1000 n8n_data

# 4. Start again
sudo docker compose up -d
```
