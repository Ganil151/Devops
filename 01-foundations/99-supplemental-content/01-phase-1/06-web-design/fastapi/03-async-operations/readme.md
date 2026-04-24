# ⚡ FastAPI Async & Performance
*Efficiently Orchestrating High-Volume Operations*

---

## 📖 Overview
Traditional Python (Flask) blocks the entire worker while waiting for a database or API response. FastAPI uses an event loop (similar to Node.js) to switch to other tasks while waiting for I/O, dramatically increasing throughput.

---

## 🏗️ Technical Pillars

### 1. `async def`
Functions defined with `async` can use the `await` keyword.
```python
@app.get("/cluster-stats")
async def get_stats():
    stats = await fetch_from_provider() # Does not block
    return stats
```

### 2. When to use Sync (`def`)
If your logic is purely CPU-bound (processing data, heavy math), regular `def` is fine. FastAPI will run these in a separate thread pool.

### 3. Concurrency (`asyncio.gather`)
Fire off multiple infrastructure queries at once and wait for all to complete.
```python
results = await asyncio.gather(query_aws(), query_gcp(), query_azure())
```

---

## 🚀 Advanced Pattern: Background Tasks
For long-running tasks like purging a CDN or rotating logs, use `BackgroundTasks` to return a "202 Accepted" response immediately.
```python
@app.post("/cleanup")
async def trigger_cleanup(tasks: BackgroundTasks):
    tasks.add_task(long_running_logic)
    return {"status": "Cleanup started"}
```

---

## 🛡️ SRE Standard Checklist
- [ ] Is every network call (HTTP/Database) awaited?
- [ ] Are timeouts set for all outbound `async` requests?
- [ ] Is the worker count configured to match CPU cores in production?

---
**Next Step**: [04-Authed-Endpoints](../04-authed-endpoints/readme.md)
