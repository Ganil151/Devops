# 🟩 Node.js & Express: JavaScript Everywhere
*Version 1.0 | Event-Driven Architectures and Fast Backend Development*

---

## 📖 Overview
Node.js is a cross-platform, open-source JavaScript runtime environment that can run on Windows, Linux, Unix, macOS, and more. Express is the minimal and flexible web application framework for Node.js. It is the backbone of millions of microservices.

---

## 🏗️ Core Architecture

### Event Loop
**Definition**: The mechanism that allows Node.js to perform non-blocking I/O operations despite being single-threaded.
**Impact**: High concurrency for lightweight tasks like API proxying or message queuing.

### Single-Threaded Non-Blocking
**Definition**: Node handling many concurrent operations by delegating I/O (file system, network) to the operating system and handling results via callbacks or promises.

---

## ⚙️ Routing & Middleware (Express)

### Middleware Pattern
**Definition**: Functions that have access to the request object (`req`), the response object (`res`), and the next middleware function in the application’s request-response cycle.
**Example**:
```javascript
app.use((req, res, next) => {
  console.log('Time:', Date.now());
  next();
});
```

### Express Router
**Definition**: A mini-app that only performs middleware and routing functions.
**Use Case**: Splitting `/api/v1/users` and `/api/v1/tasks` into different files.

---

## 📦 Dependency Management (NPM)

### package.json
**Definition**: The manifest for your project, listing dependencies and scripts.
**Command**: `npm install` to download libraries like `dotenv`, `cors`, or `mongoose`.

### NPM Scripts
**Standard**: `npm start`, `npm run dev`, `npm test`.

---

## 🚀 DevOps & Reliability

### Process Managers (PM2)
**Definition**: A production process manager for Node.js applications with a built-in load balancer.
**Command**: `pm2 start app.js -i max` (Start in cluster mode).

### Native ESM vs CommonJS
**Definition**: Transition from `require()` (CommonJS) to `import/export` (ESM) syntax.
**SRE Impact**: Modernizing codebase for better tree-shaking and compatibility.

---

## 💡 SRE Pro-Tips
- **Memory Leaks**: Node.js apps can leak memory if closures or global arrays growth isn't managed. Use `heapdump` for debugging OOM errors.
- **Security Check**: Always run `npm audit` in your CI pipeline to catch vulnerable dependencies.
- **Cluster Module**: Use the built-in `cluster` module or PM2 to utilize all CPU cores on high-memory servers.

---
**Next Step**: [Tailwind CSS Architecture →](./TailwindCSS-Architecture-Ref.md)
