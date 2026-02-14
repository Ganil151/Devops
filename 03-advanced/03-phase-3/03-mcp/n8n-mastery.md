# n8n Mastery: Low-Code Automation for DevOps Engineers

> **Level**: Intermediate  
> **Tag Justification**: This module tracks the progression from a basic Junior-level setup (SQLite) to an Intermediate-level, production-grade architecture (PostgreSQL, Docker Networking, and Environment Orchestration).

## Prerequisites
Before you begin, ensure you have:
*   A machine with **Docker** and **Docker Compose** installed.
*   A basic understanding of the **terminal**.
*   **Registry Access**: Ensure your firewall allows traffic from `docker.n8n.io`.

---

## Task 1: The "What & Why" (Conceptual)

### What is n8n?
**n8n** is a "fair-code", node-based workflow automation tool. Unlike closed-source alternatives, it allows you to self-host the entire engine, giving you full control over your data, costs, and execution environment.

### The Competition: n8n vs. Zapier/Make
| Feature | Zapier / Make | n8n (Self-Hosted) |
| :--- | :--- | :--- |
| **Data Privacy** | Cloud-managed (Third-party access) | **Private** (Stays in your VPC) |
| **Cost** | Per-execution (Scales poorly) | **Fixed** (Infrastructure cost only) |
| **Customization** | Limited by UI/Plugin API | **Infinite** (Custom JS, Internal API access) |
| **Connectivity** | Cloud-native only | **Hybrid** (Cloud + Internal SSH/DBs) |

---

## Task 2: Deployment Duel (Docker vs. Bare Metal)

**Verdict**: **Docker** is the superior choice. It aligns with the principle of **Immutable Infrastructure**, ensuring that your automation server is easily replicable, version-controlled, and environment-agnostic. Running it on Bare Metal creates "Snowflake Servers"—servers that are hard to replicate and maintain.

---

## Task 3: Phase 1 - The Junior Setup (SQLite & Rapid Prototyping)

Before jumping into complex clusters, every DevOps engineer starts with a "Proof of Concept" (PoC). This setup uses **SQLite** for simplicity.

### 1. Create Your Directory Structure
Organization is everything in DevOps.
```bash
mkdir n8n-docker && cd n8n-docker
mkdir n8n_data
```

### 2. The Basic `docker-compose.yml` (Junior Setup)
This manifest defines a single-service stack using the official n8n image and a bridge network.

```yaml
version: '3.8'

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n_automation
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=http://localhost:5678/
      - GENERIC_TIMEZONE=UTC 
    volumes:
      - ./n8n_data:/home/node/.n8n
    networks:
      - automation_network

networks:
  automation_network:
    driver: bridge
```

### 3. Image Preparation & Launch
In a professional DevOps workflow, we explicitly pull images to verify registry connectivity and ensure the latest bits are cached.

*   **Step 3.1: Pre-fetch the Image**  
    n8n hosts its images on its own dedicated registry (`docker.n8n.io`). Pull the image manually to verify your path:
    ```bash
    docker pull docker.n8n.io/n8nio/n8n:latest
    ```

*   **Step 3.2: Launch the Stack**  
    Start the container in detached mode:
    ```bash
    docker-compose up -d
    ```

*   **Step 3.3: Verify Deployment**  
    *   **Health Check**: Run `docker ps`. Look for `n8n_automation` with a status of `Up`.
    *   **Interface**: Access the UI at `http://localhost:5678`.

---

## Task 4: Phase 2 - Post-Install "Day 1" Operations

Don't just stop at the login screen. A professional setup requires verification.

1.  **Set up the Owner Account**: Follow the prompts to create the admin user.
2.  **Test Persistence**: Create a simple "Test" workflow and save it. Run `docker-compose restart`. If your workflow survives, your **Volumes** are correctly mapped.
3.  **Check the Logs**: Run `docker logs -f n8n_automation`. This is how you will debug 90% of issues. Watch the logs as you trigger nodes in the UI.

---

## Task 5: Phase 3 - The Intermediate Handoff (Production-Grade Postgres)

For real environments, SQLite is a bottleneck. We must migrate to **PostgreSQL**.

### The Production `docker-compose.yml`
```yaml
version: '3.8'

services:
  db:
    image: postgres:14-alpine
    restart: always
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data

  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - WEBHOOK_URL=https://n8n.yourdomain.com/
      - N8N_USER_MANAGEMENT_JWT_SECRET=${N8N_JWT_SECRET}
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_HOST=db
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - db

volumes:
  postgres_data:
  n8n_data:
```

### Why this is "Best Practice":
*   **Restart Policy**: `restart: always` ensures n8n recovers from system reboots automatically.
*   **Volume Mapping**: Ensures workflows and credentials persist on the host disk, not just the volatile container layer.
*   **Database Handoff**: Moving to Postgres allows for high availability, better concurrency, and easier backups.
*   **Environment Variables**: Using a `.env` file or external vars makes the setup portable across Dev, Staging, and Prod.

---

## Task 6: AI Automation - Integrating DeepSeek & Qwen

In 2025, the most powerful use case for n8n is **AI Orchestration**. You can connect n8n to Large Language Models (LLMs) to automate decision-making, content generation, or code reviews.

