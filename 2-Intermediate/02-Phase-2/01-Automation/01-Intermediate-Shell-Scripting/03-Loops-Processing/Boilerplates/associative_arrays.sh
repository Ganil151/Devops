#!/bin/bash
# -----------------------------------------------------------------------------
# Name: associative_arrays.sh
# Description: Demonstrates Bash 4.0+ Associative Arrays (Key-Value pairs).
# -----------------------------------------------------------------------------

# Quick Version check
if ((BASH_VERSINFO[0] < 4)); then
    echo "Error: This script requires Bash 4.0+"
    exit 1
fi

# 1. Declare
declare -A USER_ROLES

# 2. Populate
USER_ROLES["alice"]="admin"
USER_ROLES["bob"]="deployer"
USER_ROLES["charlie"]="viewer"

echo "Evaluating User Roles..."

# 3. Iterate Keys
for user in "${!USER_ROLES[@]}"; do
    role="${USER_ROLES[$user]}"
    echo "User: $user | Role: $role"
    
    # Logic based on value
    if [[ "$role" == "admin" ]]; then
        echo "  -> Giving SUDO Access to $user"
    fi
done

# 4. Check existence
target="dave"
if [[ -v USER_ROLES[$target] ]]; then
    echo "Found $target"
else
    echo "User $target not found in map."
fi
