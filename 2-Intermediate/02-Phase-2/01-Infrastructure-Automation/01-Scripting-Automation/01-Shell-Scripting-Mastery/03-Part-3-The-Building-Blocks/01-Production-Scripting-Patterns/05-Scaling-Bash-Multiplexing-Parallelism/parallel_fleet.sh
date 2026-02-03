#!/usr/bin/env bash
# Topic: Scaling Bash - Multiplexing & Parallelism
# File: 05-Scaling-Bash-Multiplexing-Parallelism/parallel_fleet.sh

set -euo pipefail

# 1. Mock List of Servers
SERVERS=("web-01" "web-02" "web-03" "db-01" "db-02" "cache-01")

echo "⚡ Starting Parallel Fleet Health Check..."

# 2. Worker Function
check_health() {
    local node=$1
    # Randomly simulate some delay/work
    local delay=$(( (RANDOM % 3) + 1 ))
    sleep "$delay"
    
    if [[ $(( RANDOM % 5 )) -eq 0 ]]; then
        echo "❌ [$(date +%H:%M:%S)] $node: FAILED (Delay: ${delay}s)" >&2
        return 1
    else
        echo "✅ [$(date +%H:%M:%S)] $node: HEALTHY (Delay: ${delay}s)"
        return 0
    fi
}

# Export function for xargs to see it
export -f check_health

# 3. Parallel Execution using xargs
# -P 4: Run up to 4 processes concurrently
# -n 1: Pass 1 argument to the command
echo "--- Executing checks (4 concurrent threads) ---"
printf "%s\n" "${SERVERS[@]}" | xargs -I {} -P 4 bash -c 'check_health "$@"' _ {}

echo -e "\n✅ Parallel Sweep Complete."
