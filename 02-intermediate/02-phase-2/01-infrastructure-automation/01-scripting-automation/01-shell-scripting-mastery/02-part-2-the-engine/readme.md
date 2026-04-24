# ⚙️ Part 2: The Engine (Processing & Data)

> **"If you can pipe it, you can process it. Bash is the king of text processing."**

Welcome to **The Engine**. This is where you learn to handle data at scale without ever opening a spreadsheet. In DevOps, logs are your lifeblood, and text processing is your surgical tool.

## 🛣️ The Curriculum

### [01-Stream-and-Text-Processing](./01-stream-and-text-processing/)
**The Objective**: Master the "Big Three" utilities.
*   **Key Tools**: 
    *   **sed (Stream Editor)**: Search and replace at scale.
    *   **awk**: The mini-programming language for column-based data.
    *   **jq**: The essential tool for parsing JSON in the cloud.
    *   **xargs**: Turning text stream into command arguments.

---

## 🚀 The Power of Pipelines

In Part 2, you stop running commands one by one and start building **Processing Pipelines**:

```bash
# Example: Find top 5 error-causing IPs in Nginx logs
cat access.log | grep "500" | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 5
```

---

## 🛠️ The Toolkit

*   **Standard Utils**: `cat`, `grep`, `sort`, `uniq`, `tail`, `head`.
*   **Advanced Utils**: `sed`, `awk`, `jq`.

---
**Status**: ✅ Organized (2026-02-02)
