# ⌨️ User Input - Hands-On Challenges

## 📚 **Challenge Overview**
Master the art of handling user input in shell scripts. These 10 progressive challenges will take you from basic argument parsing to building secure, professional-grade CLI tools used in enterprise DevOps environments.

---

## 🟢 **BEGINNER CHALLENGES (1-3)**

### **Challenge 1: The Parameterized Script**
**Scenario**: You need to create a deployment script that accepts the environment and version as arguments instead of hardcoding them.

**Task**:
```bash
cat > ~/deploy_params.sh << 'EOF'
#!/bin/bash

# Task:
# 1. Assign $1 to ENVIRONMENT variable (default to "dev" if not provided)
# 2. Assign $2 to VERSION variable (default to "latest" if not provided)
# 3. Check if too many arguments (more than 2) are provided
# 4. Print the deployment summary

# Your code starts here
ENVIRONMENT="${1:-dev}"
VERSION="${2:-latest}"

if [[ $# -gt 2 ]]; then
    echo "Error: Too many arguments provided."
    echo "Usage: $0 [environment] [version]"
    exit 1
fi

echo "Deploying application..."
echo "Environment: $ENVIRONMENT"
echo "Version:     $VERSION"
EOF

chmod +x ~/deploy_params.sh
./deploy_params.sh staging v2.0
./deploy_params.sh
```

**Expected Output**:
```
Deploying application...
Environment: staging
Version:     v2.0

Deploying application...
Environment: dev
Version:     latest
```

**Real-World Application**: Parameterized scripts are essential for CI/CD pipelines where values are passed dynamically by the build server.

---

### **Challenge 2: Interactive Setup Wizard**
**Scenario**: Create a first-run setup wizard that asks the user for configuration details using interactive prompts.

**Task**:
```bash
cat > ~/setup_wizard.sh << 'EOF'
#!/bin/bash

echo "=== Application Setup Wizard ==="

# 1. Ask for Full Name (allow spaces)
read -p "Enter Full Name: " FULL_NAME

# 2. Ask for email with a timeout of 10 seconds
if read -t 10 -p "Enter Email (10s timeout): " EMAIL; then
    echo "" # Newline after successful read
else
    echo ""
    echo "Timeout! Using default email."
    EMAIL="admin@localhost"
fi

# 3. Ask for confirmation (single character y/n)
read -n 1 -p "Confirm settings? [y/n]: " CONFIRM
echo ""

if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
    echo "Saving configuration..."
    echo "User:  $FULL_NAME"
    echo "Email: $EMAIL"
else
    echo "Setup cancelled."
fi
EOF

chmod +x ~/setup_wizard.sh
./setup_wizard.sh
```

**Expected Output**:
```
=== Application Setup Wizard ===
Enter Full Name: Jane Doe
Enter Email (10s timeout): jane@example.com
Confirm settings? [y/n]: y
Saving configuration...
User:  Jane Doe
Email: jane@example.com
```

**Real-World Application**: Installation scripts often use interactive wizards to guide users through initial configuration.

---

### **Challenge 3: Input Validation Basics**
**Scenario**: Ensure the user provides a valid numeric port number for a service configuration.

**Task**:
```bash
cat > ~/port_validator.sh << 'EOF'
#!/bin/bash

while true; do
    read -p "Enter service port (1024-65535): " PORT

    # Validation Logic:
    # 1. Check if input is empty
    # 2. Check if input is a number
    # 3. Check if number is within range
    
    if [[ -z "$PORT" ]]; then
        echo "Error: Port cannot be empty."
        continue
    fi

    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
        echo "Error: '$PORT' is not a number."
        continue
    fi

    if [[ "$PORT" -lt 1024 || "$PORT" -gt 65535 ]]; then
        echo "Error: Port must be between 1024 and 65535."
        continue
    fi

    echo "✅ Valid port configured: $PORT"
    break
done
EOF

chmod +x ~/port_validator.sh
./port_validator.sh
```

**Expected Output**:
```
Enter service port (1024-65535): 80
Error: Port must be between 1024 and 65535.
Enter service port (1024-65535): abc
Error: 'abc' is not a number.
Enter service port (1024-65535): 8080
✅ Valid port configured: 8080
```

