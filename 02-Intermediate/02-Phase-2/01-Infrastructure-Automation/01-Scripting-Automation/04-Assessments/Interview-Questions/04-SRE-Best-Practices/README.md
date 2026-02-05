# SRE and Automation Best Practices

Reliability is the goal of automation. You should know the "Check-Act-Verify" pattern, Atomicity, and the Maturity Model.

## 🎤 Top 10 Questions

1.  **What is 'Fail-Fast' and why is it used?**
    - *Answer*: Verifying all conditions (disk space, permissions) before starting work to avoid partial failure.
2.  **What is a 'Pre-flight Check'?**
    - *Answer*: A check at the start of a script that verifies the environment is ready.
3.  **Explain 'Atomicity' in file editing.**
    - *Answer*: Writing to a temp file and renaming it to ensure zero corruption if the script crashes mid-write.
4.  **What is the 'Automation Maturity Model'?**
    - *Answer*: A scale from Manual (1) to Autonomous/Self-Healing (5).
5.  **What is 'Configuration Drift'?**
    - *Answer*: When servers' actual state differs from their intended state because of manual changes.
6.  **Why should you use Structured Logging (JSON)?**
    - *Answer*: Because it is machine-readable and easy to index in ELK or Splunk.
7.  **What is a 'Dry Run'?**
    - *Answer*: A safety mode that reports what *would* happen without doing it.
8.  **How do you handle 'Retries' with 'Exponential Backoff'?**
    - *Answer*: Retrying the same action multiple times but increasing the wait time between each attempt (2s, 4s, 8s, etc.).
9.  **What is 'Toil' and how do you measure it?**
    - *Answer*: Manual, repetitive work. You measure it by the time a person spends doing manual tasks vs engineeing tasks.
10. **Explain 'Self-healing' automation.**
    - *Answer*: A system that automatically repairs a failure when a monitoring alert is triggered (Level 5).

---

## 🛠️ Performance Task
**Task**: Build a "Safety First" script that performs a destructive action (like clearing a folder) but requires a `--force` flag and checks for a specific "guard" file before proceeding.

[Check challenges for more tasks.](./CHALLENGES.md)
