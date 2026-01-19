#!/bin/bash
# -----------------------------------------------------------------------------
# Name: strict_template.sh
# Description: A robust boilerplate for Bash scripts using Strict Mode.
# Author: [Your Name]
# -----------------------------------------------------------------------------

# 1. Strict Mode
# -e: Exit on error
# -u: Error on unset variables
# -o pipefail: Fail if any command in a pipe fails
set -euo pipefail
IFS=$'\n\t' 

# 2. Configuration & Globals
APP_NAME="StrictScript"
LOG_FILE="/tmp/${APP_NAME}.log"

# 3. Logging Function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# 4. Main Logic
main() {
    log "Starting script..."
    
    # Example of Safe Variable usage
    local target_dir="${1:-/tmp}" # Default to /tmp if $1 is set
    
    if [[ ! -d "$target_dir" ]]; then
        log "Error: Directory $target_dir does not exist."
        exit 1
    fi

    log "Successfully checked $target_dir"
}

# 5. Execution
main "$@"
