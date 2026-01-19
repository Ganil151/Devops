#!/bin/bash
# -----------------------------------------------------------------------------
# Name: safe_cleanup.sh
# Description: Demonstrates multiple safety layers for destructive actions.
# -----------------------------------------------------------------------------

set -euo pipefail

LOCKFILE="/tmp/myapp_cleanup.lock"
TARGET_DIR="${1:-}" # Take dir from arg, or empty

# 1. LOCKING: Prevent concurrent runs
exec 200>"$LOCKFILE"
if ! flock -n 200; then
    echo "ERROR: Another cleanup process is running. Exiting."
    exit 1
fi

# 2. VARIABLE CHECK: Fail if directory is empty/unset
: "${TARGET_DIR:?Directory path must be provided as an argument.}"

# 3. DIRECTORY VALIDATION: Ensure it's not a system critical path
if [[ "$TARGET_DIR" == "/" ]] || [[ "$TARGET_DIR" == "/etc" ]]; then
    echo "FATAL: Attempting to delete root or etc! Aborting."
    exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "ERROR: $TARGET_DIR is not a directory."
    exit 1
fi

# 4. ACTION (Self-Protecting)
echo "LOG: Safely removing contents of $TARGET_DIR..."
# rm -rf "${TARGET_DIR:?}"/* # UNCOMMENT WITH EXTREME CAUTION
echo "SUCCESS: Cleanup finished."
