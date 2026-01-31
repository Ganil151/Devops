# 🛡️ Reference: Robust Execution Keywords

In production DevOps, "Robust Execution" is the difference between a controlled failure and a system-wide catastrophe. Below are the core keywords and configurations that define a resilient Bash tool.

---

## ⚙️ The "Safe Header" Suite

### `set -e` (errexit)
*   **Definition**: Instructs the shell to exit immediately if any command returns a non-zero exit status.
*   **DevOps Why**: Prevents "cascading failures" where a script continues to run even after a critical step (like a database backup) has failed.
*   **Pro Tip**: Use `command || true` if you expect a command to fail occasionally but don't want the script to stop.

### `set -u` (nounset)
*   **Definition**: Treats unset variables and parameters as errors when performing parameter expansion.
*   **DevOps Why**: Prevents disasters like `rm -rf /tmp/$VAR/` where an empty `$VAR` results in the deletion of the entire `/tmp` directory.

### `set -o pipefail`
*   **Definition**: Ensures the exit code of a pipeline is the value of the last (rightmost) command to exit with a non-zero status.
*   **DevOps Why**: By default, a pipeline like `curl -f site.com | jq .` returns success if `jq` succeeds, even if the `curl` failed. `pipefail` catches the hidden API failure.

### `IFS=$'\n\t'` (Internal Field Separator)
*   **Definition**: Controls how Bash splits words and iterates over loops. By default, it splits on spaces.
*   **DevOps Why**: Setting it to newline/tab prevents files with spaces in their names from being split into multiple arguments during loops.

---

## 🪤 Signal & Resource Management

### `trap`
*   **Definition**: A command that intercepts signals (like Ctrl+C or script exit) and executes a specified command or function.
*   **Key Pseudo-Signal: `EXIT`**: Triggers regardless of how the script ends (success, error, or signal). This is the "Golden Standard" for cleanup.

### `mktemp`
*   **Definition**: Atomic creation of a temporary file or directory with a unique, unguessable name.
*   **DevOps Why**: Prevents race conditions and filename collisions when multiple scripts run on the same server.

### `flock`
*   **Definition**: A kernel-level advisory lock on a file.
*   **DevOps Why**: Ensures **Mutual Exclusion**. Prevents a cron job from starting a second instance of a script if the first one hasn't finished yet. Unlike "lock directories," the lock is released automatically if the script crashes.

---

## 🎙️ Staff Interview context
*   **"What is the difference between `trap` and `set -e`?"**
    *   *Answer*: `set -e` is the "Kill Switch" (stops execution on error). `trap` is the "Cleanup Crew" (runs specific logic *after* the switch is flipped).
