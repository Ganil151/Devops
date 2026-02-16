# 🤖 04: Scripting & Automation (The Force Multiplier)

> **"If you have to do it twice, script it. If you have to do it three times, automate it. If you have to do it forever, let a robot do it."**

Automation is the "Secret Sauce" of DevOps. It’s what allows one SRE to manage 10,000 servers. In this pillar, we master the two languages of the cloud: **Bash** (for quick system tasks) and **Python** (for complex logic and API integrations).

---

## 🗺️ The Narrative: Your Journey

### Phase 1: The Shell Script (Bash)
Bash is the "Glue" that connects Linux commands.
- **Analogy**: A Bash script is like a **Macro**. Instead of typing five commands to clean a disk, you type one.
- **The DevOps Why**: Most "Pipelines" are just a series of Bash commands running inside a container.

### Phase 2: The Automator (Python)
When logic gets complex (JSON parsing, API calls, Cloud SDKs), we switch to Python.
- **Analogy**: If Bash is a **Hammer**, Python is a **Swiss Army Knife**. It’s cleaner, easier to read, and handles data structures like a pro.

### Phase 3: The Handshake (Scripts & The Ecosystem)
- **Linux**: A Bash script using `cron` to rotate logs.
- **Git**: A Python script using `GitPython` to audit commit history.
- **Docker**: Using the `docker-py` library to automatically prune old images based on disk usage.
- **The "Handshake"**: A well-written script ensures that **Linux permissions**, **Network connectivity**, and **Container health** are all verified before a deployment proceeds.

---

## 🏗️ Architectural Overview
<SCRIPTING_AUTOMATION_DIAGRAM>

---

## 🆘 What to do when this fails: Automation Edition

**Issue: "Syntax Error: unexpected end of file" (Bash)**
- **The Cause**: You likely forgot to close a loop (`done`) or an `if` statement (`fi`).
- **The Fix**: Use `shellcheck yourscript.sh`. It’s like a spell-checker for your code.

**Issue: "ModuleNotFoundError" (Python)**
- **The Cause**: You haven't installed the library in your environment.
- **The Fix**: Use **Virtual Environments**! `python -m venv venv && source venv/bin/activate && pip install -r requirements.txt`.

---

## 🛡️ Pro-Tips for SREs
> **Idempotency is King**: A good script should be able to run 10 times and produce the same result every time. Always check if a folder exists *before* you try to create it (`mkdir -p`).

---
*Visit the [Assessment/](./Assessment/) folder to test your knowledge!*
