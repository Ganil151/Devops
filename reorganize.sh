#!/bin/bash

# ============================================================
# auto_reorg.sh — Robust Recursive Folder Renaming Script
# Author: Senior Linux Systems Administrator
# Purpose: Recursively rename folders to a strict numeric sequence
#          with sanitization, dry-run safety, and exclusion rules.
# ============================================================

# ANSI color codes for visual feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=true
FORCE=false
RECURSIVE=false
EXCLUDE_LIST=(".git" ".terraform" "__pycache__" "node_modules")

# Function: Print usage information
print_usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0 [-r|--recursive] [-f|--force] [--dry-run]"
    echo -e ""
    echo -e "Options:"
    echo -e "  -r, --recursive     Apply renaming recursively to subdirectories"
    echo -e "  -f, --force         Execute actual renames (bypass dry-run)"
    echo -e "  --dry-run           Show what would be renamed (default)"
    echo -e ""
    echo -e "Example:"
    echo -e "  $0 --recursive -f        # Rename all folders recursively with force"
    echo -e "  $0 --dry-run             # Simulate renaming without changes"
}

# Function: Sanitize folder name (replace spaces with hyphens, remove special chars)
sanitize_name() {
    local input="$1"
    # Replace spaces with hyphens
    local sanitized="${input// /-}"
    # Remove non-alphanumeric characters except hyphens and underscores
    sanitized=$(echo "$sanitized" | sed 's/[^a-zA-Z0-9_-]/-/g')
    # Convert to lowercase
    sanitized=$(echo "$sanitized" | tr '[:upper:]' '[:lower:]')
    # Trim leading/trailing hyphens
    sanitized=$(echo "$sanitized" | sed 's/^-*//;s/-*$//')
    # If empty after sanitization, default to 'unknown'
    [ -z "$sanitized" ] && sanitized="unknown"
    echo "$sanitized"
}

# Function: Check if folder is already numbered (matches ^[0-9]{2}-)
is_numbered() {
    local folder="$1"
    [[ "$folder" =~ ^[0-9]{2}- ]] && return 0 || return 1
}

# Function: Check if folder should be excluded
should_exclude() {
    local folder="$1"
    for exclude in "${EXCLUDE_LIST[@]}"; do
        if [ "$folder" = "$exclude" ]; then
            return 0
        fi
    done
    return 1
}

# Function: Get next available number (based on existing numbered folders)
get_next_number() {
    local dir="$1"
    local max_num=0
    local numbered_folders=()

    # Find all numbered folders in the current directory
    for entry in "$dir"/*; do
        if [ -d "$entry" ]; then
            basename_entry=$(basename "$entry")
            if is_numbered "$basename_entry"; then
                # Extract number part (first 2 digits)
                num_part=$(echo "$basename_entry" | sed 's/^[0-9]\{2\}-//')
                if [[ "$num_part" =~ ^[0-9]+$ ]]; then
                    numbered_folders+=("$num_part")
                fi
            fi
        fi
    done

    # Sort numbers and find max + 1
    if [ ${#numbered_folders[@]} -eq 0 ]; then
        echo "01"
    else
        IFS=$'\n' sorted=($(sort -n <<<"${numbered_folders[*]}"))
        unset IFS
        max_num=${sorted[-1]}
        next_num=$((max_num + 1))
        printf "%02d\n" "$next_num"
    fi
}

# Function: Process a single directory (rename unnumbered folders)
process_directory() {
    local dir="$1"
    local next_num=$(get_next_number "$dir")

    # Get list of folders to process
    local folders=()
    for entry in "$dir"/*; do
        if [ -d "$entry" ]; then
            local folder_name=$(basename "$entry")
            # Skip if already numbered or excluded
            if is_numbered "$folder_name" || should_exclude "$folder_name"; then
                continue
            fi
            folders+=("$entry")
        fi
    done

    # Sort alphabetically
    IFS=$'\n' sorted_folders=($(sort <<<"${folders[*]}"))
    unset IFS

    # Process each folder
    for folder in "${sorted_folders[@]}"; do
        local old_name=$(basename "$folder")
        local new_name=$(sanitize_name "$old_name")
        local new_fullname="${next_num}-${new_name}"

        # Display action
        if $DRY_RUN; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Would rename '${old_name}' -> '${new_fullname}'"
        else
            echo -e "${GREEN}[RENAME]${NC} Renaming '${old_name}' -> '${new_fullname}'"
            mv "$folder" "${dir}/${new_fullname}" || {
                echo -e "${RED}[ERROR]${NC} Failed to rename '${old_name}' to '${new_fullname}'"
                return 1
            }
        fi

        # Increment next number
        next_num=$(printf "%02d" $((next_num + 1)))
    done

    return 0
}

# Function: Main script logic
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive)
                RECURSIVE=true
                shift
                ;;
            -f|--force)
                DRY_RUN=false
                FORCE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                FORCE=false
                shift
                ;;
            -*)
                echo -e "${RED}[ERROR]${NC} Unknown option: $1"
                print_usage
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    # Validate: must run from project root (or specify path via args)
    if [ $# -eq 0 ]; then
        CURRENT_DIR="."
    else
        CURRENT_DIR="$1"
        if [ ! -d "$CURRENT_DIR" ]; then
            echo -e "${RED}[ERROR]${NC} Directory '$CURRENT_DIR' does not exist."
            exit 1
        fi
    fi

    # Start processing
    echo -e "${YELLOW}[INFO]${NC} Starting reorganization in: $CURRENT_DIR"

    if $RECURSIVE; then
        # Traverse recursively using find
        find "$CURRENT_DIR" -type d -exec bash -c '
            DIR="$1"
            if [ -d "$DIR" ]; then
                process_directory "$DIR"
            fi
        ' _ {} \;
    else
        # Process only current directory
        process_directory "$CURRENT_DIR"
    fi

    echo -e "${GREEN}[SUCCESS]${NC} Reorganization complete."
}

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi