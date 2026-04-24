# 🚀 Flask Production Standards
*Hardening Logic for Scalable Deployment*

---

## 📖 Overview
The built-in Flask server is for development only. It is not secure, stable, or efficient. Production requires a **WSGI Server** (Gunicorn) and a **Reverse Proxy** (Nginx).

---

## 🏗️ The Production Stack

### 1. Gunicorn (WSGI)
Handles the execution of Python code and manages multiple worker processes.
```bash
gunicorn -w 4 -b 0.0.0.0:8000 app:app
```

### 2. Nginx (Reverse Proxy)
Handles SSL termination, static file serving, and load balancing.

### 3. Environment Context
Ensure `FLASK_ENV` is set to `production` to disable debug mode and prevent leaking sensitive tracebacks to users.

---

## 🚀 Advanced Pattern: Dockerization
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "-w", "4", "main:app"]
```

---

## 🛡️ SRE Standard Checklist
- [ ] Is `DEBUG = False` set?
- [ ] Is a "WSGI Server" being used?
- [ ] Are logs being sent to `stdout` for container log collection?
- [ ] Is `CORS` restricted to only authorized frontend origins?

---
**Back to Module**: [Flask Main Guide](../readme.md)
