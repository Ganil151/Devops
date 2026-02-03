#!/usr/bin/env bash
# Topic: Intermediate Logic & Associative Arrays
# Description: Demonstrates managing multi-environment configurations using Key-Value pairs.

set -euo pipefail

# 1. Declare an Associative Array (Requires Bash 4.0+)
declare -A ENV_CONFIGS=(
    ["prod"]="us-east-1"
    ["staging"]="us-west-2"
    ["dev"]="eu-central-1"
)

# 2. Logic: Loop through keys and values
echo "🌐 Loading Infrastructure Map..."
for env in "${!ENV_CONFIGS[@]}"; do
    region="${ENV_CONFIGS[$env]}"
    echo "  - Environment: $env | Target Region: $region"
done

# 3. Regex Matching Logic
# Use [[ ]] with =~ operator for advanced validation
validate_resource_name() {
    local name=$1
    local pattern="^[a-z]{3}-[0-9]{2}-[a-z]+$" # e.g., web-01-nginx

    if [[ "$name" =~ $pattern ]]; then
        echo "✅ Resource name '$name' is valid."
    else
        echo "❌ Error: '$name' does not match naming convention (app-xx-service)."
        return 1
    fi
}

validate_resource_name "web-01-nginx"
validate_resource_name "INVALID_NAME" || true # Prevent script exit for demo
