# Safety Guards and Locks

Destructive automation requires multiple layers of safety. A single unset variable should never result in `rm -rf /`.

## 📚 Module Structure
- **[Boilerplates](README.md)**: `safe_cleanup.sh` (Locking and Variable checks).
- **[CHALLENGES](./CHALLENGES.md)**: Building a "Self-Protecting" script.

---

## 🏗️ Scenario: The "Recursive Delete" Safety Guard
**Problem**: A cleanup script ran `rm -rf $DIR/*`. If `$DIR` was empty, it became `rm -rf /*`.
**Solution**: Use protective expansion `${DIR:?}`.

---

## 🏗️ Scenario: The "Race Condition" Lock
**Problem**: Concurrent cron jobs modifying the same files.
**Solution**: Use `flock`.

```bash
exec 200>/var/lock/myapp.lock
flock -n 200 || { echo "Script already running!"; exit 1; }
```

---

## 📖 Real-World Story: The "Company Deleter"
A junior engineer once ran a script that was supposed to clear `/tmp/cache`. Due to a typo in the variable name, the script ran `rm -rf / bin/`. The system immediately crashed as the binaries were deleted. 
**Lesson**: Always use `[[ -d "$VAR" ]]` checks and NEVER run destructive commands as Root unless absolutely necessary.

---

## ❓ Interview Questions
1. **How do you prevent a Bash script from running multiple times?**
   - *Answer*: Use `flock` or a manual PID file check.
2. **What does the `:?` syntax do in Bash?**
   - *Answer*: It checks if a variable is set and non-null. If not, it prints an error message and exits with code 1.

---

[Next: Log Analysis](../02-Log-Analysis-and-Parsing/README.md)
