# 🎯 Subprocess Execution: System Nervous System Challenges

> **"Python is the brain, Shell is the muscles. These challenges test your ability to coordinate the two without accidental injury."**

---

## 🏆 Challenge 1: The System Health Snapshot
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Create a script that runs basic system commands and summarizes the results.

### Requirements
- Run `uptime` and `whoami`.
- Capture the output as a string.
- Print: "User [user] has been active for [uptime output]".

---

## 🏆 Challenge 2: The Git Branch Guard
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Build a safety script that prevents dangerous operations on the `main` branch.

### Requirements
- Run `git branch --show-current`.
- If the output is "main", print a big warning: "⚠️ DANGER: You are on the MAIN branch!".
- If it's any other branch, print: "✅ Safe to proceed on [branch name]".
- Handle the case where the current directory is not a Git repository (check the exit code!).

---

## 🏆 Challenge 3: The Docker Inventory Auditor
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Use Python to parse structured JSON output from a shell command.

### Requirements
- Run `docker ps --format "{{json .}}"`.
- Capture the output and parse it using the `json` module (remember: it's one JSON object per line).
- Filter the results to find containers that have been running for more than 24 hours.
- Print a report: "Container [ID] ([Name]) needs a restart (Running for [Time])".
- **Bonus**: Use a `timeout=10` to ensure the script doesn't hang if Docker is slow.

---

## ✅ Completion Checklist
- [ ] Challenge 1: System Health Snapshot
- [ ] Challenge 2: Git Branch Guard
- [ ] Challenge 3: Docker Inventory Auditor
