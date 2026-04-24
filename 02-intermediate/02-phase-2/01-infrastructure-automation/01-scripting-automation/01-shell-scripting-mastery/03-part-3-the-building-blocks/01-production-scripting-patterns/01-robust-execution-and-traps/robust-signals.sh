#!/usr/bin/env bash
# Topic: Robust Execution & Signal Management
# File: 01-Robust-Execution-and-Traps/robust_signals.sh

set -euo pipefail

# 1. Boilerplate: Fail-fast and Lockfiles
LOCKFILE="/tmp/$(basename "$0").lock"

cleanup() {
    echo "🧹 Script interrupted or finished. Cleaning up..."
    rm -f "$LOCKFILE"
    # Kill any background child processes
    kill $(jobs -p) 2>/dev/null || true
}

# 2. Trap signals
trap cleanup EXIT INT TERM

# 3. Recursive lock (Idempotency)
if [[ -e "$LOCKFILE" ]]; then
    echo "❌ Error: Script is already running (Lockfile exists)."
    exit 1
fi
touch "$LOCKFILE"

# 4. Atomic logic example: Securely create a temp file
TEMP_DATA=$(mktemp /tmp/data.XXXXXX)
echo "🚀 Processing critical system data in $TEMP_DATA..."

# Simulating high-stakes work
for i in {1..3}; do
    echo "  - Transaction $i/3 in progress..."
    sleep 2
done

echo "✅ All data persisted safely."
