#!/bin/bash

# ============================================================
# auto_reorg.sh — Robust Recursive Folder Numbering & Sanitization Script
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
SCRIPT_NAME=$(basename "$0")

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
    
    [[ -z "$sanitized" ] ] && echo "unnamed-folder" || echo "$sanitized"
}

is_numbered() {
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
    
    # Efficiently find the highest prefix number
    for entry in "$dir"/*; do
        local base=$(basename "$entry")
        if [[ -d "$entry" ]] && is_numbered "$base"; then
            local num=${base%%-*} # Extract everything before the first hyphen
            # Remove leading zero for calculation
            num=$((10#$num)) 
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

    # Use a null-terminated glob to handle weird filenames safely
    for folder in "$target_dir"/*; do
        [[ ! -d "$folder" ]] && continue
        
        local old_name
        old_name=$(basename "$folder")

        # Skip logic
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

        # Increment
        next_num=$(printf "%02d" $((10#$next_num + 1)))
    done

    # Recursive call if flag is set
    if $RECURSIVE; then
        for subdir in "$target_dir"/*; do
            if [[ -d "$subdir" ]] && ! should_exclude "$(basename "$subdir")"; then
                process_directory "$subdir"
            fi
        done
    fi
}

main() {
    # Parse Arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive) RECURSIVE=true; shift ;;
            -f|--force)     DRY_RUN=false; FORCE=true; shift ;;
            --dry-run)      DRY_RUN=true; shift ;;
            -h|--help)      print_usage; exit 0 ;;
            -*)             echo -e "${RED}Error: Unknown option $1${NC}"; print_usage; exit 1 ;;
            *)              TARGET_DIR="$1"; shift ;;
        esac
    done

    TARGET_DIR="${TARGET_DIR:-.}"

    if [[ ! -d "$TARGET_DIR" ]]; then
        echo -e "${RED}[ERROR]${NC} '$TARGET_DIR' is not a valid directory."
        exit 1
    fi

    if [[ "$FORCE" == "true" ]]; then
        echo -e "${RED}WARNING:${NC} About to rename folders in '$TARGET_DIR'."
        read -p "Proceed? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && echo "Aborted." && exit 0
    fi

    process_directory "$TARGET_DIR"
    echo -e "\n${GREEN}Operation Complete.${NC}"
}

main "$@"