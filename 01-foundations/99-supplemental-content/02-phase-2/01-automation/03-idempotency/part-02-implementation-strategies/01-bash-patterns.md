# 🛡️ Idempotency in Bash: The "Check-Then-Act" Pattern

Bash is inherently **imperative** and **destructive**. `echo "foo" >> file` will happily corrupt your config if run twice. To write professional automation, you must wrap every action in a "State Check".

## The Pattern
1.  **Check**: Does the desired state already exist?
2.  **Act**: Only if the check fails.
3.  **Verify**: Confirm the state changed (optional but recommended).

---

## ❌ Bad (Non-Idempotent)
```bash
# Appending to a file blindly
# RUN 1: "server=10.0.0.1"
# RUN 2: "server=10.0.0.1" (Duplicate!)
echo "server=10.0.0.1" >> /etc/hosts

# Creating a directory
# RUN 2: "mkdir: cannot create directory: File exists" (Error!)
mkdir /var/www/app

# Installer
# RUN 2: Re-downloads and re-installs, wasting time and bandwidth.
wget http://app.com/install.sh && bash install.sh
```

---

## ✅ Good (Idempotent)

### 1. File Modification
Use `grep` to check for existence before writing.
```bash
# "grep -q" acts silently. Returns 0 (True) if found.
if ! grep -q "server=10.0.0.1" /etc/hosts; then
    echo "Adding server to hosts file..."
    echo "server=10.0.0.1" >> /etc/hosts
else
    echo "Server already in hosts file. Skipping."
fi
```

### 2. Directory Creation
Use the `-p` (parents) flag. It ensures the directory exists and remains silent if it already does.
```bash
# Safe to run 1000 times.
mkdir -p /var/www/app
```

### 3. Installation / Downloads
Check for the binary or the completion marker.
```bash
if [ ! -f "/opt/myapp/bin/app" ]; then
    echo "App not found. Installing..."
    wget http://app.com/install.sh -O /tmp/install.sh
    bash /tmp/install.sh
else
    echo "App is already installed."
fi
```

---

## 🚀 Advanced Pattern: The "Sentinel File"

For complex operations that don't leave a clean binary to check (like a database migration), create a hidden "flag" file to mark completion.

```bash
SENTINEL="/var/log/setup_complete.lock"

if [ -f "$SENTINEL" ]; then
    echo "System already setup. Exiting."
    exit 0
fi

# ... Critical Operations ...
# ... Initialize DB ...
# ... Format Disk ...

# Only create this if everything succeeded (Specific to bash strict mode)
touch "$SENTINEL"
echo "Setup complete."
```
