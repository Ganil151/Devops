# 📋 Module 02: Manual Docker Audit

> **"The best vulnerability is the one that isn't there because you deleted the code."**

## 📚 Overview

Scanners find CVEs. But they often miss **Configuration Errors**. This module teaches you how to look at a `Dockerfile` and spot security nightmares.

## 🎓 Learning Objectives

- ✅ **Root vs. Non-Root**: Why running as `uid 0` is dangerous.
- ✅ **Base Images**: `ubuntu` vs `alpine` vs `distroless`.
- ✅ **Secrets**: Why `ENV PASSWORD=secret` is a bad idea.

---

## 🛑 The "Bad" Dockerfile

If you see this, flag it!

```dockerfile
# ❌ Huge attack surface
FROM ubuntu:latest 

# ❌ Runs as Root by default
COPY . /app 

# ❌ Secret in plain text
ENV API_KEY="12345"

CMD ["python", "app.py"]
```

## ✅ The "Good" Dockerfile

```dockerfile
# ✅ Minimal attack surface
FROM python:3.9-alpine

# ✅ Specific User
RUN adduser -D myuser
USER myuser

WORKDIR /app
COPY . .

CMD ["python", "app.py"]
```

---

**Next Step**: Prove your skills in **[CHALLENGES.md](../../CHALLENGES.md)** 🚀
