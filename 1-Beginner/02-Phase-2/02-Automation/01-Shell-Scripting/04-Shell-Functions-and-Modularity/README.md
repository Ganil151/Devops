# Module 4: Functions and Modules - Building Reusable DevOps Components

## 🎯 Learning Objectives
- Master function creation and advanced parameter handling
- Build modular, reusable DevOps automation libraries
- Implement enterprise-grade error handling and logging
- Create scalable code organization patterns
## 📚 Core Concepts
### Function Architecture in DevOps Context
![Function Architecture](../../assets/function_architecture.svg)
## 🧱 Defining Functions
Functions in Bash are defined using the `function` keyword or simply with `()`.
```bash
# Style 1
function log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Style 2 (More common)
print_usage() {
    echo "Usage: $0 --option"
}
```
### Advanced Parameter Handling
```bash
# Multiple parameter patterns
process_deployment() {
    local app_name="$1"
    local environment="$2"
    local version="${3:-latest}"  # Default value
    local config_file="${4:-/etc/app/config.yml}"
    
    # Validate required parameters
    [[ -z "$app_name" ]] && { echo "Error: App name required"; return 1; }
    [[ -z "$environment" ]] && { echo "Error: Environment required"; return 1; }
    
    echo "Processing: $app_name v$version -> $environment"
}

# Named parameters using associative arrays (Bash 4+)
declare -A deployment_config
set_deployment_config() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --app) deployment_config["app"]="$2"; shift 2 ;;
            --env) deployment_config["env"]="$2"; shift 2 ;;
            --version) deployment_config["version"]="$2"; shift 2 ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
    done
}
```
### Passing Arguments
Functions do not take named arguments like `function(arg1, arg2)`. Instead, they use positional parameters just like the script itself:
-   `$1`, `$2`, ...: The arguments passed to the function.
-   `$@`: All arguments.
-   `$#`: Number of arguments.
```bash
calculate_sum() {
    local SUM=$(( $1 + $2 ))
    echo "$SUM"
}

TOTAL=$(calculate_sum 5 10)
```

> [!IMPORTANT]
> Always use the `local` keyword inside functions to ensure variables don't bleed into the global script scope.
## 🏗️ DevOps Function Library Patterns

### System Monitoring Functions
```bash
# Health check function with return codes
check_service_health() {
    local service_name="$1"
    local timeout="${2:-30}"
    
    if systemctl is-active --quiet "$service_name"; then
        echo "✅ $service_name is running"
        return 0
    else
        echo "❌ $service_name is not running"
        return 1
    fi
}

# Resource monitoring with thresholds
check_system_resources() {
    local cpu_threshold="${1:-80}"
    local memory_threshold="${2:-85}"
    local disk_threshold="${3:-90}"
    
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    local alerts=()
    
    (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )) && alerts+=("CPU: ${cpu_usage}%")
    (( memory_usage > memory_threshold )) && alerts+=("Memory: ${memory_usage}%")
    (( disk_usage > disk_threshold )) && alerts+=("Disk: ${disk_usage}%")
    
    if [[ ${#alerts[@]} -gt 0 ]]; then
        echo "⚠️ Resource alerts: ${alerts[*]}"
        return 1
    else
        echo "✅ All resources within limits"
        return 0
    fi
}
```
### Deployment Automation Functions
```bash
# Blue-green deployment function
blue_green_deploy() {
    local app_name="$1"
    local new_version="$2"
    local current_slot="$3"  # blue or green
    
    local target_slot
    [[ "$current_slot" == "blue" ]] && target_slot="green" || target_slot="blue"
    
    echo "🚀 Starting blue-green deployment: $app_name v$new_version"
    echo "Current: $current_slot -> Target: $target_slot"
    
    # Deploy to target slot
    if deploy_to_slot "$app_name" "$new_version" "$target_slot"; then
        echo "✅ Deployment to $target_slot successful"
        
        # Health check
        if health_check_slot "$app_name" "$target_slot"; then
            echo "✅ Health check passed, switching traffic"
            switch_traffic "$app_name" "$target_slot"
            return 0
        else
            echo "❌ Health check failed, rolling back"
            cleanup_slot "$app_name" "$target_slot"
            return 1
        fi
    else
        echo "❌ Deployment failed"
        return 1
    fi
}
```
## 🏁 Exit Codes and Returns
Functions in Bash don't "return" values in the traditional sense (like a string).
-   **Return Statement**: `return` produces an **exit status** (0-255), not data.
-   **Returning Data**: To return data, `echo` it from the function and capture it using command substitution: `RESULT=$(my_func)`.
## 📦 Module Organization Patterns
### Library Structure
```bash
# lib/common.sh - Common utilities
source_library() {
    local lib_path="$1"
    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
    else
        echo "Error: Library not found: $lib_path" >&2
        return 1
    fi
}

# lib/logging.sh - Logging functions
setup_logging() {
    local log_file="${1:-/var/log/devops-automation.log}"
    local log_level="${2:-INFO}"
    
    export LOG_FILE="$log_file"
    export LOG_LEVEL="$log_level"
    
    # Ensure log directory exists
    mkdir -p "$(dirname "$log_file")"
}

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}
```
## 📦 Script Arguments and `shift`
When your script receives many arguments, `shift` is useful for processing them one by one.
```bash
while [ $# -gt 0 ]; do
    case "$1" in
        --help) print_usage; exit 0 ;;
        --user) USERNAME="$2"; shift ;; # Move to next arg
    esac
    shift # Move to next arg
done
```
## 🔍 Error Handling and Debugging
### Advanced Error Handling
```bash
# Error handling with cleanup
cleanup() {
    local exit_code=$?
    echo "Cleaning up resources..."
    # Cleanup logic here
    exit $exit_code
}

trap cleanup EXIT ERR

# Function with comprehensive error handling
safe_deployment() {
    local app_name="$1"
    local version="$2"
    
    # Pre-deployment validation
    validate_deployment_params "$app_name" "$version" || {
        log_message "ERROR" "Validation failed for $app_name v$version"
        return 1
    }
    
    # Create backup point
    local backup_id
    backup_id=$(create_backup "$app_name") || {
        log_message "ERROR" "Failed to create backup for $app_name"
        return 1
    }
    
    # Attempt deployment
    if ! deploy_version "$app_name" "$version"; then
        log_message "ERROR" "Deployment failed, initiating rollback"
        restore_backup "$app_name" "$backup_id"
        return 1
    fi
    
    log_message "INFO" "Deployment successful: $app_name v$version"
    return 0
}
```

