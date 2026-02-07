#!/bin/bash

# ==============================================================================
# Script Name: reorganize.sh
# Description: Renames and reorders directories to follow a strict numeric sequence.
#              Cleans names (kebab-case), pads numbers (01-), and handles conflicts.
# Author:      Gemini Code Assist
# ==============================================================================

# --- Configuration & Defaults ---
LOG_FILE="migration_report.log"
DRY_RUN=false
RECURSIVE=false
START_INDEX=1
TARGET_PATH=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Functions ---

usage() {
    echo -e "${BLUE}Usage: $0 -p <path> [-s <start_index>] [-r] [-d]${NC}"
    echo ""
    echo "Options:"
    echo "  -p <path>   Target directory path (Required)"
    echo "  -s <num>    Start index for numbering (Default: 1)"
    echo "  -r          Recursive mode (Process sub-directories)"
    echo "  -d          Dry-run mode (Show changes without executing)"
    echo "  -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -p /home/gsmash/docs -d        (Dry run on docs folder)"
    echo "  $0 -p /home/gsmash/docs -r        (Recursive cleanup)"
    exit 1
}

log_change() {
    local old="$1"
    local new="$2"
    local status="$3"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Console output
    if [ "$status" == "DRY-RUN" ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Rename: '$old' -> '$new'"
    elif [ "$status" == "SUCCESS" ]; then
        echo -e "${GREEN}[OK]${NC} Renamed: '$old' -> '$new'"
    elif [ "$status" == "SKIPPED" ]; then
        echo -e "${BLUE}[SKIP]${NC} No change: '$old'"
    else
        echo -e "${RED}[ERROR]${NC} $status: '$old'"
    fi

    # File logging
    echo "[$timestamp] [$status] $old -> $new" >> "$LOG_FILE"
}

clean_name() {
    local input_name="$1"
    
    # 1. Convert to lowercase
    local clean="${input_name,,}"
    
    # 2. Extract existing number if present (e.g., "1-intro" -> "1", "intro" -> "")
    local number=""
    if [[ "$clean" =~ ^([0-9]+)[^0-9] ]]; then
        number="${BASH_REMATCH[1]}"
    elif [[ "$clean" =~ ^([0-9]+)$ ]]; then
        number="${BASH_REMATCH[1]}"
    fi

    # 3. Remove the number from the string for cleaning
    if [[ -n "$number" ]]; then
        clean="${clean#$number}"
    fi

    # 4. Replace special characters, spaces, parentheses with hyphens
    clean=$(echo "$clean" | sed -E 's/[^a-z0-9]+/-/g')

    # 5. Remove leading/trailing hyphens
    clean=$(echo "$clean" | sed -E 's/^-+|-+$//g')

    # 6. Pad number to 2 digits (or use provided start index logic if needed)
    # Note: This script prioritizes preserving existing numbers but padding them.
    if [[ -n "$number" ]]; then
        local padded_num=$(printf "%02d" "$number")
        echo "${padded_num}-${clean}"
    else
        # If no number exists, just return the cleaned name
        # (Auto-numbering unnumbered folders would require sorting logic not available in simple iteration)
        echo "$clean"
    fi
}

process_directory() {
    local dir_path="$1"
    local parent_dir=$(dirname "$dir_path")
    local base_name=$(basename "$dir_path")

    # Skip if base_name is empty or root
    [[ -z "$base_name" || "$base_name" == "." || "$base_name" == "/" ]] && return

    local new_base=$(clean_name "$base_name")
    local new_full_path="${parent_dir}/${new_base}"

    # If name hasn't changed, skip
    if [[ "$dir_path" == "$new_full_path" ]]; then
        log_change "$dir_path" "$new_full_path" "SKIPPED"
        return
    fi

    # Conflict Handling
    if [[ -e "$new_full_path" && "$dir_path" != "$new_full_path" ]]; then
        # If target exists (and isn't us, e.g. case change on case-insensitive FS), append timestamp
        local timestamp=$(date +%s)
        new_full_path="${new_full_path}_conflict_${timestamp}"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_change "$dir_path" "$new_full_path" "DRY-RUN"
    else
        if mv "$dir_path" "$new_full_path"; then
            log_change "$dir_path" "$new_full_path" "SUCCESS"
        else
            log_change "$dir_path" "$new_full_path" "FAILED"
            return 1
        fi
    fi
}

# --- Main Execution ---

# Parse arguments
while getopts "p:s:rdh" opt; do
    case $opt in
        p) TARGET_PATH="$OPTARG" ;;
        s) START_INDEX="$OPTARG" ;;
        r) RECURSIVE=true ;;
        d) DRY_RUN=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Validation
if [[ -z "$TARGET_PATH" ]]; then
    echo -e "${RED}Error: Target path (-p) is required.${NC}"
    usage
fi

if [[ ! -d "$TARGET_PATH" ]]; then
    echo -e "${RED}Error: Directory '$TARGET_PATH' does not exist.${NC}"
    exit 1
fi

# Initialize Log
echo "--- Migration Started: $(date) ---" >> "$LOG_FILE"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Starting Dry-Run Mode...${NC}"
else
    echo -e "${BLUE}Starting Migration...${NC}"
fi

# Traversal Logic
# We use find with -depth to rename children before parents, ensuring paths remain valid.
FIND_CMD="find \"$TARGET_PATH\" -mindepth 1 -type d"

if [ "$RECURSIVE" = false ]; then
    FIND_CMD="$FIND_CMD -maxdepth 1"
fi

# Add -depth to process leaves first
FIND_CMD="$FIND_CMD -depth"

# Execute find and loop
eval "$FIND_CMD" | while read -r dir; do
    process_directory "$dir"
done

echo -e "${BLUE}Operation Complete. Check $LOG_FILE for details.${NC}"

