# 🔀 Hands-On Challenges: Conditionals

## Target: Logic Implementation

In these challenges, you will build the "brains" of your automation. You will move beyond linear scripts to create tools that make intelligent decisions based on file states, variables, and user input.

---

## 🟢 **BEGINNER CHALLENGES (1-3)**

### **Challenge 1: The Config Guard**
**Mission**: Create a script that acts as a safe-wrapper for reading configuration files.
1. Check if the file `app.conf` exists.
2. If it does, print "Loading config...".
3. If it doesn't, print "❌ Error: Config missing" and generate a default one.

**Steps**:
```bash
cat > ~/config_guard.sh << 'EOF'
#!/bin/bash

CONFIG_FILE="app.conf"

# Your Logic Here:
# 1. Use [[ -f ... ]] to check existence
# 2. Use else to handle the failure case

if [[ -f "$CONFIG_FILE" ]]; then
    echo "✅ Loading config..."
    cat "$CONFIG_FILE"
else
    echo "❌ Error: Config missing."
    echo "Generating default credentials..."
    echo "user=admin" > "$CONFIG_FILE"
    echo "Created default $CONFIG_FILE"
fi
EOF

chmod +x ~/config_guard.sh
./config_guard.sh  # First run (creates file)
./config_guard.sh  # Second run (loads file)
```

**Why**: Production scripts must be "Idempotent" (handle different starting states gracefully).

---

### **Challenge 2: The Server Health Check**
**Mission**: Simulate a monitoring agent that checks server load.
1. Create a variable `LOAD` (integer 0-10).
2. If `LOAD > 8`: Alert "CRITICAL".
3. If `LOAD > 5` but <= 8: Alert "WARNING".
4. Otherwise: "OK".

**Steps**:
```bash
cat > ~/health_check.sh << 'EOF'
#!/bin/bash

# Simulate reading from 'uptime' (using a random number 1-10)
LOAD=$(( RANDOM % 10 + 1 ))

echo "Current System Load: $LOAD"

if (( LOAD > 8 )); then
    echo "🚨 CRITICAL: System Overload!"
    exit 2
elif (( LOAD > 5 )); then
    echo "⚠️  WARNING: High usage."
else
    echo "✅ System Healthy."
fi
EOF

chmod +x ~/health_check.sh
./health_check.sh
```

**Why**: This logic is the foundational building block of monitoring tools like Nagios and Datadog.

---

### **Challenge 3: The Environment Switch**
**Mission**: Use a `case` statement to handle different deployment targets safely.
1. Accept `$1` as the target (dev, stg, prod).
2. Handle capitalization (Dev, DEV).
3. Block unknown targets.

**Steps**:
```bash
cat > ~/deploy_switch.sh << 'EOF'
#!/bin/bash

TARGET="${1,,}" # Convert to lowercase (Bash 4.0+)

case "$TARGET" in
    dev|development)
        echo "🚀 Deploying to Development (Fast Mode)..."
        # commands...
        ;;
    stg|staging)
        echo "🧪 Deploying to Staging (Test Mode)..."
        # commands...
        ;;
    prod|production)
        echo "🔒 Deploying to PRODUCTION (Safety Checks Enabled)..."
        read -p "Are you sure? (y/n) " -n 1
        echo ""
        ;;
    *)
        echo "❌ Error: Unknown target '$1'"
        echo "Usage: $0 [dev|stg|prod]"
        exit 1
        ;;
esac
EOF

chmod +x ~/deploy_switch.sh
./deploy_switch.sh DEV
./deploy_switch.sh production
./deploy_switch.sh foo
```

**Why**: `case` statements are clearer than 10 nested `if` statements for flag processing.

---

## 🟡 **INTERMEDIATE CHALLENGES (4-5)**

### **Challenge 4: The File Extension Sorter**
**Mission**: Loop through files and use Regex Matching `[[ =~ ]]` to categorize them.

**Steps**:
```bash
cat > ~/file_sorter.sh << 'EOF'
#!/bin/bash

touch image.jpg script.py document.txt unknown.xyz

for FILE in *; do
    if [[ "$FILE" =~ \.jpg$ ]]; then
        echo "🖼️  Image detected: $FILE"
    elif [[ "$FILE" =~ \.(py|sh)$ ]]; then
        echo "📜 Script detected: $FILE"
    elif [[ "$FILE" =~ \.txt$ ]]; then
        echo "📄 Text File: $FILE"
    else
        echo "❓ Unknown type: $FILE"
    fi
done
EOF

chmod +x ~/file_sorter.sh
./file_sorter.sh
```

**Why**: Regex matching is critical for processing messy log files or enforcing naming conventions.

---

### **Challenge 5: The "Guard Clause" Refactor**
**Mission**: Refactor a messy nested script into a clean, flat professional script.

**Steps**:
```bash
cat > ~/refactor_me.sh << 'EOF'
#!/bin/bash
# ❌ MESSY NESTED LOGIC
USER_ID=$(id -u)
if [[ $USER_ID -eq 0 ]]; then
    if [[ -f "/etc/debian_version" ]]; then
        echo "Updating Debian System..."
    else
        echo "Not Debian."
    fi
else
    echo "Not Root."
fi
EOF

cat > ~/clean_logic.sh << 'EOF'
#!/bin/bash
# ✅ CLEAN GUARD CLAUSE LOGIC
USER_ID=$(id -u)

# 1. Fail Fast
(( USER_ID != 0 )) && { echo "❌ Error: Must be root"; exit 1; }
[[ ! -f "/etc/debian_version" ]] && { echo "❌ Error: Not Debian"; exit 1; }

# 2. Happy Path
echo "Updating Debian System..."
EOF

chmod +x ~/refactor_me.sh ~/clean_logic.sh
# Try running both (will likely fail if not root, which is expected!)
./clean_logic.sh
```

**Why**: Guard clauses reduce "Cyclomatic Complexity," making scripts easier to read and debug.

---

## 🔗 **NEXT STEPS**
Proceed to **[Loops & Processing](../04-loops-and-processing/readme.md)** →
