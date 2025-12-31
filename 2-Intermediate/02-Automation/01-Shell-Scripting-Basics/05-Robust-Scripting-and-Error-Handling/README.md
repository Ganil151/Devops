# Robust Scripting and Error Handling

Writing a script that works when everything is perfect is easy. Writing a script that fails gracefully and doesn't cause damage when things go wrong is what separates a DevOps pro from a beginner.

## 🚀 The "Strict Mode" (Fail Fast)

At the top of every production-grade script, you should include these settings:

```bash
#!/bin/bash
set -euo pipefail
```

-   **`-e` (errexit)**: Exit immediately if any command returns a non-zero exit status.
-   **`-u` (nounset)**: Treat unset variables as an error and exit immediately.
-   **`-o pipefail`**: If any command in a pipeline fails, the whole pipeline's return status is the failure code. Without this, `false | true` returns success (0).

## 🪤 Handling Cleanups with `trap`

Scripts often create temporary files or locks. If the script crashes or is killed, these files remain. `trap` allows you to run a cleanup function when the script receives a specific signal.

```bash
# Define cleanup logic
cleanup() {
    echo "Cleaning up temp files..."
    rm -rf "$TMP_DIR"
}

# Trap Signals: EXIT (script ends), SIGINT (Ctrl+C), SIGTERM (Kill)
trap cleanup EXIT SIGINT SIGTERM

TMP_DIR=$(mktemp -d)
# ... script logic ...
```

## 🔍 Debugging Your Scripts

Sometimes you need to see exactly what the shell is doing line-by-line.

-   **`set -x` (xtrace)**: Prints every command before executing it (useful for debugging logic).
-   **`set -v` (verbose)**: Prints shell input lines as they are read.
-   **Bash Debugger**: For very complex scripts, tools like `bashdb` can be used for step-through debugging.

---

## 📖 Stories from the Field: The Script that Deleted `/`

**Scenario**: A maintenance script was supposed to delete a specific application folder: `rm -rf "$APP_DIR/*"`.
**Problem**: The `APP_DIR` variable was set via a config file that failed to load. Because `-u` (nounset) was NOT set, Bash treated `$APP_DIR` as an empty string. The command became `rm -rf /*`.
**Outcome**: The script started deleting the entire root filesystem of the production server.
**Resolution**: The sysadmin caught it quickly, but significant damage was done.
**Prevention**: **ALWAYS** use `set -u`. If `$APP_DIR` was empty, the script would have exited immediately with an "unbound variable" error before running the `rm` command.

---

## ❓ Interview Questions

1.  **What does `set -e` do, and why might it be dangerous?**
    *   *Answer*: It stops the script on failure. It can be dangerous if you expect certain commands to fail (e.g., `grep` not finding a match) but want to continue. In those cases, you can use `command || true`.
2.  **How do you debug a script without changing the code?**
    *   *Answer*: Run it as `bash -x script.sh`.
3.  **What is a "Dead Man's Switch" in scripting?**
    *   *Answer*: It's often implemented using `trap`. If the script doesn't reach a successful completion and clear the trap, the trap function runs to alert someone or cleanup state.
4.  **What is the difference between `SIGINT` and `SIGTERM`?**
    *   *Answer*: `SIGINT` (Signal 2) is triggered by `Ctrl+C`. `SIGTERM` (Signal 15) is the default termination signal sent by the `kill` command.
5.  **How do you handle a command that might fail in a script with `set -e`?**
    *   *Answer*: Use `command || [logic_if_failed]` or wrap it in an `if` block.

---

## 🧠 Quiz

1.  **Which `set` option stops the script if a variable is undefined?** `(-u)`
2.  **What command ensures a "cleanup" function runs even if the script crashes?** `(trap)`
3.  **Which `set` option is required to catch errors inside a pipe like `A | B | C`?** `(pipefail)`
4.  **True/False: `set -x` is only useful for production logs.** `(False - it is primarily a debugging tool)`
5.  **Which signal is sent when a user presses `Ctrl+C`?** `(SIGINT)`