### Option 1: The "Easy Way" (Cloud API)
Best for quick setup or production environments without local GPU resources.

*   **1.1 Get Your Credentials**:
    *   **DeepSeek**: Log in to [platform.deepseek.com](https://platform.deepseek.com) and generate an API key.
    *   **Qwen**: Access through Alibaba Cloud's **DashScope** console and create a key.
*   **1.2 Configure n8n**:
    *   Search for the **DeepSeek Chat Model** node (native integration).
    *   If using Qwen, use the **OpenAI Chat Model** node and set the **Base URL** to the DashScope endpoint.
*   **1.3 Credential Setup**:
    *   **Base URL**: `https://api.deepseek.com` (for DeepSeek).
    *   **Model Name**: Manually type `deepseek-chat`, `deepseek-reasoner` (R1), or `qwen-plus`.

### Option 2: The "DevOps Way" (Local via Ollama)
The superior learning path for SREs. Run models locally for zero cost and maximum privacy.

#### Step 1: Install & Pull Models
Install **Ollama** on your host machine. Then, pull the models:
```bash
ollama pull deepseek-r1:7b
ollama pull qwen2.5:7b
```

#### Step 2: Update Docker Networking
Because n8n runs inside a container, it cannot reach `localhost` of your computer directly. You must bridge the gap using `host-gateway`.

Update your `docker-compose.yml` service:
```yaml
services:
  n8n:
    # ... previous configuration ...
    extra_hosts:
      - "host.docker.internal:host-gateway"
```
Run `docker-compose up -d` to apply.

#### Step 3: Connect n8n to Ollama
1.  Add an **AI Agent** node to the canvas.
2.  Connect an **Ollama Chat Model** node to it.
3.  **Credentials**:
    *   **Base URL**: `http://host.docker.internal:11434`
    *   **Model Name**: `deepseek-r1:7b` (must match the pulled name).

### AI Setup Summary for DevOps
| Method | Why do it? | Skill Learned |
| :--- | :--- | :--- |
| **DeepSeek API** | Production stability. | API authentication & JSON payloads. |
| **Ollama (Local)** | Cost-saving & Privacy. | Docker networking (`host-gateway`). |
| **OpenRouter** | Access to hundreds of models. | Aggregator API management. |

> **Pro-Tip**: To impress in interviews, deploy **Open WebUI** in the same Docker network. It provides a ChatGPT-like interface for your models, while n8n handles the automated background logic.

---

## Task 7: The "God-Mode" Stack (Ollama + n8n + Postgres)

For the ultimate DevOps experience, we can orchestrate the entire automation engine, the database, and the AI model server in a single, unified stack. This simplifies networking and ensures portability.

### The Unified `docker-compose.yml`
```yaml
version: '3.8'

services:
  db:
    image: postgres:14-alpine
    restart: always
    environment:
      - POSTGRES_USER=${POSTGRES_USER:-n8n_user}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-n8n_pass}
      - POSTGRES_DB=n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data

  ollama:
    image: ollama/ollama:latest
    container_name: ollama_server
    restart: always
    volumes:
      - ollama_data:/root/.ollama
    # Note: For GPU support, add the 'deploy' section with 'reservations'

  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n_unified
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_HOST=db
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=${POSTGRES_USER:-n8n_user}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD:-n8n_pass}
      - OLLAMA_HOST=ollama:11434
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - db
      - ollama

volumes:
  postgres_data:
  ollama_data:
  n8n_data:
```

### Why this is the "DevOps Way":
1.  **Service Discovery**: n8n no longer needs `host.docker.internal`. It can reach the database at `db` and the LLM server at `ollama` because they share the same internal Docker network.
2.  **Zero-Configuration Persistence**: All three services have dedicated volumes, ensuring that workflows, database records, and AI models survive container recreation.
3.  **Portability**: You can move this entire folder to any Linux server, run `docker-compose up -d`, and the entire automation infrastructure will be identical.

---

## Task 8: DevOps Use Cases

### 1. Advanced Alert Routing
*   **Scenario**: Webhook from AWS CloudWatch or Grafana.
*   **Logic**: If `priority == 'CRITICAL'`, trigger PagerDuty. If `priority == 'WARNING'`, post to Slack.

### 2. Auto-Remediation (Self-Healing)
*   **Scenario**: Prometheus Alert for "Disk Full".
*   **Logic**: n8n triggers an **Ansible Playbook** to clear `/tmp` or rotate logs.

### 3. GitHub Internal Bot
*   **Scenario**: GitHub Webhook on `PR Created`.
*   **Logic**: Check commit message headers. If `[FIX]`, auto-assign "Needs Review" and notify the team lead.

---

## First-Run Security Checklist

- [ ] **Encryption Key**: Set `N8N_ENCRYPTION_KEY`. If lost, you lose access to all credentials!
- [ ] **SSL/TLS**: Never run n8n over plain HTTP in production. Use a Reverse Proxy (Nginx/Traefik).
- [ ] **Network Isolation**: Ensure the `db` container is not exposed to the public internet.
- [ ] **Backup**: Automate backups of the `n8n_data` volume and the Postgres DB.
