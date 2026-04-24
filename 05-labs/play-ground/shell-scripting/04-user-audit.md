# Lab 04: User Audit & Report

## 🎯 Objective
Create a script that generates a CSV report of all users on the system who have a valid shell (e.g., `/bin/bash` or `/bin/sh`), along with their home directory usage.

## 📝 Starter Template (`audit_users.sh`)
```bash
#!/bin/bash

# TODO: Read /etc/passwd
# TODO: Filter for users with valid shells (not nologin/false)
# TODO: For each user, get du -sh of their $HOME
# TODO: Output format: User,Home,Size
```

## ✅ Solution (`solution_audit_users.sh`)
```bash
#!/bin/bash
# ==============================================================================
# Script: System User Auditor
# Usage: sudo ./audit_users.sh
# ==============================================================================

set -u

OUTPUT_FILE="user_audit_$(date +%F).csv"

# Header
echo "User,UID,Home_Dir,Disk_Usage" > "$OUTPUT_FILE"

# Iterate over /etc/passwd
# Format: user:pw:uid:gid:comment:home:shell
while IFS=: read -r user pw uid gid comment home shell; do
    
    # Filter: Only real shells (allow bash, sh, zsh)
    if [[ "$shell" =~ (bash|sh|zsh)$ ]]; then
        
        # Calculate size (requires sudo for access)
        if [[ -d "$home" ]]; then
            size=$(du -sh "$home" 2>/dev/null | cut -f1) || size="Error"
        else
            size="NoDir"
        fi
        
        echo "$user,$uid,$home,$size" >> "$OUTPUT_FILE"
        echo "Scanned: $user"
    fi

done < /etc/passwd

echo "=========================================="
echo "Report generated: $OUTPUT_FILE"
echo "=========================================="
cat "$OUTPUT_FILE"
```