**Real-World Application**: Validating input prevents misconfiguration and security vulnerabilities in production systems.

---

## 🟡 **INTERMEDIATE CHALLENGES (4-6)**

### **Challenge 4: Professional Argument Parsing (getopts)**
**Scenario**: Build a robust CLI tool that accepts flags for verbosity, output file, and help using `getopts`.

**Task**:
```bash
cat > ~/cli_tool.sh << 'EOF'
#!/bin/bash

# Defaults
VERBOSE=false
OUTPUT_FILE=""

usage() {
    echo "Usage: $0 [-v] [-o file] [-h]"
    echo "  -v    Enable verbose mode"
    echo "  -o    Specify output file"
    echo "  -h    Show help"
    exit 1
}

while getopts ":vo:h" opt; do
    case ${opt} in
        v)
            VERBOSE=true
            ;;
        o)
            OUTPUT_FILE="$OPTARG"
            ;;
        h)
            usage
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument."
            exit 1
            ;;
        \?)
            echo "Error: Invalid option -$OPTARG"
            usage
            ;;
    esac
done

# Shift processed options away
shift $((OPTIND -1))

if [[ "$VERBOSE" == "true" ]]; then
    echo "Verbose mode enabled."
fi

if [[ -n "$OUTPUT_FILE" ]]; then
    echo "Output will be written to: $OUTPUT_FILE"
else
    echo "Outputting to stdout"
fi

echo "Remaining arguments: $@"
EOF

chmod +x ~/cli_tool.sh
./cli_tool.sh -v -o log.txt input1 input2
```

**Expected Output**:
```
Verbose mode enabled.
Output will be written to: log.txt
Remaining arguments: input1 input2
```

**Real-World Application**: `getopts` is the standard way to build Unix-compliant command-line interfaces.

---

### **Challenge 5: Secure Password Handling**
**Scenario**: Create a script that asks for a password twice to confirm, ensures it meets complexity requirements, and does not show characters on screen.

**Task**:
```bash
cat > ~/secure_pass.sh << 'EOF'
#!/bin/bash

check_complexity() {
    local pass="$1"
    if [[ ${#pass} -lt 8 ]]; then
        echo "Error: Password must be at least 8 characters."
        return 1
    fi
    # Bonus: Add regex check for numbers/special chars if you dare
    return 0
}

while true; do
    # -s hides input
    read -s -p "Enter new password: " PASS1
    echo ""
    
    if ! check_complexity "$PASS1"; then
        continue
    fi

    read -s -p "Confirm password: " PASS2
    echo ""

    if [[ "$PASS1" == "$PASS2" ]]; then
        echo "✅ Password successfully set."
        break
    else
        echo "❌ Passwords do not match. Try again."
    fi
done
EOF

chmod +x ~/secure_pass.sh
./secure_pass.sh
```

**Expected Output**:
```
Enter new password: 
Error: Password must be at least 8 characters.
Enter new password: 
Confirm password: 
✅ Password successfully set.
```

**Real-World Application**: Handling credentials securely (hiding input, validation) is critical for user management scripts.

---

### **Challenge 6: Dynamic Selection Menus**
**Scenario**: Create a script that dynamically lists all text files in the current directory and allows the user to select one to process.

**Task**:
```bash
cat > ~/file_selector.sh << 'EOF'
#!/bin/bash

echo "Select a file to process:"

# Create some dummy files for testing
touch data1.txt data2.txt config.xml

# Use 'select' for simple menus
# We use a glob pattern *.txt to populate the menu
PS3="Enter selection number: "

select FILENAME in *.txt "Quit"; do
    case $FILENAME in
        "Quit")
            echo "Exiting..."
            break
            ;;
        "")
            echo "Invalid option. Please try again."
            ;;
        *)
            echo "You selected: $FILENAME"
            echo "Processing..."
            # Simulate processing
            wc -l "$FILENAME"
            break
            ;;
    esac
done
EOF

chmod +x ~/file_selector.sh
./file_selector.sh
```

**Expected Output**:
```
Select a file to process:
1) data1.txt
2) data2.txt
3) Quit
Enter selection number: 1
You selected: data1.txt
Processing...
0 data1.txt
```

