#!/bin/bash

# boilerplate_tool_version_checker.sh

readonly TOOLS=("terraform:1.0" "ansible:2.9" "docker:20.10" "kubectl:1.20")

for entry in "${TOOLS[@]}"; do
    tool="${entry%%:*}"
    min_version="${entry##*:}"
    
    if command -v $tool &> /dev/null; then
        current=$($tool --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        echo "✓ $tool: $current (minimum: $min_version)"
    else
        echo "❌ $tool not installed"
    fi
done
