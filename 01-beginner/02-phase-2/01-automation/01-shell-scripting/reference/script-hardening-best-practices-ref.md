# 🛡️ Shell Script Hardening & Best Practices
*Version 1.0 | Engineering Production-Grade Shell Automation*

---

## 📖 Overview
Shell scripts are notorious for being fragile and "hacky." However, in a production SRE environment, shell scripts often run with high privileges (Root/Sudo). Hardening your scripts is not just about reliability; it is about security and auditability.

---

## 🧱 The "Safety Header" (Strict Mode)
Always start your production scripts with these settings to catch errors early.
```bash
#!/usr/bin/env bash
set -e          # Exit immediately if a command exits with a non-zero status.
set -u          # Treat unset variables as an error.
set -o pipefail # The return value of a pipeline is the status of the last command to fail.

# IFS=$'\n\t'   # Prevents accidental word splitting on spaces.
```

---

## 🔒 Security Best Practices

### 1. Avoid `eval`
**Definition**: `eval` takes a string and executes it as a command.
**Risk**: If the string contains user-controlled input, it leads to **Command Injection**.
**Rule**: Never use `eval` for external data. Use environment variables or configuration files.

### 2. Path Sanitation
Never rely on the user's `$PATH`.
**Rule**: Define your own PATH or use absolute paths for critical binaries.
`GIT_BIN="/usr/bin/git"`

### 3. File Permissions
**Rule**: Scripts should be `chmod 755` (Owner can edit, others can only read/execute).
**Rule**: Never hardcode credentials. Use environment secrets or a secure Vault.

---

## ⚙️ Error Handling & Logging

### Global Cleanup (The `trap` Pattern)
Ensure temp files are deleted even if the script crashes.
```bash
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT
```

### Standard Logging Format
Always print to `stderr` for errors to avoid polluting `stdout` (which might be piped to another tool).
```bash
log_error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S')] ERROR: $*" >&2
}
```

---

## 🚀 Scaling & Maintenance

- **Modularize**: Use functions for repetitive logic.
- **Checkers**: Always run **ShellCheck** (`shellcheck my-script.sh`) during your CI/CD pipeline to catch syntax errors and non-POSIX behavior.
- **Dry Run**: Support a `-n` or `--dry-run` flag so users can see what the script *would* do without making changes.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the impact of `set -o pipefail` on a multi-command pipeline.**
2. **What is the risk of using `cat password.txt | xargs ./script.sh` in terms of process visibility?**
3. **How do you handle "Race Conditions" when creating lock files in a script?**
4. **Why is `#!/usr/bin/env bash` preferred over `#!/bin/bash` in multi-OS environments?**
5. **Describe how "Command Injection" occurs in a script that processes filenames provided by a user.**

---
**Next Step**: [POSIX vs. Bash Compatibility →](./POSIX-vs-Bash-Compatibility-Ref.md)
