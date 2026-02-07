#!/bin/bash

# ============================================================
# auto_reorg.sh — Robust Recursive Folder Numbering
# ============================================================

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

# Default values
DRY_RUN=true
FORCE=false
RECURSIVE=false
EXCLUDE_LIST=(".git" ".terraform" "__pycache__" "node_modules" "." "..")

print_usage() {
    echo -e "${YELLOW}Usage:${NC} $0 [options] [directory]"
    echo -e "\nOptions:"
    echo -e "  -r, --recursive     Apply renaming recursively to subdirectories"
    echo -e "  -f, --force         Execute actual renames (bypass dry-run)"
    echo -e "  --dry-run           Show what would be renamed (default)"
    echo -e "  -h, --help          Show this help message"
}

sanitize_name() {
    local sanitized
    # 1. Replace spaces/underscores with hyphens
    sanitized="${1//[ _]/-}"
    # 2. Remove non-alphanumeric (except hyphens)
    sanitized=$(echo "$sanitized" | sed 's/[^a-zA-Z0-9-]//g')
    # 3. Convert to lowercase
    sanitized="${sanitized,,}"
    # 4. Collapse multiple hyphens and trim
    sanitized=$(echo "$sanitized" | sed 's/-\{2,\}/-/g; s/^-*//; s/-*$//')
    
    # FIXED: Corrected the spacing in the conditional check
    [[ -z "$sanitized" ]] && echo "unnamed-folder" || echo "$sanitized"
}

is_numbered() {
    # Matches exactly two digits followed by a hyphen at the start
    [[ "$1" =~ ^[0-9]{2}- ]]
}

should_exclude() {
    local folder="$1"
    for exclude in "${EXCLUDE_LIST[@]}"; do
        [[ "$folder" == "$exclude" ]] && return 0
    done
    return 1
}

get_next_number() {
    local dir="$1"
    local max_num=0
    
    # Loop through directories to find the highest prefix
    for entry in "$dir"/*; do
        local base=$(basename "$entry")
        if [[ -d "$entry" ]] && is_numbered "$base"; then
            local num_prefix="${base%%-*}"
            # 10# force base-10 to avoid octal errors with 08, 09
            local num=$((10#$num_prefix)) 
            (( num > max_num )) && max_num=$num
        fi
    done

    printf "%02d" $((max_num + 1))
}

process_directory() {
    local target_dir="$1"
    echo -e "${BLUE}[SCANNING]${NC} $target_dir"

    local next_num
    next_num=$(get_next_number "$target_dir")

    # Process directories in the current level
    for folder in "$target_dir"/*; do
        # Ensure it is a directory and not a file
        [[ ! -d "$folder" ]] && continue
        
        local old_name
        old_name=$(basename "$folder")

        # Skip if already numbered or in exclusion list
        if should_exclude "$old_name" || is_numbered "$old_name"; then
            continue
        fi

        local sanitized_base
        sanitized_base=$(sanitize_name "$old_name")
        local new_name="${next_num}-${sanitized_base}"
        local destination="${target_dir}/${new_name}"

        if $DRY_RUN; then
            echo -e "  ${YELLOW}[DRY-RUN]${NC} '$old_name' -> '$new_name'"
        else
            if mv "$folder" "$destination" 2>/dev/null; then
                echo -e "  ${GREEN}[RENAMED]${NC} '$old_name' -> '$new_name'"
            else
                echo -e "  ${RED}[ERROR]${NC} Failed to rename '$old_name'"
            fi
        fi

        # Increment with leading zero
        next_num=$(printf "%02d" $((10#$next_num + 1)))
    done

    # Recursion Logic
    if $RECURSIVE; then
        for subdir in "$target_dir"/*; do
            if [[ -d "$subdir" ]]; then
                local base_sub=$(basename "$subdir")
                if ! should_exclude "$base_sub"; then
                    process_directory "$subdir"
                fi
            fi
        done
    fi
}

main() {
    # Argument Parsing
    local target_dir=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive) RECURSIVE=true; shift ;;
            -f|--force)     DRY_RUN=false; FORCE=true; shift ;;
            --dry-run)      DRY_RUN=true; shift ;;
            -h|--help)      print_usage; exit 0 ;;
            -*)             echo -e "${RED}Error: Unknown option $1${NC}"; print_usage; exit 1 ;;
            *)              target_dir="$1"; shift ;;
        esac
    done

    # Default to current directory if none provided
    target_dir="${target_dir:-.}"

    if [[ ! -d "$target_dir" ]]; then
        echo -e "${RED}[ERROR]${NC} '$target_dir' is not a valid directory."
        exit 1
    fi

    # Confirmation for destructive actions
    if [[ "$FORCE" == "true" ]]; then
        echo -e "${RED}WARNING:${NC} Reorganizing folders in: $(realpath "$target_dir")"
        read -p "Proceed with renames? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && echo "Aborted." && exit 0
    fi

    process_