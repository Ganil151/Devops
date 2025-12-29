# Advanced Bash Automation

Move beyond "one-liners" to resilient, production-grade automation scripts.

---

## 🧠 Advanced Techniques

### 1. Robust Error Handling
Use `trap` to clean up temporary files if a script crashes.
```bash
trap "rm -f /tmp/temp_file; exit" INT TERM EXIT
```

### 2. Parameterization (Arguments)
Don't hardcode values. Use positional parameters or `getopts`.
```bash
# $1, $2 are arguments passed to the script
echo "Processing environment: $1"
```

### 3. Working with JSON (`jq`)
DevOps engineers deal with APIs. `jq` is the standard for parsing JSON in the shell.
```bash
# Extract the IP address from a JSON response
IP=$(curl -s "http://api.info" | jq -r '.ip')
```

### 4. Remote Execution over SSH
Combine loops with SSH for scale.
```bash
cat servers.txt | while read SERVER; do
    ssh -o ConnectTimeout=5 $SERVER "df -h"
done
```

---

## 🏗️ Building Resilient Scripts
- **Check dependencies**: Does the machine have `curl` or `openssl` installed before you try to use them?
- **Logging**: Redirect output to a log file: `>> automation.log 2>&1`.
- **Dry-run flags**: Implement a `-d` flag that prints what would happen without actually doing it.

---

## 🎯 Key Tool: The "Swiss Army Knife" of Bash
- `sed`: Stream Editor for text transformation.
- `awk`: Pattern scanning and processing language.
- `xargs`: Build and execute command lines from standard input.
