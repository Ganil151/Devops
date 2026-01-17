#!/bin/bash
# -----------------------------------------------------------------------------
# Name: cli_skeleton.sh
# Description: Professional CLI boilerplate handling Short AND Long options.
# -----------------------------------------------------------------------------

set -euo pipefail

# Defaults
VERBOSE=false
TARGET_ENV=""
DRY_RUN=false

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS] [COMMAND]

Options:
  -e, --env      Target environment (dev, stg, prod) [Required]
  -v, --verbose  Enable verbose logging
  -d, --dry-run  Simulate execution
  -h, --help     Show this help message

Examples:
  $(basename "${BASH_SOURCE[0]}") -e prod --dry-run
EOF
    exit 1
}

# Manual Parsing Loop (Supports Long Options)
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            TARGET_ENV="$2"
            shift 2 # Process key AND value
            ;;
        -v|--verbose)
            VERBOSE=true
            shift # Process key only
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
done

# Validation
if [[ -z "$TARGET_ENV" ]]; then
    echo "Error: --env is required."
    usage
fi

# Execution
if [[ "$VERBOSE" == "true" ]]; then
    echo "[INFO] Verbose mode enabled"
    echo "[INFO] Environment: $TARGET_ENV"
fi

if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY-RUN] Would deploy to $TARGET_ENV"
else
    echo "Deploying to $TARGET_ENV..."
fi
