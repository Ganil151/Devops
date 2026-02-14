# n8n Mastery: Low-Code Automation for DevOps Engineers

> **Level**: Intermediate  
> **Tag Justification**: Implementing n8n at this level requires proficiency in Docker networking, Environment Variable orchestration, and Webhook listener configuration. It moves beyond simple "Desktop App" usage into "Production-Ready" automation infrastructure.

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

### The "Node" Concept
*   **Triggers**: The "When". Can be a Webhook, a Cron schedule, or a message in a queue (RabbitMQ/Kafka).
*   **Actions**: The "What". Sending a Slack message, creating a Jira ticket, or executing an SSH command.
*   **Data Transformation**: The "How". Merging JSON objects, filtering arrays, or running custom JavaScript logic.

---

## Task 2: Deployment Duel (Docker vs. Bare Metal)

| Method | Docker (The DevOps Choice) | Bare Metal (Node.js) |
| :--- | :--- | :--- |
| **Environment Isolation** | High. All dependencies (Node, Python, libraries) are isolated. | Low. Conflicts with system-wide Node versions are common. |
| **Ease of Updates** | Simple: `docker compose pull && docker compose up -d`. | Vulnerable: Requires manual `npm` updates and possible breaking changes. |
| **Security** | Immutable infrastructure. Minimal host OS exposure. | Direct access to host files and processes. Harder to sandbox. |
| **Scaling** | Easy to move to Kubernetes or AWS ECS. | Manual migration and re-configuration of dependencies. |

**Verdict**: **Docker** is the superior choice for DevOps. It aligns with the principle of **Immutable Infrastructure**, ensuring that your automation server is easily replicable, version-controlled, and environment-agnostic.

---

## Task 3: Intermediate Configuration (Docker Compose)

### Production-Grade `docker-compose.yml`
This setup moves n8n from the default (and volatile) SQLite database to a persistent PostgreSQL instance.

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

### Essential Environment Variables
1.  **`N8N_ENCRYPTION_KEY`**: Crucial for encrypting your stored credentials (API keys, SSH keys). If lost, you lose access to all credentials.
2.  **`WEBHOOK_URL`**: Allows n8n to generate the correct callback URLs for external services (GitHub, Stripe).
3.  **`N8N_USER_MANAGEMENT_JWT_SECRET`**: Secures the user authentication layer in multi-user environments.

---

## Task 4: DevOps Use Cases

### 1. Advanced Alert Routing
*   **Trigger**: Webhook from AWS CloudWatch or Grafana.
*   **Logic**: n8n parses the JSON. If `priority == 'CRITICAL'`, it triggers a PagerDuty incident. If `priority == 'WARNING'`, it simply posts to a Slack channel.
*   **Benefit**: Reduces alert fatigue by filtering noise.

### 2. Auto-Remediation (Self-Healing)
*   **Trigger**: Prometheus Alert for "Disk Full".
*   **Logic**: n8n triggers an **Ansible Playbook** or a **Jenkins Job** that clears `/tmp` directories or rotates logs on the target server.
*   **Benefit**: Resolves routine issues without human intervention.

### 3. GitHub Internal Bot
*   **Trigger**: GitHub Webhook on `PR Created`.
*   **Logic**: n8n checks the commit message headers. If it detects `[FIX]` or `[FEAT]`, it automatically assigns the "Needs Review" label and notifies the relevant team lead.
*   **Benefit**: Enforces documentation standards and speeds up code reviews.

---

## First-Run Security Checklist

- [ ] **Change Default Credentials**: Immediately set up the owner account.
- [ ] **SSL/TLS**: Never run n8n over plain HTTP. Use a Reverse Proxy like Nginx or Traefik with Let's Encrypt.
- [ ] **Network Isolation**: Ensure the `db` container is not exposed to the public internet (internal Docker network only).
- [ ] **Backup Strategy**: Automate backups of the `n8n_data` volume and the PostgreSQL database.
- [ ] **Audit Logs**: Periodically review the n8n execution logs for unauthorized webhook attempts.