**Real-World Application**: Dynamic menus are great for operations tools, allowing ops engineers to pick from available logs, servers, or snapshots.

---

## 🔴 **ADVANCED CHALLENGES (7-8)**

### **Challenge 7: The Universal Input Validation Library**
**Scenario**: Create a reusable library (sourced file) of validation functions and a main script that uses them.

**Task**:
```bash
# 1. Create the library
cat > ~/validation_lib.sh << 'EOF'
#!/bin/bash

validate_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

validate_ip() {
    [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
}

validate_yes_no() {
    [[ "$1" =~ ^(yes|no|y|n)$ ]]
}

get_input() {
    local prompt="$1"
    local validator="$2"
    local var_name="$3"
    local input
    
    while true; do
        read -p "$prompt: " input
        if $validator "$input"; then
            # Indirect variable assignment
            eval "$var_name=\"$input\""
            break
        else
            echo "Invalid input. Please try again."
        fi
    done
}
EOF

# 2. Create the main script
cat > ~/registration.sh << 'EOF'
#!/bin/bash
source ~/validation_lib.sh

echo "=== User Registration ==="

get_input "Enter User Email" validate_email USER_EMAIL
get_input "Enter Server IP"  validate_ip    SERVER_IP
get_input "Enable SSL? (y/n)" validate_yes_no SSL_ENABLED

echo "-----------------"
echo "Registration Summary:"
echo "Email: $USER_EMAIL"
echo "IP:    $SERVER_IP"
echo "SSL:   $SSL_ENABLED"
EOF

chmod +x ~/registration.sh
./registration.sh
```

**Expected Output**:
```
=== User Registration ===
Enter User Email: bad-email
Invalid input. Please try again.
Enter User Email: user@test.com
Enter Server IP: 999.999
Invalid input. Please try again.
Enter Server IP: 192.168.1.1
Enable SSL? (y/n): y
-----------------
Registration Summary:
Email: user@test.com
IP:    192.168.1.1
SSL:   y
```

**Real-World Application**: Modular code reuse is a hallmark of senior DevOps engineering. Centralizing validation logic reduces bugs across scripts.

---

### **Challenge 8: Audit Logger with Sensitive Data Redaction**
**Scenario**: Create a wrapper function that logs every command execution and argument, but automatically redacts arguments that look like passwords or API keys.

**Task**:
```bash
cat > ~/audit_wrapper.sh << 'EOF'
#!/bin/bash

LOG_FILE="activity.log"

log_action() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local cmd="$1"
    shift
    local args=""
    
    for arg in "$@"; do
        # Simple heuristic: if argument contains "pass", "key", or "secret", redact it
        # Or if it matches a high-entropy string (simplified here)
        if [[ "$arg" =~ (pass|key|secret) ]]; then
            args="$args [REDACTED]"
        else
            args="$args $arg"
        fi
    done
    
    echo "[$timestamp] CMD: $cmd ARGS:$args" >> "$LOG_FILE"
}

# Simulate usage
log_action "db_connect" "--host" "localhost" "--user" "admin" "--password" "SuperSecret123"
log_action "api_call" "--key" "x8s7df68s7d6f" "--endpoint" "/v1/users"

echo "Log contents:"
cat "$LOG_FILE"
EOF

chmod +x ~/audit_wrapper.sh
./audit_wrapper.sh
```

**Expected Output**:
```
Log contents:
[2026-01-11 10:00:00] CMD: db_connect ARGS: --host localhost --user admin --password [REDACTED]
[2026-01-11 10:00:00] CMD: api_call ARGS: --key [REDACTED] --endpoint /v1/users
```

**Real-World Application**: Compliance standards (SOC2, HIPAA) require detailed audit logs, but storing secrets in plain text logs is a severe violation.

---

## 🏆 **CHALLENGE CHALLENGES (9-10)**

### **Challenge 9: The Robust CLI Application**
**Scenario**: Build a "User Manager" tool that combines all previous skills: `getopts`, subcommands (`add`, `delete`, `list`), interactivity, and file database.

