#!/bin/bash

# AI Assistant Change Application Tool
# Applies code suggestions from AI assistants to files with validation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR=".ai-backups"
LOG_FILE="${BACKUP_DIR}/apply-changes.log"
PATCH_DIR="${BACKUP_DIR}/patches"

# Load AI Toolkit config from VS Code settings
load_vscode_config() {
    local settings_file="$HOME/.vscode/settings.json"
    
    if [[ ! -f "$settings_file" ]]; then
        echo "Error: VS Code settings not found"
        return 1
    fi
    
    # Extract AI Toolkit config using jq
    export AI_TOOLKIT_ENABLED=$(jq -r '.aiToolkit.enabled' "$settings_file")
    export AI_BACKUP_DIR=$(jq -r '.aiToolkit.project.backupLocation' "$settings_file")
    export AI_SCRIPT_DIR=$(jq -r '.aiToolkit.project.scriptDirectory' "$settings_file")
    
    echo "✅ AI Toolkit config loaded from VS Code settings"
}

# Initialize backup directory
setup_backup_system() {
    mkdir -p "$BACKUP_DIR" "$PATCH_DIR"
    touch "$LOG_FILE"
}

# Log function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    echo -e "${BLUE}[${level}]${NC} $message"
}

# Apply changes with git
apply_with_git() {
    local file_path=$1
    local patch_file=$2
    
    log_message "INFO" "Applying patch: $patch_file to $file_path"
    
    # Dry-run first
    if ! git apply "$patch_file" --check 2>/dev/null; then
        log_message "ERROR" "Patch validation failed for $file_path"
        return 1
    fi
    
    # Create backup
    cp "$file_path" "${BACKUP_DIR}/${file_path##*/}.backup.$(date +%s)"
    
    # Apply patch
    git apply "$patch_file"
    log_message "SUCCESS" "Patch applied successfully: $file_path"
    return 0
}

# Apply changes with sed (fallback)
apply_with_sed() {
    local file_path=$1
    local start_marker=$2
    local end_marker=$3
    local new_content=$4
    
    log_message "INFO" "Applying sed replacement to $file_path"
    
    # Create backup
    cp "$file_path" "${BACKUP_DIR}/${file_path##*/}.backup.$(date +%s)"
    
    # Use sed to replace between markers
    if sed -i.tmp "/$start_marker/,/$end_marker/{
        /$start_marker/!{
            /$end_marker/!d
        }
    }" "$file_path"; then
        log_message "SUCCESS" "Sed replacement completed: $file_path"
        rm -f "${file_path}.tmp"
        return 0
    else
        log_message "ERROR" "Sed replacement failed for $file_path"
        return 1
    fi
}

# Verify file changes
verify_changes() {
    local file_path=$1
    
    if [[ ! -f "$file_path" ]]; then
        log_message "ERROR" "File not found: $file_path"
        return 1
    fi
    
    log_message "INFO" "Verifying: $file_path"
    
    # Check syntax for known file types
    case "$file_path" in
        *.sh)
            bash -n "$file_path" 2>/dev/null || {
                log_message "ERROR" "Bash syntax error in $file_path"
                return 1
            }
            ;;
        *.json)
            jq . "$file_path" >/dev/null 2>&1 || {
                log_message "ERROR" "JSON syntax error in $file_path"
                return 1
            }
            ;;
        *.yaml|*.yml)
            if command -v yamllint &>/dev/null; then
                yamllint "$file_path" || {
                    log_message "ERROR" "YAML syntax error in $file_path"
                    return 1
                }
            fi
            ;;
    esac
    
    log_message "SUCCESS" "Verification passed: $file_path"
    return 0
}

# Interactive mode
interactive_mode() {
    setup_backup_system
    
    echo -e "${BLUE}=== AI Assistant Change Application Tool ===${NC}\n"
    
    read -p "Enter file path: " file_path
    
    if [[ ! -f "$file_path" ]]; then
        echo -e "${RED}❌ File not found: $file_path${NC}"
        exit 1
    fi
    
    echo -e "\n${YELLOW}Choose application method:${NC}"
    echo "1. Git patch (most reliable)"
    echo "2. Manual sed replacement"
    
    read -p "Select method (1 or 2): " method
    
    if [[ "$method" == "1" ]]; then
        read -p "Enter patch file path: " patch_file
        apply_with_git "$file_path" "$patch_file" && verify_changes "$file_path"
    elif [[ "$method" == "2" ]]; then
        read -p "Enter start marker (regex): " start_marker
        read -p "Enter end marker (regex): " end_marker
        read -p "Enter new content file path: " content_file
        
        if [[ ! -f "$content_file" ]]; then
            echo -e "${RED}❌ Content file not found${NC}"
            exit 1
        fi
        
        new_content=$(cat "$content_file")
        apply_with_sed "$file_path" "$start_marker" "$end_marker" "$new_content" && verify_changes "$file_path"
    else
        echo -e "${RED}Invalid choice${NC}"
        exit 1
    fi
    
    # Show git diff
    echo -e "\n${BLUE}Changes:${NC}"
    git diff "$file_path" || echo "No git tracked changes"
}

# Batch mode
batch_mode() {
    local config_file=$1
    
    if [[ ! -f "$config_file" ]]; then
        log_message "ERROR" "Config file not found: $config_file"
        exit 1
    fi
    
    setup_backup_system
    
    log_message "INFO" "Starting batch operations from: $config_file"
    
    # Parse JSON config (requires jq)
    if ! command -v jq &>/dev/null; then
        log_message "ERROR" "jq is required for batch mode"
        exit 1
    fi
    
    jq -r '.changes[] | @base64d' "$config_file" | while read -r change; do
        file_path=$(echo "$change" | jq -r '.file')
        patch_file=$(echo "$change" | jq -r '.patch')
        
        if apply_with_git "$file_path" "$patch_file"; then
            verify_changes "$file_path"
        fi
    done
    
    log_message "INFO" "Batch operations completed"
}

# Main
main() {
    if [[ $# -eq 0 ]]; then
        interactive_mode
    elif [[ $# -eq 1 && "$1" == --batch ]]; then
        batch_mode "$2"
    elif [[ "$1" == --help || "$1" == -h ]]; then
        cat <<EOF
${BLUE}AI Assistant Change Application Tool${NC}

Usage:
  $0                          Interactive mode
  $0 --batch <config.json>   Batch mode
  $0 --help                  Show this help

Examples:
  $0
  $0 --batch changes.json

Backup Location: $BACKUP_DIR
Log File: $LOG_FILE
EOF
    else
        echo -e "${RED}Invalid arguments${NC}"
        echo "Run '$0 --help' for usage"
        exit 1
    fi
}

main "$@"