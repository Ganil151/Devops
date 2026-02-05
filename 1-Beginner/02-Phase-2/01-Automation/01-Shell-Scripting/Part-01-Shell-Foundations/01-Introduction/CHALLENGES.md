# 🎯 Hands-On Challenges: Introduction to Shell Scripting

## Challenge 1: The Service Status Reporter (Mission-Based Beginner)

**Objective**: Create your first DevOps automation script - checking if a critical service is running.

**The Why**: In production, you'll write scripts that other tools (Jenkins, GitHub Actions, Kubernetes health checks) depend on. They need to know: **Did this succeed or fail?** That's what exit codes are for.

**Tasks**:

1. Create a file called `check_service.sh`
2. Add the shebang line `#!/usr/bin/env bash` (portable version)
3. Add comments explaining what the script does
4. Check if a service (like `nginx` or `ssh`) is running
5. Print a status message with timestamp
6. **Exit with proper code**: `0` for success, `1` for failure
7. Make the script executable
8. Run it using `./check_service.sh`

**Expected Output (if service running)**:

```
[2026-02-01 02:30:15] Checking nginx service...
✅ nginx is active and running
```

**Expected Output (if service stopped)**:
```
[2026-02-01 02:30:15] Checking nginx service...
🚨 ERROR: nginx is NOT running!
```

**Solution**:

```bash
#!/usr/bin/env bash
# Mission: Check if nginx service is active
# Used by: Monitoring systems, CI/CD health checks

SERVICE="nginx"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking $SERVICE service..."

if systemctl is-active --quiet "$SERVICE"; then
    echo "✅ $SERVICE is active and running"
    exit 0  # Success! Tell the calling system everything is OK
else
    echo "🚨 ERROR: $SERVICE is NOT running!"
    exit 1  # Failure! Tell monitoring/CI/CD to stop and alert
fi
```

**What You Learned**:
- ✅ The shebang (`#!/usr/bin/env bash`) makes scripts portable
- ✅ `exit 0` = success (DevOps best practice)
- ✅ `exit 1` = failure (alerts monitoring systems)
- ✅ `$(date)` = command substitution (runs command, puts output in string)
- ✅ `systemctl is-active --quiet` = check service without verbose output

**Test the Exit Code**:
```bash
./check_service.sh
echo "Exit code was: $?"
# $? contains the exit code of the last command
# 0 = success, non-zero = failure
```

---

## Challenge 2: System Information Reporter (Intermediate)

**Objective**: Create a script that displays system information.

**Tasks**:

1. Create `system_info.sh`
2. Display the following information:
   - Current user
   - Hostname
   - Current directory
   - Shell version
   - Operating system type
3. Use proper formatting with labels

**Expected Output**:

```
=== System Information ===
User: Ganil
Hostname: DESKTOP-ABC123
Current Dir: /home/ganil
Shell: bash version 5.1.16
OS: Linux
```

**Hints**:

- Use `whoami` for username
- Use `hostname` for hostname
- Use `pwd` for current directory
- Use `$BASH_VERSION` for shell version
- Use `uname -s` for OS type

---
## Challenge 3: Shell Type Comparison (Advanced)
**Objective**: Write a script that runs in both Bash and Sh and reports differences.

**Tasks**:
1. Create `shell_compare.sh`
2. Check which shell is executing the script
3. Display shell-specific information
4. Run the script with both `bash` and `sh`
**Sample Code**:
```bash
#!/bin/bash

echo "Executing with: $0"
echo "Shell: $SHELL"
echo "Bash Version: ${BASH_VERSION:-Not Bash}"

# Test array support (Bash-specific)
if [ -n "$BASH_VERSION" ]; then
    arr=(apple banana cherry)
    echo "Arrays supported: ${arr[1]}"
else
    echo "Arrays not supported in this shell"
fi
```

---
## Challenge 4: Script Execution Methods (Practical)
**Objective**: Understand different ways to execute scripts.
**Tasks**:
1. Create `test_exec.sh` with a simple echo command
2. Execute it using ALL these methods:
   - `bash test_exec.sh`
   - `sh test_exec.sh`
   - `./test_exec.sh` (after chmod +x)
   - `source test_exec.sh`
   - `. test_exec.sh`
3. Document which methods require execute permissions

**Questions to Answer**:
- Which methods create a subshell?
- Which methods run in the current shell?
- When would you use `source` vs direct execution?

---

## Challenge 5: DevOps Automation Simulator (Challenge)

**Objective**: Create a script that simulates a basic deployment process.

**Requirements**:

1. Print a banner "=== Deployment Starting ==="
2. Show current date/time
3. Check if user is root (bonus)
4. Print "Backing up configuration..."
5. Print "Deploying application..."
6. Print "Restarting services..."
7. Print "Deployment Complete!"
8. Show total runtime (bonus challenge)

**Advanced Version**:
Add delays between steps using `sleep 1` to simulate real processes.

**Bonus Challenge**:
Use color codes to make output more professional:

```bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "${GREEN}✓ Success${NC}"
```

---

## Verification Checklist

- [ ] Can create and edit bash scripts
- [ ] Understand shebang purpose
- [ ] Can make scripts executable with chmod
- [ ] Know difference between bash and sh
- [ ] Can execute scripts multiple ways
- [ ] Can use basic commands (echo, date, whoami)
- [ ] Understand comments in shell scripts

## Next Steps

Complete these challenges, then proceed to **[Terminal Navigation](CHALLENGES.md)** →
