#!/bin/bash

# ============================================================
# auto_reorg.sh — Sequential Re-indexing & Sanitization
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

DRY_RUN=true
FORCE=false
RECURSIVE=false
EXCLUDE_LIST=(".git" ".terraform" "__pycache__" "node_modules")

sanitize_name() {
    local sanitized
    # Remove existing "00-" prefix if present to get the raw name
    local raw_name=$(echo "$1" | sed 's/^[0-9]\{2\}-//')
    
    sanitized="${raw_name//[ _]/-}"
    sanitized=$(echo "$sanitized" | sed 's/[^a-zA-Z0-9-]//g')
    sanitized="${sanitized,,}"
    sanitized=$(echo "$sanitized" | sed 's/-\{2,\}/-/g; s/^-*//; s/-*$//')
    
    [[ -z "$sanitized" ]] && echo "unnamed" || echo "$sanitized"
}

should_exclude() {
    local folder="$1"
    for exclude in "${EXCLUDE_LIST[@]}"; do
        [[ "$folder" == "$exclude" ]] && return 0
    done
    return 1
}

process_directory() {
    local target_dir="$1"
    echo -e "${BLUE}[PROCESSING]${NC} $target_dir"

    # 1. Get all directories, sort them alphabetically (ignoring old numbers)
    # We use a temp array to store the original names
    local folders=()
    for entry in "$target_dir"/*; do
        if [[ -d "$entry" ]]; then
            local base=$(basename "$entry")
            if ! should_exclude "$base"; then
                folders+=("$base")
            fi
        fi
    done

    # Sort folders alphabetically based on their sanitized/raw names
    IFS=$'\n' sorted_folders=($(sort <<<"${folders[*]}"))
    unset IFS

    # 2. Re-index from 00
    local count=0
    for old_name in "${sorted_folders[@]}"; do
        local prefix=$(printf "%02d" $count)
        local clean_name=$(sanitize_name "$old_name")
        local new_name="${prefix}-${clean_name}"
        
        # Only rename if the name actually needs to change
        if [[ "$old_name" != "$new_name" ]]; then
            if $DRY_RUN; then
                echo -e "  ${YELLOW}[DRY-RUN]${NC} '$old_name' -> '$new_name'"
            else
                if mv "$target_dir/$old_name" "$target_dir/$new_name" 2>/dev/null; then
                    echo -e "  ${GREEN}[FIXED]${NC} '$old_name' -> '$new_name'"
                else
                    echo -e "  ${RED}[ERROR]${NC} Failed: '$old_name'"
                fi
            fi
        else
            echo -e "  ${NC}[STABLE]${NC} '$old_name' (already correct)"
        fi
        
        ((count++))
    done

    # 3. Recursive Logic
    if $RECURSIVE; then
        for entry in "$target_dir"/*; do
            if [[ -d "$entry" ]]; then
                process_directory "$entry"
            fi
        done
    fi
}

main() {
    local target_dir=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive) RECURSIVE=true; shift ;;
            -f|--force)     DRY_RUN=false; FORCE=true; shift ;;
            --dry-run)      DRY_RUN=true; shift ;;
            *)              target_dir="$1"; shift ;;
        esac
    done

    target_dir="${target_dir:-.}"

    if [[ "$FORCE" == "true" ]]; then
        echo -e "${RED}FORCE MODE ENABLED.${NC} This will re-index ALL folders to 00, 01, 02..."
        read -p "Continue? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    fi

    process_directory "$target_dir"
}

main "$@"