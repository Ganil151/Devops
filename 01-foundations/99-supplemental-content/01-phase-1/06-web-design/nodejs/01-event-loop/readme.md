# 🔄 Node.js Architecture: The Event Loop
*Mastering High-Concurrency Performance*

---

## 📖 Overview
Understanding the Event Loop is mandatory for any serious Node.js developer. It is the heart of what makes Node.js fast despite being single-threaded.

---

## 🏗️ Technical Pillars

### 1. Single-Threaded Nature
Node runs your JavaScript on one thread. If you run a heavy loop (`for (let i=0; i<10000000; i++)`), you block **everyone** from accessing your server.

### 2. The Loop Phases
1. **Timers**: `setTimeout`, `setInterval`.
2. **Pending Callbacks**: System errors.
3. **Poll**: Retrieve new I/O events (network scripts, file reads).
4. **Check**: `setImmediate`.
5. **Close Callbacks**: Socket closure.

### 3. Libuv & Thread Pool
While the JS thread is single, Node delegates I/O (Crypto, FS) to a multi-threaded pool (libuv) managed by the OS.

---

## 💡 SRE Pro-Tip
Never perform CPU-intensive tasks inside a Node.js web server. If you must process massive data, delegate it to a Worker Thread or a separate Python script.

---
**Next Step**: [02-Express-Middleware](../02-express-middleware/readme.md)
