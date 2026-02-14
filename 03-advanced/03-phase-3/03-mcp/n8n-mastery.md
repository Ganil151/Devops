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

### 2. The Basic `docker-compose.yml`
This manifest defines a single-service stack using the official n8n image.

```yaml
version: '3.8'

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n_automation
...
```

### 3. Image Preparation & Launch
In a professional CI/CD environment, we pull images before execution to ensure availability and speed up deployment.

*   **Step 3.1: Pull from the Official Registry**  
    n8n uses its own registry (`docker.n8n.io`) for the latest stable builds. Run this command to fetch the image:
    ```bash
    docker pull docker.n8n.io/n8nio/n8n:latest
    ```

*   **Step 3.2: Launch the Stack**  
    Start n8n in detached mode (running in the background):
    ```bash
    docker-compose up -d
    ```

*   **Step 3.3: Verify Deployment**  
    *   **Monitor**: Run `docker ps`. You should see `n8n_automation` with status "Up".
    *   **Connectivity**: Open your browser to `http://localhost:5678`.

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

## Task 6: DevOps Use Cases

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
