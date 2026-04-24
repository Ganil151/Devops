#!/usr/bin/env bash
# Topic: Signal Handling and Traps
# Description: Demonstrates guaranteed cleanup using the EXIT and INT signals.

set -euo pipefail

TEMP_WORK_DIR="/tmp/automation_$(date +%s)"
LOCK_FILE="/tmp/migration.lock"

# 1. Define Cleanup Function
cleanup() {
    local exit_code=$?
    echo "🧹 Cleanup triggered. Process exiting with code: $exit_code"
    
    # Remove temp files
    if [[ -d "$TEMP_WORK_DIR" ]]; then
        echo "  - Removing temp directory: $TEMP_WORK_DIR"
        rm -rf "$TEMP_WORK_DIR"
    fi

    # Remove lock file
    if [[ -f "$LOCK_FILE" ]]; then
        echo "  - Releasing lock: $LOCK_FILE"
        rm -f "$LOCK_FILE"
    fi
}

# 2. Register Traps
# EXIT: Always runs when the shell exits
# INT: Runs on Ctrl+C
# TERM: Runs on kill command
trap cleanup EXIT INT TERM

# 3. Execution Logic
echo "🔒 Creating lock file..."
touch "$LOCK_FILE"

echo "📂 Initializing work directory..."
mkdir -p "$TEMP_WORK_DIR"

echo "⚙️ Processing data (Simulating long-running task)..."
echo "Try pressing Ctrl+C while this runs."

# Simulate work
for i in {1..5}; do
    echo "  - Step $i/5 complete..."
    sleep 2
done

echo "✅ Task finished successfully."
# cleanup() will run automatically due to 'EXIT' trap
