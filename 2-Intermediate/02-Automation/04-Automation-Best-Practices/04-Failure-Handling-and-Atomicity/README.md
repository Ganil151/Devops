# Failure Handling and Atomicity

Automation scales errors just as easily as it scales success. "Failure Handling" ensures that if something goes wrong, the script stops immediately and leaves the system in a clean state.

## 🏃 Fail-Fast Logic

Don't wait for a 500-line script to fail at step 400 because a prerequisite was missing and you didn't check it at step 1.

### Pre-flight Checks (Prerequisites)
Perform these checks at the very beginning of your script:
1.  **Privileges**: Do I have `root` / `sudo`?
2.  **Tools**: Are `curl`, `jq`, or `aws-cli` installed?
3.  **Connectivity**: Can I ping the API / Database?
4.  **Disk Space**: Is there enough room for this backup?

```bash
# Example: Fail if not root
[[ $EUID -ne 0 ]] && { echo "Error: This script must be run as root"; exit 1; }
```

## ⚛️ Atomic Operations (All or Nothing)

If a script fails halfway through updating a config file, it shouldn't leave the file half-written or corrupted. Avoid editing files directly.

### The "Temp-and-Move" Pattern
Instead of `sed -i`, use a temporary file.

```bash
# 1. Write to temp file
sed 's/old/new/' config.yaml > config.yaml.tmp

# 2. Verify temp file (e.g., check if it's not empty)
[[ -s config.yaml.tmp ]] || exit 1

# 3. Move (Atomic Operation)
mv config.yaml.tmp config.yaml
```
The `mv` command is an **atomic operation** at the filesystem level. Either the move happens, or it doesn't—the system never sees a "half-moved" file.

---

## 📖 Stories from the Field: The 2:00 AM Disk Crash

**Scenario**: A maintenance script ran every night to rotate logs. It zipped the logs and then deleted the originals.
**Problem**: One night, the server ran out of disk space *while* the script was zipping a massive log file. The zip failed and was empty (0 bytes).
**Outcome**: Because the script didn't check if the zip succeeded, it proceeded to delete the original log files. All logs for that day were lost.
**Resolution**: The script was refactored to use a check: `[ -s "$ZIP_FILE" ] && rm "$ORG_FILE"`.
**Prevention**: Never delete source data unless you have **verified** that the processing/backup was 100% successful.

---

## ❓ Interview Questions

1. **What is "Atomic Operation" in a Linux shell?**
   * *Answer*: It's an operation that is guaranteed to either complete fully or not happen at all, with no intermediary state. Examples include `mv` and `ln -sf`.
2. **How does `set -e` relate to fail-fast logic?**
   * *Answer*: It tells the shell to exit immediately if any command returns a non-zero exit code, preventing the script from "drilling" into further errors.
3. **What is a "Pre-flight Check"?**
   * *Answer*: A set of validation steps at the start of a script that verify the environment (permissions, dependencies, space) before any changes are made.
4. **How do you handle rollbacks in a script?**
   * *Answer*: By using a `trap` function. If the script fails, the trap triggers a cleanup function that restores backup files or deletes temporary resources.
5. **Why is it safer to use `sed ... > tmp && mv tmp file` than `sed -i`?**
   * *Answer*: If the system crashes or disk fills during a direct edit (`-i`), the original file may be left corrupted. The move pattern ensures the original file remains intact until the new one is fully and safely written.

---

## 🧠 Quiz

1. **Which command is an atomic filesystem operation?** `(mv)`
2. **True/False: You should check for `root` privileges at the end of a script.** `(False)`
3. **What does the `-s` flag check for in a file test?** `(That the file exists and has size > 0)`
4. **Fail-fast logic helps prevent...** `(Partial system corruption / Cascading failures)`
5. **Which bash flag stops execution on any error?** `(set -e)`
