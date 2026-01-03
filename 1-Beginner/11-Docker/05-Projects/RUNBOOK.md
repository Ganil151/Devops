# Operational Runbook: Flask-Postgres-Nginx Stack

This runbook provides step-by-step procedures for the deployment, management, and recovery of the Dockerized full-stack project.

**Runbook Type:** 🟡 Hybrid (Manual steps + automated container orchestration)

---

## 📋 1. Service Overview
- **Frontend:** Nginx serving static HTML.
- **Backend:** Flask API (Gunicorn).
- **Database:** PostgreSQL 16 (Alpine).
- **Cache:** Redis 7 (Alpine).
- **Proxy/SSL:** Nginx-Certbot for SSL termination and routing.

---

## 🚀 2. Deployment Procedures

### Initial Setup
1. **Clone the repository:** `git clone <repo_url>`
2. **Set up secrets:**
   - Create `pg_password.txt` with a strong password.
   - Create `Flask/api_key.txt` for the backend.
3. **Configure Environment:**
   - Update `nginx-certbot.env` with your email and domain.
   - Update `Flask/dev.env` if needed.

### Launching the Stack
#### Development (Local)
```bash
docker compose up -d
```
#### Production (Server)
```bash
docker compose -f compose.yaml -f compose.prod.yaml up -d
```

---

## 🏥 3. Health & Sanity Checks

### Verify Services
Check running containers:
```bash
docker compose ps
```

### Check Connectivity
<b>1. Frontend:** `curl -I http://localhost`</b>
<details>
<summary>Show Answer</summary>
Answer: Should return 200 or 301
</details>

<b>2. API:** `curl http://localhost/api/about`</b>
<details>
<summary>Show Answer</summary>
Answer: Should return JSON with visitor count
</details>

<b>3. Redis:** `docker compose exec redis redis-cli ping`</b>
<details>
<summary>Show Answer</summary>
Answer: Should return PONG
</details>


---

## 🚨 4. Incident Response & Recovery

### Scenario A: Backend is Unhealthy
**Symptoms:** `docker compose ps` shows `unhealthy` for Flask.
**Steps:**
1. Check logs: `docker compose logs flask`
2. Restart service: `docker compose restart flask`
3. If persistent, check DB connectivity: `docker compose exec flask nc -vz postgres 5432`

### Scenario B: Database Corruption/Loss
**Symptoms:** Application cannot connect to Postgres.
**Steps:**
1. Check volume mounts: `docker volume inspect projects_postgres-data`
2. Restore from backup:
   ```bash
   cat ./backups/latest_backup.sql | docker exec -i projects-postgres-1 psql -U myuser mydb
   ```

### Scenario C: SSL Certificate Renewal Failure
**Symptoms:** Browser shows "Not Secure" warning.
**Steps:**
1. Check Certbot logs: `docker compose logs nginx`
2. Manual renewal attempt:
   ```bash
   docker compose exec nginx certbot renew
   ```

---

## 🧹 5. Maintenance Tasks

### Database Backup (Manual)
```bash
docker compose exec db-backup pg_dump -h postgres -U myuser mydb > ./backups/manual_$(date +%F).sql
```

### Cleaning Up Unused Resources
```bash
docker system prune -f
```

---
**Owner:** DevOps Team
**Escalation:** Infrastructure Lead (#on-call-slack)
