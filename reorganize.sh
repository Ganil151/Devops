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

usage() {
    echo "Usage: $0 [OPTIONS] [TARGET_DIR]"
    echo "Options:"
    echo "  -r, --recursive    Recursively process sub-directories"
    echo "  -f, --force        Execute changes (disable Dry Run)"
    echo "  --dry-run          Show what would happen (Default)"
    echo "  -h, --help         Show this help message"
}

sanitize_name() {
    local sanitized
    # Remove existing "00-" prefix if present to get the raw name
    local raw_name=$(echo "$1" | sed 's/^[0-9]\{2\}-//')
    
    sanitized="${raw_name//[ _]/-}"
    local name="$1"
    # Replace spaces and underscores with hyphens
    local sanitized="${name//[ _]/-}"
    # Remove non-alphanumeric characters except hyphens
    sanitized=$(echo "$sanitized" | sed 's/[^a-zA-Z0-9-]//g')
    # Convert to lowercase
    sanitized="${sanitized,,}"
    # Remove duplicate hyphens and leading/trailing hyphens
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
    # Check if directory exists
    if [[ ! -d "$target_dir" ]]; then
        echo -e "${RED}[ERROR]${NC} Directory not found: $target_dir"
        return
    fi

    echo -e "${BLUE}[PROCESSING]${NC} $target_dir"

    # 1. Get all directories, sort them alphabetically (ignoring old numbers)
    # We use a temp array to store the original names
    local folders=()
    local max_index=0
    local unnumbered_dirs=()

    # 1. Analyze current directory
    # Enable nullglob to handle empty directories gracefully
    shopt -s nullglob
    for entry in "$target_dir"/*; do
        if [[ -d "$entry" ]]; then
            local base=$(basename "$entry")
            
            if ! should_exclude "$base"; then
                folders+=("$base")
                # Check if already numbered (01-name)
                if [[ "$base" =~ ^[0-9]{2}- ]]; then
                    # Extract the number part
                    local num_part="${base%%-*}"
                    # Convert to integer (base 10 to handle 08, 09)
                    local num=$((10#$num_part))
                    
                    if (( num > max_index )); then
                        max_index=$num
                    fi
                    if $DRY_RUN; then
                         echo -e "  ${NC}[SKIP]${NC} '$base' (Already numbered)"
                    fi
                else
                    unnumbered_dirs+=("$base")
                fi
            fi
        fi
    done
    shopt -u nullglob

    # Sort folders alphabetically based on their sanitized/raw names
    IFS=$'\n' sorted_folders=($(sort <<<"${folders[*]}"))
    unset IFS
    # 2. Sort unnumbered folders alphabetically
    if [[ ${#unnumbered_dirs[@]} -gt 0 ]]; then
        IFS=$'\n' sorted_folders=($(sort <<<"${unnumbered_dirs[*]}"))
        unset IFS

    # 2. Re-index from 00
    local count=0
    for old_name in "${sorted_folders[@]}"; do
        local prefix=$(printf "%02d" $count)
        local clean_name=$(sanitize_name "$old_name")
        local new_name="${prefix}-${clean_name}"
        # 3. Rename unnumbered folders
        local current_index=$((max_index + 1))
        
        # Only rename if the name actually needs to change
        if [[ "$old_name" != "$new_name" ]]; then
            if $DRY_RUN; then
                echo -e "  ${YELLOW}[DRY-RUN]${NC} '$old_name' -> '$new_name'"
            else
                if mv "$target_dir/$old_name" "$target_dir/$new_name" 2>/dev/null; then
                    echo -e "  ${GREEN}[FIXED]${NC} '$old_name' -> '$new_name'"
        for old_name in "${sorted_folders[@]}"; do
            local clean_name=$(sanitize_name "$old_name")
            local prefix=$(printf "%02d" $current_index)
            local new_name="${prefix}-${clean_name}"
            
            if [[ "$old_name" != "$new_name" ]]; then
                if $DRY_RUN; then
                    echo -e "  ${YELLOW}[DRY-RUN]${NC} '$old_name' -> '$new_name'"
                else
                    echo -e "  ${RED}[ERROR]${NC} Failed: '$old_name'"
                    # Check for collision
                    if [[ -e "$target_dir/$new_name" ]]; then
                         echo -e "  ${RED}[CONFLICT]${NC} Cannot rename '$old_name' to '$new_name' (Target exists)"
                    else
                        if mv "$target_dir/$old_name" "$target_dir/$new_name"; then
                            echo -e "  ${GREEN}[RENAMED]${NC} '$old_name' -> '$new_name'"
                        else
                            echo -e "  ${RED}[ERROR]${NC} Failed to rename '$old_name'"
                        fi
                    fi
                fi
            fi
        else
            echo -e "  ${NC}[STABLE]${NC} '$old_name' (already correct)"
        fi
        
        ((count++))
    done
            ((current_index++))
        done
    fi

    # 3. Recursive Logic
    if $RECURSIVE; then
        shopt -s nullglob
        for entry in "$target_dir"/*; do
            if [[ -d "$entry" ]]; then
                process_directory "$entry"
                local base=$(basename "$entry")
                if ! should_exclude "$base"; then
                    process_directory "$entry"
                fi
            fi
        done
        shopt -u nullglob
    fi
}

main() {
    local target_dir=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive) RECURSIVE=true; shift ;;
            -f|--force)     DRY_RUN=false; FORCE=true; shift ;;
            -f|--force)     DRY_RUN=false; shift ;;
            --dry-run)      DRY_RUN=true; shift ;;
            -h|--help)      usage; exit 0 ;;
            *)              target_dir="$1"; shift ;;
        esac
    done

    target_dir="${target_dir:-.}"
    
    # Remove trailing slash if present
    target_dir="${target_dir%/}"

    if [[ "$FORCE" == "true" ]]; then
        echo -e "${RED}FORCE MODE ENABLED.${NC} This will re-index ALL folders to 00, 01, 02..."
        read -p "Continue? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    if $DRY_RUN; then
        echo -e "${YELLOW}*** DRY RUN MODE ***${NC} (Use -f or --force to execute)"
    fi

    process_directory "$target_dir"
}

main "$@"