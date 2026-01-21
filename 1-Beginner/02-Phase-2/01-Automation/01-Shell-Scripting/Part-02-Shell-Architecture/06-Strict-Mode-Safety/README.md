# 🛡️ Bash Strict Mode

Defensive programming is the cornerstone of professional shell scripting. By default, Bash is permissive: it lets you reference undefined variables (evaluating them to empty strings) and ignores errors in pipelines. "Strict Mode" forces Bash to behave more like a compiled language—failing fast and explicitly.

## The Standard Header

Every script you write should start with this:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

### 1. The Shebang & Environment

Using `#!/usr/bin/env bash` is the professional standard for portability. It ensures your script finds the correct Bash interpreter regardless of whether it's on Ubuntu (`/bin/bash`), macOS (`/usr/local/bin/bash`), or Alpine Linux.

### 2. The IFS (Internal Field Separator)

By default, Bash splits strings on spaces, tabs, and newlines. Setting `IFS=$'\n\t'` removes the "Space" as a separator. This prevents many bugs where filenames with spaces are accidentally split into multiple arguments during iteration.

## Detailed Breakdown

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

## 🚀 Advanced Defensive Patterns

### Pattern A: The Atomic Cleanup (`trap`)

Scripts often fail midway, leaving orphaned temporary files that clog up disks. Use an atomic cleanup trap to ensure your script leaves no trace.

```bash
# Create a unique temporary directory
TMP_DIR=$(mktemp -d)

# Link the EXIT signal to a cleanup command
trap 'rm -rf "$TMP_DIR"; echo "🧹 Cleanup complete."' EXIT
```

### Pattern B: The Global Logging Wrapper

Instead of peppering your code with `echo`, use a dedicated logging function that includes timestamps and log levels. This makes your automation "Auditable."

```bash
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" >&2
}

log "INFO" "Starting deployment..."
```

---

## 🔗 Next Steps

Now that your scripts are bulletproof, let's learn how to organize them into modular, reusable blocks!

Proceed to: **[Functions and Scope](../Part-18-Functions-and-Scope/README.md)** →
