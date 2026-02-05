# 🛠️ Module 02: Manual Health Checks

> **"Automation is great, but knowing how to check a pulse manually is mandatory."**

## 📚 Overview

Before we set up Prometheus or Datadog, we must know how to check a system's health using standard `Unix` utilities. This module covers the "First Responder" toolkit for inspecting servers.

## 🎓 Learning Objectives

- ✅ Check endpoint status with `curl`.
- ✅ Inspect disk usage with `df`.
- ✅ Monitor system load with `top`.
- ✅ Verify active ports with `netstat` or `ss`.

---

## 💻 The Toolkit

### 1. HTTP Checks (`curl`)
Checking if a web server is responding.
```bash
# Check headers only (-I)
curl -I https://google.com

# Verbose mode to see the handshake (-v)
curl -v localhost:8080
```

### 2. Disk Space (`df`)
Checking if the hard drive is full.
```bash
# Human readable format (-h)
df -h
```

### 3. System Load (`top`)
Checking CPU and RAM usage.
- Run `top` (or `htop` if installed) to see a live view of process consumption.

### 4. Active Ports
Checking what is listening on the network.
```bash
# Show listening ports
ss -tulpn
```

---

## 🚀 The Health Check Script

We have provided a script `manual_health_check.sh` in this directory to automate these basic checks.

### Usage:
```bash
chmod +x manual_health_check.sh
./manual_health_check.sh
```

---

**Next Step**: Prove your skills in **[CHALLENGES.md](../../CHALLENGES.md)** 🚀
