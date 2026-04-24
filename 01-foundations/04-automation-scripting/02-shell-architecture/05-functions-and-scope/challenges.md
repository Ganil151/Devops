# 🧩 Hands-On Challenges: Functions & Scope

## Target: Modular Architecture

In these challenges, you will stop writing "Single-File Scripts" and start building **Modular Automation**. You will practice encapsulation, return values, and library management.

---

## 🟢 **BEGINNER CHALLENGES (1-3)**

### **Challenge 1: The Modular Logger**
**Mission**: Create a professional logging function that handles timestamps, severity levels, and colors.
1. Define a function `log_m`.
2. Arguments: `$1` = Level (INFO/ERROR), `$2` = Message.
3. Use `local` variables to store the color code.
4. INFO = Green, ERROR = Red.

**Steps**:
```bash
cat > ~/logger_demo.sh << 'EOF'
#!/bin/bash

# Function Definition
log_m() {
    local LEVEL=$1
    local MSG=$2
    local COLOR="\e[0m" # Reset
    local RED="\e[31m"
    local GREEN="\e[32m"
    local TIMESTAMP=$(date "+%H:%M:%S")

    if [[ "$LEVEL" == "ERROR" ]]; then
        echo -e "${RED}[$TIMESTAMP] [$LEVEL] $MSG${COLOR}" >&2
    else
        echo -e "${GREEN}[$TIMESTAMP] [$LEVEL] $MSG${COLOR}"
    fi
}

# Main Script Logic
log_m "INFO" "Starting backup process..."
sleep 1
log_m "INFO" "Connecting to DB..."
sleep 1
log_m "ERROR" "Connection Refused!"
EOF

chmod +x ~/logger_demo.sh
./logger_demo.sh
```

**Why**: Every professional script needs logging. Wrapping it in a function ensures consistency (format, timestamp) across your entire toolset.

---

### **Challenge 2: The Resource Calculator (Return Values)**
**Mission**: Create a function that calculates disk usage and **returns** a string to be captured by the main script.
1. Function `get_disk_usage`.
2. Logic: Run `df -h /` and extract the percentage.
3. Main script: Capture the output into a variable `USAGE`.

**Steps**:
```bash
cat > ~/disk_check.sh << 'EOF'
#!/bin/bash

get_disk_usage() {
    # Extract just the percentage number (e.g. 45)
    # df output: /dev/sda1 ... 45% /
    local percent=$(df -h / | grep '/' | awk '{print $5}' | tr -d '%')
    
    # "Return" the value by echoing it
    echo "$percent"
}

echo "Querying system stats..."

# Capture the output
CURRENT_USAGE=$(get_disk_usage)

echo "Disk is at ${CURRENT_USAGE}% capacity."

if (( CURRENT_USAGE > 90 )); then
    echo "⚠️  Alert: High Disk Usage!"
else
    echo "✅ Disk levels normal."
fi
EOF

chmod +x ~/disk_check.sh
./disk_check.sh
```

**Why**: This pattern separates **Logic** (getting the number) from **Action** (alerting), making the function reusable in other reports.

---

### **Challenge 3: The Library Pattern**
**Mission**: Split your code into two files: a library and a controller.
1. `lib/utils.sh`: Contains `check_root` and `log_m`.
2. `deploy.sh`: Sources the library and runs the logic.

**Steps**:
```bash
# 1. Create directory
mkdir -p ~/scripts/lib

# 2. Create the library
cat > ~/scripts/lib/utils.sh << 'EOF'
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ Error: This script requires root."
        return 1
    fi
}

say_hello() {
    local name=$1
    echo "👋 Hello, $name! Welcome to the system."
}
EOF

# 3. Create the main script
cat > ~/scripts/deploy.sh << 'EOF'
#!/bin/bash

# Import Library
source ./lib/utils.sh

# Use Functions
say_hello "DevOps Engineer"

echo "Checking permissions..."
if check_root; then
    echo "✅ Root access confirmed. Proceeding..."
else
    echo "⚠️  Running in non-privileged mode."
fi
EOF

chmod +x ~/scripts/deploy.sh
~/scripts/deploy.sh
```

**Why**: This is how enterprise automation frameworks are structured. You might have one `utils.sh` used by 50 different deployment scripts.

---

## 🔗 **NEXT STEPS**
Proceed to **[Strict Mode & Safety](../06-strict-mode-safety/readme.md)** →
