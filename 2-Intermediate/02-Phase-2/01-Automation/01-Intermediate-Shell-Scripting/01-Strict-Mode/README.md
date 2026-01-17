# 🛡️ Bash Strict Mode

Defensive programming is the cornerstone of professional shell scripting. By default, Bash is permissive: it lets you reference undefined variables (evaluating them to empty strings) and ignores errors in pipelines. "Strict Mode" forces Bash to behave more like a compiled language—failing fast and explicitly.

## The Standard Header
Every script you write should start with this:

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
```

## detailed Breakdown

| Flag | Meaning | Use Case |
| :--- | :--- | :--- |
| `-e` | **Exit immediately** | Stops execution if a command exits with a non-zero status. Prevents snowballing errors. |
| `-u` | **Unset variables** | Treats unset variables as an error and exits. Catches typos and missing logic. |
| `-o pipefail` | **Pipeline failure** | Returns the exit status of the *last* command in the pipe that failed, not just the last command of the pipeline. |

---

## 🛑 Why `set -u` is Your Safety Net

Without `set -u`, a simple typo can involve disastrous consequences (like deleting the wrong directory).

### ❌ Comparison: The Risk

**Scenario**: Backup script deleting old backups.

```bash
#!/bin/bash
# Forgot to define BACKUP_PATH!

# Without -u:
rm -rf $BACKUP_PATH/old_data
# Expands to: rm -rf /old_data
# Result: Tries to delete /old_data from root! 😱
```

### ✅ The Fix: Strict Mode

```bash
#!/bin/bash
set -u

# Forgot to define BACKUP_PATH!
rm -rf $BACKUP_PATH/old_data

# Result:
# script.sh: line 4: BACKUP_PATH: unbound variable
# Script exits BEFORE running the command. Safety preserved. 🛡️
```

---

## 🧠 Best Practices
1.  **Defaults**: If a variable *might* be empty intentionally, use default expansion: `${VAR:-default}`. This satisfies `set -u`.
2.  **Explicit Intent**: Declare global variables at the top so their scope and presence are clear.
