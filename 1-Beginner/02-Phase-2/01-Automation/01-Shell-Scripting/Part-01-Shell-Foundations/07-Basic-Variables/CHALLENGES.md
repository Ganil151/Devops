# 🎯 Hands-On Challenges: Basic Variables

## Challenge 1: The Environment Configurator (Mission-Based Beginner)

**Objective**: Configure the environment variables for a fictional Docker container.

**The Why**: In Docker and Kubernetes, you don't edit files inside the container. You pass configuration via **Environment Variables** (e.g., `DB_HOST=10.0.0.1`).

**Scenario**: You are writing the startup script for a web server container.

**Tasks**:
1. **Define the App Config**:
   - Set `APP_NAME` to "billing-service"
   - Set `APP_ENV` to "production"
   - Set `MAX_RETRIES` to 5
2. **Define the Database Connection**:
   - Set `DB_HOST` to "db.internal"
   - Set `DB_PORT` to 5432
3. **Generate the Startup Message**:
   - Create a variable `STARTUP_MSG` that combines them: 
     `"Starting billing-service in production mode (DB: db.internal:5432)"`
4. **Print the Message**:
   - use `echo "$STARTUP_MSG"`

**Expected Output**:
```bash
Starting billing-service in production mode (DB: db.internal:5432)
```

**Common Mistakes**:
```bash
# ❌ WRONG (Spaces break assignment)
APP_NAME = "billing-service"

# ❌ WRONG (Missing braces in complex strings)
# echo "DB: $DB_HOST:$DB_PORT" might work, but...
# echo "Backup_${APP_NAME}_today" needs braces!
```

**Skill Check**:
- Did you use uppercase for environment variables? (Standard convention)
- Did you avoid spaces around `=`?

---

## Challenge 2: The Quoting Safety Drill (Intermediate)

**Objective**: Prevent script crashes caused by filenames with spaces.

**The Why**: "My Document.txt" is one file to a human, but **two** arguments (`My` and `Document.txt`) to a script if not quoted. This is the #1 cause of "argument count" errors in production.

**Scenario**: You are processing a user upload named `Annual Report 2025.pdf`.

**Setup**:
```bash
FILENAME="Annual Report 2025.pdf"
```

**Tasks (Try these and record what happens)**:

1. **The Crash (Unquoted)**:
   - Try: `ls -l $FILENAME`
   - *Result*: Does `ls` try to look for one file or three files?

2. **The Fix (Double Quotes)**:
   - Try: `ls -l "$FILENAME"`
   - *Result*: Should find the single file (if it existed) or report one error.

3. **The Literal Trap (Single Quotes)**:
   - Try: `echo 'Processing $FILENAME'`
   - *Result*: Does it print the filename or the literal string `$FILENAME`?

**Command Substitution Practice**:
- Create a timestamped backup name using `date`:
  ```bash
  BACKUP_NAME="backup_$(date +%Y-%m-%d).tar.gz"
  echo "$BACKUP_NAME"
  ```

**Key Lesson**:
- **Always double quote** variables: `"$VAR"`
- **Single quotes** kill the magic: `'$VAR'` is just text.

---

## Challenge 3: Parameter Expansion Magic (Practical)
**Objective**: Use advanced expansion techniques.

**Tasks**:
1. Default value: `echo ${UNDEFINED:-"default"}` 
2. String length: `echo ${#NAME}`
3. Substring: `echo ${NAME:0:3}`
4. Replace: `echo ${NAME/DevOps/SRE}`
5. Uppercase: `echo ${NAME^^}` (Bash 4+)
6. Lowercase: `echo ${NAME,,}` (Bash 4+)

**Real-World Example**:
```bash
# Configuration with fallbacks
DB_HOST=${DATABASE_HOST:-localhost}
DB_PORT=${DATABASE_PORT:-5432}
echo "Connecting to $DB_HOST:$DB_PORT"
```

---

## Challenge 4: Environment Variables (Advanced)
**Objective**: Manage environment variable scope.

**Setup**:
```bash
# Script 1: parent.sh
#!/bin/bash
LOCAL_VAR="I am local"
export GLOBAL_VAR="I am global"
./child.sh
```

**Tasks**:
```bash
# Script 2: child.sh
#!/bin/bash
echo "Local: $LOCAL_VAR"   # Empty!
echo "Global: $GLOBAL_VAR"  # Works!
```

**Experiment**:
1. Create both scripts
2. Make executable
3. Run `./parent.sh`
4. Observe which variables are accessible

**Lesson**: Only `export`ed variables pass to child processes!

---

## Challenge 5: Special Variables ($?, $$, $@) (Essential)
**Objective**: Master special shell variables.

**Tasks**:
1. Exit code: Create a failing script and check `$?`
   ```bash
   false
   echo "Exit code: $?"  # 1
   
   true
   echo "Exit code: $?"  # 0
   ```

2. Process ID:
   ```bash
   echo "My PID: $$"
   ```

3. All arguments:
   ```bash
   # test.sh
   echo "All args: $@"
   echo "Count: $#"
   echo "Script name: $0"
   ```

---

## Challenge 6: Variable Validation (Security)
**Objective**: Implement defensive programming.

**Dangerous Code**:
```bash
# ❌ DANGEROUS!
rm -rf $TEMP_DIR/*  # If TEMP_DIR is empty, deletes everything!
```

