# 🟩 Node.js: High-Performance Backend JavaScript
*Scalable Architectures for Modern Microservices*

---

## 🗺️ Learning Roadmap

### [01-Event-Loop](./01-event-loop/)
- **Concepts**: Callbacks, Promises, libuv, non-blocking I/O.
- **Goal**: Understand the engine that powers Node.js.

### [02-Express-Middleware](./02-express-middleware/)
- **Concepts**: Routing, Request pipelining, Error handling.
- **Goal**: Build flexible and robust web servers.

### [03-PM2-Operations](./03-pm2-operations/)
- **Concepts**: Process clustering, Auto-restart, Monitoring.
- **Goal**: Run Node.js at production scale.

---

## 🛠️ Quick Start
```bash
npm init -y
npm install express
# create index.js
node index.js
```

---

## 🛡️ SRE Standards
- **Memory Management**: Monitor V8 heap usage to identify leaks early.
- **Dependency Guard**: Regularly run `npm audit` to fix vulnerabilities.
- **Stream Everything**: Use Streams for handling large files to keep memory usage low.
