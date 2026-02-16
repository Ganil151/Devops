# 🤖 Pillar 04: Scripting & Automation

> **"If you have to do it twice, script it. If you have to do it three times, automate it. If you have to do it forever, let a robot do it."**

Automation is the "Secret Sauce" of DevOps. It allows one person to manage 1,000 servers. In this pillar, we move beyond just "typing commands" to "writing logic." We build scripts that make decisions, handle errors, and do our work for us while we sleep.

---

## 🗺️ The Narrative: Your Robot Butler

### Bash Fundamentals (The Glue)
Bash is the language of the system. It's how you tell the Linux kernel what to do in a series of steps.
- **Analogy**: A cooking recipe. *If* the oven is hot, *then* put the cake in. *While* the cake is baking, set a timer.
- **The DevOps Why**: Most CI/CD pipelines (GitHub Actions, Jenkins) are just fancy Bash scripts running inside a container.

### Automation Logic (The Brains)
A script that just runs commands is a "macro." A script that checks if a server is healthy before deploying is "Automation."
- **Senior Perspective**: A senior script includes **Error Handling**. If a command fails, the script should stop and tell you why, rather than blindly continuing and breaking things further.

### Real-World Sysadmin Scripts
- **Incident Example**: Every morning at 4:00 AM, the backups failed because the script didn't check for disk space. We fix this by adding a "Pre-Flight Check" to our automation.

---

## 🏗️ Study Guide
1.  **[01-Reference](./01-Reference/)**: Variables, Loops, Exit Codes, and Logic.
2.  **[02-Labs/Sysadmin-Scripts](./02-Labs/Sysadmin-Scripts/)**: Real-world scripts for health monitoring and log rotation.
3.  **[03-Assessment](./03-Assessment/)**: Audit your own scripts—are they idempotent?

---
*Pro-Tip: "Idempotency" is the goal. Your script should be safe to run 10 times and produce the same result every time.*