**Safe Version**:
```bash
# ✅ SAFE
TEMP_DIR=${1:?Error: TEMP_DIR not provided}
[[ -d "$TEMP_DIR" ]] || { echo "Not a directory!"; exit 1; }
rm -rf "${TEMP_DIR:?}"/*
```

**Tasks**:
1. Create a safe delete script
2. Test with empty variable
3. Test with invalid directory
4. Verify it prevents disasters

---

## Challenge 7: Array Variables (Intermediate)
**Objective**: Work with array data structures.

**Tasks**:
```bash
# Create array
SERVERS=("web1" "web2" "db1")

# Access elements
echo ${SERVERS[0]}     # First element
echo ${SERVERS[@]}     # All elements
echo ${#SERVERS[@]}    # Count

# Add element
SERVERS+=("cache1")

# Loop through
for server in "${SERVERS[@]}"; do
    echo "Ping $server"
done
```

**Real-World**: Managing multiple deployment targets!

---

## Challenge 8: Configuration File Variables (Real-World)
**Objective**: Load configuration from external files.

**Setup**:
```bash
# config.env
export APP_NAME="MyApp"
export APP_VERSION="2.0"
export APP_PORT=8080
export APP_ENV="production"
```

**Tasks**:
Create `deploy.sh`:
```bash
#!/bin/bash
set -euo pipefail

# Load configuration
if [[ -f config.env ]]; then
    source ./config.env
else
    echo "ERROR: config.env not found"
    exit 1
fi

echo "Deploying $APP_NAME v$APP_VERSION"
echo "Environment: $APP_ENV"
echo "Port: $APP_PORT"

# Validate required vars
: "${APP_NAME:?Missing APP_NAME}"
: "${APP_VERSION:?Missing APP_VERSION}"

echo "✅ Configuration validated"
```

---

## Challenge 9: Dynamic Variable Names (Expert)
**Objective**: Create and access variables dynamically.

**Tasks**:
```bash
# Create variables dynamically
for i in {1..3}; do
    declare "SERVER_$i=server$i.example.com"
done

# Access them
echo $SERVER_1
echo $SERVER_2
echo $SERVER_3

# Or use indirect expansion
var_name="SERVER_2"
echo "${!var_name}"
```

**Real-World**: Loading configs from multiple environments!

---

## Challenge 10: Build a Configuration Manager (Challenge)
**Objective**: Create a professional config management script.

**Requirements**:
Create `config_manager.sh`:
```bash
#!/bin/bash
set -euo pipefail

CONFIG_FILE="${1:-config.env}"

# Function to set config value
set_config() {
    local key="$1"
    local value="$2"
    
    if grep -q "^${key}=" "$CONFIG_FILE" 2>/dev/null; then
        sed -i "s/^${key}=.*/${key}=${value}/" "$CONFIG_FILE"
    else
        echo "${key}=${value}" >> "$CONFIG_FILE"
    fi
    echo "✅ Set $key=$value"
}

# Function to get config value
get_config() {
    local key="$1"
    grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- || echo "Not found"
}

# Function to list all configs
list_configs() {
    if [[ -f "$CONFIG_FILE" ]]; then
        cat "$CONFIG_FILE"
    else
        echo "No config file found"
    fi
}

# Main menu
case "${2:-list}" in
    set)
        set_config "$3" "$4"
        ;;
    get)
        get_config "$3"
        ;;
    list)
        list_configs
        ;;
    *)
        echo "Usage: $0 <config-file> {set|get|list} [key] [value]"
        exit 1
        ;;
esac
```

**Test**:
```bash
./config_manager.sh app.conf set DB_HOST localhost
./config_manager.sh app.conf get DB_HOST
./config_manager.sh app.conf list
```

---

## Verification Checklist
- [ ] Can create and access variables correctly
- [ ] Understand quoting rules (single vs double quotes)
- [ ] Know parameter expansion techniques
- [ ] Understand local vs environment variables
- [ ] Master special variables ($?, $$, $@)
- [ ] Implement variable validation
- [ ] Can work with arrays
- [ ] Know how to source configuration files

## Variable Best Practices
✅ **Always quote variables**: `"$VAR"` not `$VAR`  
✅ **Use braces for clarity**: `${VAR}` not `$VAR`  
✅ **Validate before use**: `${VAR:?error message}`  
✅ **Use uppercase for environment**: `export API_KEY=...`  
✅ **Use lowercase for local**: `local temp_file=...`  

## Common Pitfalls
❌ `VAR = "value"` - Spaces around =  
❌ `$VAR` without quotes - Word splitting  
❌ `rm -rf $DIR/*` - Disaster if DIR is empty  
❌ Forgetting to `export` - Child process won't see it  

## Real-World Application
```bash
# DevOps deployment script
#!/bin/bash
set -euo pipefail

# Load environment-specific config
ENV=${1:-dev}
CONFIG_FILE="configs/${ENV}.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Config not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# Validate required variables
: "${DB_HOST:?DB_HOST not set}"
: "${API_KEY:?API_KEY not set}"

echo "Deploying to $ENV environment..."
echo "Database: $DB_HOST"
```

## Next Steps
Complete these challenges, then proceed to **[Vim Crash Course](../10-Vim-Crash-Course/CHALLENGES.md)** →
