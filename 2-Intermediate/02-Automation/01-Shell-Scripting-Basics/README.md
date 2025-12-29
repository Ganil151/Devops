# Shell Scripting Basics

The shell is the native language of the server. Mastering it allows you to manipulate files, manage processes, and glue different tools together.

---

## 🏗️ Core Concepts

### 1. Variables and Data
In Bash, variables are defined without spaces: `NAME="DevOps"`.
To access them, use the `$` sign: `echo $NAME`.

### 2. Conditionals (if/else)
Useful for making decisions based on status codes.
```bash
if [ -f "/etc/passwd" ]; then
    echo "Password file exists."
fi
```

### 3. Loops (for/while)
Iterate over lists of files, servers, or commands.
```bash
for SERVER in web01 web02 web03; do
    ssh $SERVER "uptime"
done
```

### 4. Exit Status codes
Every command returns a code. `0` means success, anything else means failure.
Check it with `$?`.

---

## 🛠️ Essential Automation Snippets

### A. Checking for Root Privileges
```bash
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi
```

### B. Simple Log Rotation
```bash
find /var/log/myapp -name "*.log" -mtime +7 -exec rm {} \;
```

---

## 💡 Best Practices
- **Shebang**: Always start with `#!/bin/bash`.
- **Quoting**: Use double quotes around variables to prevent word splitting.
- **Fail Fast**: Use `set -e` to exit immediately if any command fails.