---

## 📖 Stories from the Field: The Recursive Disaster
**Scenario**: A sysadmin wrote a function to recursively delete "temp" files.
**Problem**: The function had a bug where it accidentally called itself with an empty string as an argument. Because they didn't use `local` variables, the empty argument modified the global "current directory" variable.
**Outcome**: The script started deleting from the root directory instead of the temp folder.
**Resolution**: Added `local` keywords and strict input validation at the start of every function.
**Prevention**: Never pass unvalidated variables to destructive commands like `rm`. Always use `local` to isolate function logic.

---
## ❓ Interview Questions

1.  **What does the `local` keyword do?**
    <details>
    <summary>Show Answer</summary>
    It restricts the scope of a variable to the function where it is defined, preventing it from overwriting variables in the rest of the script.
    </details>
2.  **How do you return a value from a bash function?**
    <details>
    <summary>Show Answer</summary>
    To return an exit status, use `return N`. To return data (like a string), use `echo "data"` and capture it with `VAR=$(function_name)`.
    </details>
3.  **What does `shift` do?**
    <details>
    <summary>Show Answer</summary>
    It shifts the positional parameters (e.g., `$2` becomes `$1`, `$3` becomes `$2`). This is often used to parse command-line flags.
    </details>
4.  **Can a function be exported to other scripts?**
    <details>
    <summary>Show Answer</summary>
    Yes, using `export -f function_name`, provided the sub-script is executed within the same environment (e.g., via `source` or a child bash process).
    </details>
5.  **How do you find the name of the current function inside itself?**
    <details>
    <summary>Show Answer</summary>
    Use the special array variable `${FUNCNAME[0]}`.
    </details>
6.  **How do you implement blue-green deployment in shell functions?**
    <details>
    <summary>Show Answer</summary>
    Create functions that deploy to alternate environments (blue/green), perform health checks, and switch traffic only after validation.
    </details>
7.  **What's the best practice for parameter validation in functions?**
    <details>
    <summary>Show Answer</summary>
    Validate required parameters at the beginning of the function and return early with meaningful error messages if validation fails.
    </details>

---

## 🧠 Quiz

1.  **Which keyword limits a variable's scope to a function?** `(local)`
2.  **How do you access the second argument passed to a function?** `($2)`
3.  **What is the maximum value a `return` statement can provide?** `(255)`
4.  **T/F: `RESULT=function_name` will capture the output of a function.** `(False - must use substitution: RESULT=$(function_name))`
5.  **What command moves `$2` into the `$1` position?** `(shift)`
6.  **How do you create a function library in shell scripting?** `(Create separate .sh files and source them using 'source' or '.')`
7.  **What's the recommended way to handle errors in DevOps functions?** `(Use trap for cleanup, validate inputs early, and provide meaningful return codes)`
## 📝 Best Practices Summary
1. **Function Design**: Keep functions focused on single responsibility
2. **Error Handling**: Use `set -euo pipefail` and implement cleanup functions
3. **Code Organization**: Separate concerns into different library files
4. **DevOps Integration**: Design functions for automation pipelines with monitoring capabilities
## 🔗 Integration with Other Modules
- **Module 1**: Environment setup for function libraries
- **Module 2**: Variable scoping in functions
- **Module 3**: Control flow within functions
- **Module 4**: File operations in deployment functions