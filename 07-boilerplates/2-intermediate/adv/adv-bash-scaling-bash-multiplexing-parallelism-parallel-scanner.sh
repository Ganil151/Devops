#!/bin/bash
# -----------------------------------------------------------------------------
# Name: parallel_scanner.sh
# Description: Demonstrates xargs parallelism vs sequential loops.
# -----------------------------------------------------------------------------

set -u

# Generate dummy hosts
echo "[INFO] Generating hosts list..."
seq 1 10 | sed 's/^/host-/' > /tmp/hosts.txt

task() {
    local host=$1
    # Simulate I/O latency
    sleep 1
    echo "Checked $host"
}
export -f task

echo "--- 1. Sequential Scan (Slow) ---"
START=$SECONDS
while read -r host; do
    # Run in foreground
    task "$host"
done < /tmp/hosts.txt
DURATION=$((SECONDS - START))
echo "Sequential took: ${DURATION}s"

echo ""
echo "--- 2. Parallel Scan (Fast) ---"
START=$SECONDS
# -P 5: Run 5 at a time
# -I {}: Replace {} with the input line
# bash -c: Run the command (since 'task' is a function, we need to export it and call bash)
cat /tmp/hosts.txt | xargs -P 5 -I {} bash -c 'task "{}"'
DURATION=$((SECONDS - START))
echo "Parallel took: ${DURATION}s"
