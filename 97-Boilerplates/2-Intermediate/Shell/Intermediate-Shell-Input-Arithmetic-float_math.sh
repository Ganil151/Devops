#!/bin/bash
# -----------------------------------------------------------------------------
# Name: float_math.sh
# Description: Demonstrates floating point math using `bc`.
# -----------------------------------------------------------------------------

set -u

calculate_percentage() {
    local part=$1
    local total=$2
    
    # "scale=2" gives us two decimal places.
    # We multiply by 100 for percentage.
    echo "scale=2; ($part / $total) * 100" | bc
}

check_cpu_usage() {
    local current_load=$1
    local threshold=$2
    
    # bc returns 1 if true, 0 if false
    if (( $(echo "$current_load > $threshold" | bc -l) )); then
        echo "🚨 ALERT: CPU Load $current_load exceeds $threshold"
    else
        echo "✅ CPU Load $current_load is normal."
    fi
}

# --- Main ---
echo "Calculating 45 out of 120..."
PERC=$(calculate_percentage 45 120)
echo "Result: $PERC%"

echo ""
echo "Checking Thresholds..."
check_cpu_usage 0.85 0.70
check_cpu_usage 0.20 0.70
