# 🚀 Node.js Operations: PM2
*High-Availability Process Management*

---

## 📖 Overview
In production, running `node app.js` is not enough. If the app crashes, it stays down. PM2 ensures your app restarts automatically and can use all CPU cores.

---

## 🏗️ Technical Pillars

### 1. Cluster Mode
Allows Node.js (single-threaded) to scale across all CPU cores by creating multiple workers.
`pm2 start app.js -i max`

### 2. Auto-Restart
PM2 monitors your process. If it crashes due to a memory leak or error, PM2 pulls it back up instantly.

### 3. Monitoring
`pm2 monit` provides a dashboard for CPU and Memory usage per-worker.

---

## 🛡️ SRE Standard Checklist
- [ ] Is `pm2 startup` configured to survive server reboots?
- [ ] Are logs being rotated using `pm2-logrotate`?
- [ ] Is the memory limit set (`--max-memory-restart`)?

---
**Back to Module**: [NodeJS Main Guide](../readme.md)
