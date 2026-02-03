# 💻 Shell Scripting Mastery: The Universal Glue

> **"Python is for the logic. Terraform is for the state. But Bash? Bash is the glue that holds the entire cloud together."**

Welcome to **Shell Scripting Mastery**. In a world of high-level tools, Bash remains the "Language of Last Resort." It is the only guaranteed dependency on every Linux server, every Docker container, and every CI/CD runner. Whether you are debugging a Kubernetes Pod or actively fixing a production outage via SSH, mastery of the shell is what separates a "User" from an "Engineer."

**Why This Matters for Junior DevOps Engineers:**
- 🌍 **Ubiquity**: It runs everywhere. From a Raspberry Pi to an AWS Lambda Layer.
- ⚡ **Speed**: Triage a server in seconds using pipe chains (`|`) that would take 50 lines of Python.
- 🎯 **Interview**: "How do you find the top 5 IPs in a log file?" is the #1 Linux interview question.
- 🔧 **CI/CD**: 90% of GitHub Actions and GitLab CI steps are just Bash commands.

---

## 📚 Table of Contents

1. [The Shell Hierarchy](#-the-shell-hierarchy)
2. [When to Use Bash vs Python](#-when-to-use-bash-vs-python)
3. [The "Unofficial Strict Mode"](#-the-unofficial-strict-mode)
4. [Essential Toolbelt (Sed, Awk, Jq)](#-essential-toolbelt-sed-awk-jq)
5. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
6. [Security Best Practices](#-security-best-practices)
7. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
8. [Hands-On Exercises](#-hands-on-exercises)
9. [Interview Preparation](#-interview-preparation)
10. [Knowledge Check](#-knowledge-check)

---

## 🏗️ The Shell Hierarchy

Not all shell scripts are created equal. We move from **Interactive One-Liners** to **Production Automation**.

```mermaid
graph TD
    A[Interactive: CLI] --> B{Complexity > 10 lines?}
    B -- No --> C[One-Liner / Alias]
    B -- Yes --> D[Script File .sh]
    D --> E{Need Arrays / Hash Maps?}
    E -- No --> F[Structured Bash (Functions)]
    E -- Yes --> G[Switch to Python/Go]
    F --> H[Validation: ShellCheck]
    
    style C fill:#fef3c7,stroke:#d97706
    style F fill:#e0f2fe,stroke:#0369a1
    style G fill:#f0fdf4,stroke:#15803d
```

### 🔍 Hierarchy Breakdown

**Level 1: The One-Liner**
- **What**: Quick chains of commands.
- **Example**: `ps aux | grep nginx | awk '{print $2}' | xargs kill -9`
- **Use Case**: Ad-hoc troubleshooting.

**Level 2: The Wrapper Script**
- **What**: A logical group of commands saved to a file.
- **Example**: A database backup script (`pg_dump > file`).
- **Use Case**: Cron jobs, CI/CD steps.

**Level 3: The "Glue" Application**
- **What**: Complex logic with flags, error handling, and logging.
- **Example**: An init script that checks environment health before starting an app.
- **Use Case**: Container entrypoints.

---

## ⚖️ When to Use Bash vs Python

Knowing **when to stop** is the most important skill in Bash.

| Feature | ✅ Use Bash | ❌ Switch to Python/Go |
|:---|:---|:---|
| **Primary Task** | Running other commands (`git`, `docker`) | Complex Logic / Algorithms |
| **Data Types** | Strings, Integers | JSON, Lists, Objects, Floats |
| **Dependencies** | None (Standard Utils) | External Libraries (Boto3, Requests) |
| **Performance** | Fast process startup | Better CPU/Math performance |
| **Lines of Code** | Under 100 lines | Over 100 lines |

**Rule of Thumb**: If you are trying to parse JSON with regex in Bash, **STOP**. Use Python.

---

## 🛡️ The "Unofficial Strict Mode"

By default, Bash is terrifyingly PERMISSIVE. It ignores errors and undefined variables.
**Production scripts must start with**:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

### Breakdown
1. **`set -e` (Exit Immediate)**: If _any_ command fails, the script crashes instantly. No silent failures.
2. **`set -u` (Unset Vars)**: Using an undefined variable ($FOO) causes a crash. Prevents `rm -rf /$FOO` disasters.
3. **`set -o pipefail`**: If a command in a pipe chain fails (`cmd1 | cmd2`), the whole chain fails.
4. **`IFS`**: Handles spaces in filenames correctly (Internal Field Separator).

---

## 🎭 Real-World DevOps Scenarios

### 🛡️ Scenario 1: The "Undefined Variable" Wipeout

**The Incident:** A cleanup script ran `rm -rf $DIR/*`.
**The Failure:** The variable `$DIR` was never set due to a typo. Bash interpreted it as `rm -rf /*`.
**The Impact:** Deleted the entire root filesystem of the production server.
**The Fix:** `set -u`.
```bash
# With set -u:
$ ./cleanup.sh
./cleanup.sh: line 10: DIR: unbound variable
# Script crashes safely before running rm.
```

### 🔥 Scenario 2: The "Silent Pipe" Failure

**The Incident:** A backup script ran `mysqldump | gzip > backup.gz`.
**The Failure:** `mysqldump` crashed (auth error), but `gzip` kept running successfully. Bash only looks at the *last* command code (gzip), so it reported "Success".
**The Impact:** For 6 months, the company was backing up empty files. Data was lost.
**The Fix:** `set -o pipefail`.
```bash
# With set -o pipefail:
mysqldump | gzip
# If mysqldump fails, the whole exit code is non-zero.
# Deployment/Cron job alerts properly.
```

---

## 💻 Tech Deep-Dive: Defensive Coding

### 1. Quoting is Mandatory
Bash splits arguments by space. Always quote variables.

```bash
file="My Document.txt"

# ❌ BAD: Bash sees: rm, My, Document.txt
rm $file

# ✅ GOOD: Bash sees one argument
rm "$file"
```

### 2. Trap Signals (Graceful Shutdown)
If your script is killed (Ctrl+C or Docker Stop), clean up temp files!

```bash
temp_file=$(mktemp)

cleanup() {
    echo "Cleaning up..."
    rm -f "$temp_file"
}

# Run 'cleanup' on Exit (0) and Signals (INT/TERM)
trap cleanup EXIT INT TERM
```

---

## 🔒 Security Best Practices

### 1. Avoid Injection (Eval)
Never use `eval` with user input. It executes arbitrary code.

### 2. Masking Secrets
When printing commands for debugging (`set -x`), secrets are exposed in logs.
**Mitigation**: Disable trace around sensitive commands.

```bash
set +x # Disable trace
docker login -u "$USER" -p "$PASS"
set -x # Re-enable
```

---

## ⚠️ Common Pitfalls & Solutions

### Pitfall 1: Space in Assignment
```bash
# ❌ BAD (Spaces)
NAME = "John" # Error: NAME: command not found

# ✅ GOOD (No spaces)
NAME="John"
```

### Pitfall 2: Comparing Strings vs Numbers
```bash
# ❌ BAD (Using integer operators for strings)
if [ "$name" -eq "John" ]; then ... 

# ✅ GOOD
# Strings: =, !=, -z (empty), -n (not empty)
if [ "$name" = "John" ]; then ...

# Integers: -eq, -ne, -lt, -gt
if [ "$count" -eq 5 ]; then ...
```

---

## 🎯 Hands-On Exercises

### Exercise 1: The Health Checker
**Objective**: Write a script that checks a website.
**Requirements**:
1. Use `curl` to check `google.com`.
2. If status is not 200, print "Down".
3. Use a Function for the check logic.
4. Use `set -euo pipefail`.

**Starter Code**:
```bash
#!/usr/bin/env bash
set -euo pipefail

check_site() {
    local url="$1"
    # TODO: curl logic
}

check_site "https://google.com"
```

### Exercise 2: Log Analyzer (Pipeline)
**Objective**: Count unique IP addresses in a log file.
**Requirements**:
1. Create a dummy log file.
2. Use `cat`, `awk`, `sort`, `uniq`.
3. Output the top 3 IPs.

---

## 🎙️ Interview Preparation

### Foundation Questions

**1. "What is the Shebang line?"**
- **Answer**: `#!/bin/bash`. It tells the kernel which interpreter to use to execute the file.

**2. "Explain `$?`."**
- **Answer**: It accesses the **Exit Code** of the last executed command. 0 = Success, 1-255 = Failure.

**3. "How do you debug a bash script?"**
- **Answer**: run with `bash -x script.sh` (X-Trace) to see every command as it executes.

### Advanced Scenario Questions

**4. "How do you execute a command in parallel in Bash?"**
- **Answer**: Use the background operator `&` and `wait`.
```bash
process_1 &
process_2 &
wait # Waits for both to finish
```

---

## 🧠 Knowledge Check

**1. Which command triggers strict error checking?**
- [ ] `set -x`
- [x] `set -e`
- [ ] `set -v`

**2. How do you make a script executable?**
- [ ] `chmod 600 file.sh`
- [x] `chmod +x file.sh`
- [ ] `chown +x file.sh`

**3. Which operator redirects Output to a file (overwrite)?**
- [x] `>`
- [ ] `>>` (Append)
- [ ] `|` (Pipe)

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:
- [ ] Write a Shebang correctly.
- [ ] Use `set -euo pipefail` in every script.
- [ ] Write a reusable Function with local variables.
- [ ] Quote all variables.
- [ ] Check Exit Codes (`$?`) manually if needed.

**Score yourself**: 5+/5 = Ready to advance | <5 = Review exercises

[⬅️ Back to Start](../README.md) | [Next: Fundamentals](./01-Fundamentals/README.md) ➡️
