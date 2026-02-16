# 🧪 DevOps Assessment Tests: The Screening Survival Guide

> **Goal:** Pass the initial "filter" rounds (Online Screens & Take-Homes) that eliminate 80% of candidates before they even talk to a human.

---

## 📂 Overview

Assessment tests are the gatekeepers of the DevOps hiring process. This guide provides the strategic blueprint for mastering both automated screenings and intensive take-home projects.

---

## ⏱️ Section 1: Online Screening Strategies (HackerRank & Beyond)

Online Assessment (OA) tests are the first gate. They are often automated and time-bound. Use these tactics to stay in the top 5% of candidates.

### 🏗️ Common Platforms
- **HackerRank / Codility**: Standard algorithmic and logic tests focusing on efficiency and edge cases.
- **GLIDER.ai**: Often includes live terminal environments for real Linux/K8s troubleshooting.
- **CoderPad**: Usually for live paired-coding sessions with an interviewer.

### 🚀 The 4-Step Strategy
1. **Environment Check**: Ensure stable internet, local IDE ready, and your **[DevOps Cheat Sheets](../../../../08-resources/00-cheatsheets/cheatsheet.md)** open.
2. **Hidden Requirements**: Watch for edge cases (null inputs, memory limits, execution time).
3. **The "DevOps Twist"**: Focus on string manipulation (log parsing), system logic (uptime/usage), and API interaction (fetching/filtering data).
4. **Partial Credit**: Solve the brute-force version first. A 50% score is better than 0%.

### 🛡️ Avoiding "Plagiarism Flags"
Platforms detect patterns. **NEVER** copy-paste directly from LLMs. Use AI to explain logic, then write and type the code yourself.

### 🎯 Pro Tip: Linux Terminal Screeners
In live terminals:
- **Aliases**: `alias k=kubectl` saves critical seconds.
- **Power Tools**: Master `grep` and `awk` for lightning-fast log parsing.
- **History**: Use `history` to recover or refine complex commands.

---

## 🏠 Section 2: Take-Home Project Logic (The "Production-Grade" Standard)

Take-homes are your chance to prove you can build. You aren't timed by a clock, but by your ability to prioritize quality and operations.

### 🏗️ The Winning Submission Checklist
1. **The "Killer" README**: Include an **Architecture Diagram**, Prerequisites, **One-Command Start** (`make deploy`), and a **Trade-offs** section.
2. **IaC Standards**: No hardcoded secrets, pin your provider versions, and mention state management (even if local).
3. **Container Best Practices**: Use Multi-Stage builds, non-root users, and explicit `HEALTHCHECK`s.
4. **The "SRE" Touch**: Add logging, a basic Prometheus/Grafana dashboard, and security scans (`trivy`/`checkov`).

### � Common "Auto-Fail" Mistakes
- **No README**: If it's hard to run, it's a rejection.
- **Secrets in Git**: Checking keys or `.env` files into GitHub.
- **Over-Engineering**: Keep the solution proportional to the task.
- **Broken Code**: Ensure it runs without local path dependencies.

### 🏆 The "4-Hour Rule"
- **Hour 1**: Functional Code (It runs).
- **Hour 2**: Standardize (Variables, Modules, Cleanliness).
- **Hour 3**: Documentation (README, Diagram).
- **Hour 4**: "Operations" Polish (Security scan, Monitoring metrics).

---

## 🧠 Additional Resources
- **[The Self-Assessment Hub](../../../../06-quizzes/README.md)**: Internal quizzes to test your own knowledge before the real thing.

---
*Back to [Interview Mastery](../readme.md)*
