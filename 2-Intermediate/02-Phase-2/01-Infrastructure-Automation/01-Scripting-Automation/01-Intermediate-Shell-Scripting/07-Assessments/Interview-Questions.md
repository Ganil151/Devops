# ❓ Technical Interview: Intermediate Shell Scripting

### 1. Explain 'Idempotency' with a code example.
**Answer**: Idempotency ensures a script can run multiple times without changing the system state beyond the first run.
```bash
# Not Idempotent
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# Idempotent
grep -q "8.8.8.8" /etc/resolv.conf || echo "nameserver 8.8.8.8" >> /etc/resolv.conf
```

### 2. What is the 'Shebang' and why use /usr/bin/env?
**Answer**: The Shebang (`#!`) tells the kernel which interpreter to use. `/usr/bin/env bash` is more portable than `/bin/bash` as it finds the bash executable in the user's PATH (useful for macOS/BSD/RedHat differences).

### 3. How do you handle a script being terminated (Ctrl+C)?
**Answer**: Use the `trap` command to catch the `SIGINT` signal and execute a cleanup function.
```bash
cleanup() { rm -f /tmp/lock; exit 1; }
trap cleanup INT
```

### 4. Difference between `[ ]` and `[[ ]]`?
**Answer**: `[[ ]]` is a Bash-specific keyword that is more robust than the standard `test` command (`[`). It handles empty strings better, supports regex (`=~`), and doesn't require as much quoting.

### 5. What does `set -e` do?
**Answer**: It tells the script to exit immediately if any command returns a non-zero exit status (failure).
