# 🐚 Intermediate Shell Scripting Mastery

Welcome to the **Intermediate Shell Scripting** track. This phase focuses on the **Architecture of Automation**—moving beyond basic syntax into modular, fail-safe, and production-grade system engineering.

---

## 🗺️ Curriculum Path

### 1. [01-Introduction](./01-Introduction/README.md)
The role of Shell as "Glueware," system architecture, and why Bash remains the industry standard for DevOps.

### 2. [02-Intermediate-Logic](./02-Intermediate-Logic/README.md)
Advanced iteration (Associative Arrays), Complex Conditionals (Regex matching), and Arithmetic.

### 3. [03-Advanced-Functions-and-Modularity](./03-Advanced-Functions-and-Modularity/README.md)
**The Core Module**. Building function libraries, managing local variable scope, and sourcing code across the fleet.

### 4. [04-Advanced-IO-and-Logging](./04-Advanced-IO-and-Logging/README.md)
Professional data plumbing. Redirecting `stderr`, mastering File Descriptors 3-9, and the `pipefail` protocol.

### 5. [05-Signal-Handling-and-Traps](./05-Signal-Handling-and-Traps/README.md)
Resilient scripting. Using `trap` for automated cleanup, handling `Ctrl+C`, and signal propagation.

### 6. [06-Regex-and-Data-Parsing](./06-Regex-and-Data-Parsing/README.md)
The "Triple Threat": `grep -E`, `sed`, and `awk` for high-performance log analysis.

### 7. [07-Assessments](./07-Assessments/README.md)
Prepare for your next role with technical interview deep-dives, professional quizzes, and mastery challenges.

---

## 🛡️ The "Fail-Fast" Standard
All scripts in this track adhere to the **DevOps Fail-Fast Protocol**:
```bash
#!/usr/bin/env bash
# Author: Ganil
set -euo pipefail
```

---

[⬅️ Back to Infrastructure Automation](../README.md)
