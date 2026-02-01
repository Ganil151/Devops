# 🚰 Hands-On Challenges: Advanced I/O & Redirection

## Target: The Master Plumber

Mastering I/O allows you to route data like a professional engineer. In these challenges, you will build scripts that generate configurations, compare system states, and manage noisy logs.

---

## 🟢 **BEGINNER CHALLENGES (1-3)**

### **Challenge 1: The Secure Vault Generator (Here-Docs)**
**Mission**: Use a Here-Doc to generate a JSON configuration file dynamically.
1. The script should take a "Secret Key" as an argument.
2. It generates a file named `vault.json`.
3. The file must contain the key and a timestamp.

**Steps**:
```bash
cat > ~/vault_gen.sh << 'EOF'
#!/bin/bash

# Check if secret is provided
SECRET="${1:-'default-secret'}"
TIMESTAMP=$(date)

# Use Here-Doc to create JSON
cat <<JSON > vault.json
{
    "secret": "$SECRET",
    "generated_at": "$TIMESTAMP",
    "status": "ready"
}
JSON

echo "✅ Vault configuration generated: vault.json"
cat vault.json
EOF

chmod +x ~/vault_gen.sh
./vault_gen.sh "MY_SUPER_SECRET_123"
```

---

### **Challenge 2: The Silent Auditor (Redirection)**
**Mission**: Run a command that potentially fails (e.g., searching for a missing file) and ensure the screen stays clean, but the error is logged to a file.
1. Try to list a file that doesn't exist.
2. Redirect Success to `/dev/null`.
3. Redirect Errors to `audit_errors.log`.

**Steps**:
```bash
cat > ~/silent_audit.sh << 'EOF'
#!/bin/bash

echo "Starting silent audit..."

# Attempt to list a non-existent file
ls /tmp/secret_file_that_doesnt_exist > /dev/null 2> audit_errors.log

if [[ -s audit_errors.log ]]; then
    echo "⚠️  Audit found issues. Check audit_errors.log"
else
    echo "✅ Audit passed with no errors."
fi
EOF

chmod +x ~/silent_audit.sh
./silent_audit.sh
```

---

### **Challenge 3: The Log T-Junction (tee)**
**Mission**: Run a command and see its output on the screen while simultaneously appending it to a persistent log.

**Steps**:
```bash
# Append local date to a log while seeing it on terminal
date | tee -a ~/system_history.log
```

---

## 🟡 **INTERMEDIATE CHALLENGES (4-5)**

### **Challenge 4: The Differential Probe (Process Substitution)**
**Mission**: Compare the open network ports of two target hosts (or the same host at different times) without creating intermediate temporary files.

**Steps**:
```bash
cat > ~/port_diff.sh << 'EOF'
#!/bin/bash

# We simulate two port scans by creating two dummy files
echo "22, 80, 443" > state_a.txt
echo "22, 80, 443, 8080" > state_b.txt

echo "Detecting differences in open ports..."

# Use process substitution to compare filtered versions of the files
diff <(cat state_a.txt | tr ',' '\n') <(cat state_b.txt | tr ',' '\n')

rm state_a.txt state_b.txt
EOF

chmod +x ~/port_diff.sh
./port_diff.sh
```

---

### **Challenge 5: The TCP Liveness Probe (/dev/tcp)**
**Mission**: Use Bash's internal networking to check if a website is reachable without using `curl` or `ping`.

**Steps**:
```bash
cat > ~/ping_bash.sh << 'EOF'
#!/bin/bash

TARGET="google.com"
PORT=80

echo "Probing $TARGET on port $PORT..."

# Open a TCP connection using file descriptors
if (echo > /dev/tcp/$TARGET/$PORT) &>/dev/null; then
    echo "✅ Success: $TARGET is reachable."
else
    echo "❌ Failure: $TARGET is offline or blocked."
fi
EOF

chmod +x ~/ping_bash.sh
./ping_bash.sh
```

---

## 🔗 **NEXT STEPS**
**Beginner Shell Scripting Complete!** 🚀

Proceed to: **[Python for DevOps Automation](../../01-Automation/02-Python-Basics/README.md)** →
