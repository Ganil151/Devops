# 🏆 THE FINAL MISSION: Build the "Ops-Mate" CLI

> **"This is not a lab. This is a production requirement. Your mission is to build a unified tool that your team will actually use."**

---

## 📋 Project Overview
Build a Python-based Command Line Interface (CLI) called **Ops-Mate** that serves as a central hub for day-to-day operations.

### 🏗️ Required Skills to Combine
- ✅ **Argparse**: For subcommands (`health`, `audit`, `deploy`).
- ✅ **Logging**: For audit trails (Console + File).
- ✅ **YAML/JSON**: For multi-server inventory management.
- ✅ **Requests**: For checking web service health.
- ✅ **Subprocess**: For system ping checks.
- ✅ **Pathlib**: For secure file handling.
- ✅ **Regex**: For log parsing/auditing.

---

## 🚀 Requirement 1: The Unified CLI
- Command: `python main.py health` -> Runs health checks.
- Command: `python main.py audit --file <path>` -> Searches for "ERROR" or "CRITICAL" in a log file.
- Command: `python main.py deploy --service <name>` -> Sends a POST request to a webhook receiver.

## 🚀 Requirement 2: The Logic
- **Health**: Loop through a YAML inventory. Return a non-zero exit code if any server is down.
- **Audit**: Use `re.compile` for high performance. Report the count of errors found.
- **Environment**: Load API keys and sensitive URLs from `.env` or System Env Vars.

## 🚀 Requirement 3: Robustness
- **Validation**: Check if the inventory file exists before reading.
- **Resilience**: A single failed server check must NOT stop the rest of the loop.
- **Feedback**: Use the `rich` library or clean f-strings to provide a professional user interface.

---

## 🏁 Success Criteria
1.  **Zero hardcoded secrets**.
2.  **Clean logs** in `logs/ops-mate.log`.
3.  **Correct Exit Codes** (0 for success, non-zero for failure/down servers).
4.  **Unit Tests**: At least 3 tests in `tests/` verifying the core logic.

---

## 🎓 Evaluation Rubric
| Criteria | Weight | Goal |
| :--- | :--- | :--- |
| **Architectural Separation** | 30% | Are CLI, Logic, and Config separated? |
| **Error Handling** | 30% | Does it handle missing files and timeouts gracefully? |
| **Observability** | 20% | Are the logs detailed and useful? |
| **Efficiency** | 20% | Does it use compiled regex and efficient loops? |

---

**You have been prepared. The code is in your hands.** 🚀
