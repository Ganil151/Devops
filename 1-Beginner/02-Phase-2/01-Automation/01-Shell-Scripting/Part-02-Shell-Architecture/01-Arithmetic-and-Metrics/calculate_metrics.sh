#!/bin/bash
# ==============================================================================
# Script Name: calculate_metrics.sh
# Author:      Ganil
# Description: Calculates system metrics using 'bc' for floating-point precision.
#              Demonstrates metric collection and conditional threshold checks.
# ==============================================================================

# Thresholds
DISK_THRESHOLD=80.0
MEM_THRESHOLD=20.0

echo "📊 System Health Check"
echo "----------------------"

# 1. Disk Usage Calculation
# Get usage of root partition, strip percentage sign
DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//')
# Ensure it's treated as a float for bc comparison? Actually df returns integer, but we can treat it as float contextually.
# Let's make it look float-y or just use integers for df, but the prompt asked for bc usage.
# We can simulate a calculation requiring bc.
# Let's say we want exact precision if available, or just use bc for comparison against a float threshold.

echo "💾 Disk Usage: $DISK_USAGE%"

# Check if Disk Usage > Threshold using bc
# bc returns 1 if true, 0 if false
IS_DISK_HIGH=$(echo "$DISK_USAGE > $DISK_THRESHOLD" | bc)

if [ "$IS_DISK_HIGH" -eq 1 ]; then
    echo "   ⚠️  WARNING: Disk usage is above $DISK_THRESHOLD%!"
else
    echo "   ✅ Disk usage is within limits."
fi

echo ""

# 2. Memory Free Percentage Calculation
# We need total and available memory. 'free' command usually gives kb.
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows/Git Bash environment workaround - mocking values if commands calculate differently
    # But let's try to use valid commands if possible. Windows usually has wmic or pure variables?
    # Since this is a curriculum script, we stick to standard Linux 'free' command logic because it's for learning.
    # We will assume a Linux environment or a mockery for demonstration if 'free' fails.
    
    # Mocking for demonstration if 'free' is not available (common in Git Bash on Windows without heavy tools)
    # Ideally, we'd use 'systeminfo' on Windows, but stick to standard bash syntax for the lesson.
    # Let's assume standard 'free' output structure or mock it for safety in this specific Windows user env.
    
    # Check if `free` exists
    if command -v free &> /dev/null; then
        TOTAL_MEM=$(free | grep Mem: | awk '{print $2}')
        USED_MEM=$(free | grep Mem: | awk '{print $3}')
    else
        # Fallback values for demonstration purposes on Windows Git Bash
        echo "   (Simulation Mode: 'free' command not found)"
        TOTAL_MEM=16384
        USED_MEM=12500
    fi
else
    TOTAL_MEM=$(free | grep Mem: | awk '{print $2}')
    USED_MEM=$(free | grep Mem: | awk '{print $3}')
fi

# Calculate Free Memory % using bc (Floating Point Math)
# Formula: (Total - Used) / Total * 100
# scale=2 sets decimal precision
FREE_MEM_PCT=$(echo "scale=2; ($TOTAL_MEM - $USED_MEM) / $TOTAL_MEM * 100" | bc)

echo "🧠 Free Memory: $FREE_MEM_PCT%"

# Check if Free Memory < Threshold using bc
IS_MEM_LOW=$(echo "$FREE_MEM_PCT < $MEM_THRESHOLD" | bc)

if [ "$IS_MEM_LOW" -eq 1 ]; then
    echo "   ⚠️  WARNING: Free memory is dangerously low (< $MEM_THRESHOLD%)!"
else
    echo "   ✅ Memory levels are healthy."
fi

echo "----------------------"
echo "✅ Metrics Check Complete."
