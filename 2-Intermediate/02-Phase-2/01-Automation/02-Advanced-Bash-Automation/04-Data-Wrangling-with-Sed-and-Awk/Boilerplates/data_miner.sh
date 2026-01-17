#!/bin/bash
# -----------------------------------------------------------------------------
# Name: data_miner.sh
# Description: Demonstrates Sed and Awk for log parsing.
# -----------------------------------------------------------------------------

set -euo pipefail

# Create a dummy log file
cat <<EOF > /tmp/app.log
INFO  2024-01-01 User:alice Action:login Time:150ms
ERROR 2024-01-01 User:bob Action:fail Time:50ms
INFO  2024-01-01 User:charlie Action:login Time:200ms
ERROR 2024-01-02 User:dave Action:fail Time:3000ms
EOF

echo "--- 1. Sed: Replace 'fail' with 'AUTH_FAILURE' ---"
sed 's/fail/AUTH_FAILURE/g' /tmp/app.log

echo ""
echo "--- 2. Awk: Calculate Average Time for ERRORs ---"
# We extract the number from "Time:50ms" using -F"[:ms]" or simply processing the field.
# Here we use a simpler regex approach inside awk.
grep "ERROR" /tmp/app.log | awk '{
    # "Time:50ms" is $4. We need to strip "Time:" and "ms".
    # split(input, array, separator)
    split($4, parts, ":")
    # parts[2] is "50ms". 
    # Awk converts "50ms" to 50 automatically if doing math.
    val = parts[2]
    sum += val
    count++
} END {
    if (count > 0) print "Average Error Time: ", sum/count, "ms"
    else print "No errors found."
}'

rm /tmp/app.log
