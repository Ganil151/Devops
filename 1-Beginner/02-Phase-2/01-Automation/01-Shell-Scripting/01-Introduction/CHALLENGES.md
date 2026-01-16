# 🎯 Hands-On Challenges: Introduction to Shell Scripting

## Challenge 1: Hello DevOps World (Beginner)

**Objective**: Create your first executable shell script.

**Tasks**:

1. Create a file called `hello.sh`
2. Add the shebang line `#!/bin/bash`
3. Add a comment explaining what the script does
4. Print "Hello, DevOps World! Today is [current date]"
5. Make the script executable
6. Run it using `./hello.sh`

**Expected Output**:

```

Hello, DevOps World! Today is Sat Jan 11 14:46:21 EST 2026
```

**Solution**:

```bash
#!/bin/bash
# My first DevOps automation script

echo "Hello, DevOps World! Today is $(date)"
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

Complete these challenges, then proceed to **[Terminal Navigation](../02-Terminal-and-Finder/CHALLENGES.md)** →
