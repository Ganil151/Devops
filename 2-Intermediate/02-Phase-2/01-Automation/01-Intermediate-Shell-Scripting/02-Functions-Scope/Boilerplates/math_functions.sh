#!/bin/bash
# -----------------------------------------------------------------------------
# Name: math_functions.sh
# Description: Demonstrates two ways to return values from functions.
# -----------------------------------------------------------------------------

set -u

# Strategy 1: Command Substitution (Standard)
# Returns the result via STDOUT.
# Pros: Clean, isolated.
# Cons: Slower (forks a subshell).
add_subshell() {
    local a=$1
    local b=$2
    local result=$((a + b))
    echo "$result"
}

# Strategy 2: Global Variable Reference (High Performance)
# Returns the result by assigning to a global variable.
# Pros: Fast (no forking).
# Cons: Side effects, requires strictly managed variable names.
add_ref() {
    local a=$1
    local b=$2
    # Writing to global variable 'RESULT'
    RESULT=$((a + b))
}

echo "--- 1. Using Command Substitution ---"
SUM=$(add_subshell 10 20)
echo "10 + 20 = $SUM"

echo ""
echo "--- 2. Using Global References ---"
add_ref 30 40
# The result is now in $RESULT
echo "30 + 40 = $RESULT"

echo ""
echo "--- Performance Note ---"
echo "Strategy 1 is safer and preferred for 95% of use cases."
echo "Strategy 2 is optimized for tight loops running thousands of times."