**Task**:
```bash
cat > ~/user_manager.sh << 'EOF'
#!/bin/bash

DB_FILE="users.db"
touch "$DB_FILE"

usage() {
    echo "Usage: $0 {add|delete|list} [options]"
    exit 1
}

add_user() {
    local user=""
    local role="user"
    local OPTIND
    while getopts ":u:r:" opt; do
        case $opt in
            u) user="$OPTARG" ;;
            r) role="$OPTARG" ;;
        esac
    done
    
    if [[ -z "$user" ]]; then
        read -p "Enter username: " user
    fi
    
    # Check if user exists
    if grep -q "^$user," "$DB_FILE"; then
        echo "Error: User $user already exists."
        return 1
    fi
    
    echo "$user,$role,$(date)" >> "$DB_FILE"
    echo "User $user added with role $role."
}

list_users() {
    echo "Current Users:"
    echo "NAME      ROLE      CREATED"
    echo "---------------------------"
    column -t -s ',' "$DB_FILE"
}

# Main Dispatcher
COMMAND="$1"
shift

case "$COMMAND" in
    add)
        add_user "$@"
        ;;
    list)
        list_users
        ;;
    delete)
        # Exercise for the reader: Implement delete
        echo "Delete feature pending..."
        ;;
    *)
        usage
        ;;
esac
EOF

chmod +x ~/user_manager.sh
./user_manager.sh add -u johnd -r admin
./user_manager.sh add
./user_manager.sh list
```

**Expected Output**:
```
User johnd added with role admin.
Enter username: guest
User guest added with role user.
Current Users:
NAME      ROLE      CREATED
---------------------------
johnd     admin     Fri Jan 11...
guest     user      Fri Jan 11...
```

**Real-World Application**: This pattern is exactly how tools like `kubectl`, `git`, and `aws` CLI work.

---

### **Challenge 10: The Secure Deployment Wrapper**
**Scenario**: Create a wrapper for a hypothetical deployment command that ensures:
1. Production deployments require explicit confirmation (capital 'YES').
2. Development deployments are auto-approved.
3. Input arguments use long-flags (`--env`, `--version`).
4. All actions are logged.

**Task**:
```bash
cat > ~/secure_deploy.sh << 'EOF'
#!/bin/bash

LOG_FILE="deploy.log"
ENVIRONMENT=""
VERSION=""

log() { echo "$(date): $1" | tee -a "$LOG_FILE"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$ENVIRONMENT" || -z "$VERSION" ]]; then
    echo "Usage: $0 --env <env> --version <ver>"
    exit 1
fi

# Logic
log "Initiating deployment of $VERSION to $ENVIRONMENT"

if [[ "$ENVIRONMENT" == "prod" ]]; then
    echo "⚠️  CRITICAL: You are deploying to PRODUCTION. ⚠️"
    read -p "Type 'YES' to confirm: " CONF
    if [[ "$CONF" != "YES" ]]; then
        log "Production deployment cancelled by user."
        echo "Aborted."
        exit 1
    fi
fi

# Simulation of actual work
log "Starting deployment process..."
sleep 1
log "Deployment of $VERSION to $ENVIRONMENT successful."

EOF

chmod +x ~/secure_deploy.sh

# Test 1: Dev deployment
./secure_deploy.sh --env dev --version v1.1

# Test 2: Prod deployment (simulate abort)
echo "no" | ./secure_deploy.sh --env prod --version v1.2

# Test 3: Prod deployment (simulate success)
echo "YES" | ./secure_deploy.sh --env prod --version v1.2
```

**Expected Output**:
```
...
Starting deployment process...
Deployment of v1.1 to dev successful.
...
CRITICAL: You are deploying to PRODUCTION.
Production deployment cancelled by user.
...
CRITICAL: You are deploying to PRODUCTION.
Starting deployment process...
Deployment of v1.2 to prod successful.
```

**Real-World Application**: Preventing accidental production deployments is one of the most important safety mechanisms in DevOps.

---

## 🎯 **VERIFICATION CHECKLIST**

- [ ] Can you handle positional arguments with defaults?
- [ ] Can you use `read` for timeouts, logic, and hidden input?
- [ ] Have you mastered `getopts` for flag parsing?
- [ ] Can you build a reusable validation library?
- [ ] Do you understand how to separate "Input" from "Logic"?

## 🔗 **NEXT STEPS**
Continue to **[Conditionals](../03-Conditionals/README.md)** →
