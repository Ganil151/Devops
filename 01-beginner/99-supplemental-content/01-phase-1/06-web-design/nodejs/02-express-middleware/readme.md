# ⚙️ Express.js Middleware Patterns
*Building Robust Backend Logic*

---

## 📖 Overview
Express is built on the concept of middleware—functions that run in a pipeline between the request and the final response.

---

## 🏗️ Technical Pillars

### 1. The `(req, res, next)` Pattern
```javascript
app.use((req, res, next) => {
  // logic
  next(); // Move to the next function
});
```

### 2. Built-in vs Third Party
- **Built-in**: `express.json()`, `express.static()`.
- **Third Party**: `helmet` (Security headers), `morgan` (Logging).

### 3. Error Handling Middleware
Special middleware defined with four arguments `(err, req, res, next)`.

---

## 🧪 Exercise
Create an Express app with:
1. A logger middleware that prints the timestamp of every request.
2. A route at `/info` that returns system details.

---
**Next Step**: [03-PM2-Operations](../03-pm2-operations/readme.md)
