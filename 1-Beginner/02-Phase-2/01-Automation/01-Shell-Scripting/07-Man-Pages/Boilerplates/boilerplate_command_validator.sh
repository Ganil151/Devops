#!/bin/bash

# boilerplate_command_validator.sh - Dependency checker
# DevOps Context: Environment validation

readonly REQUIRED_TOOLS=("terraform" "ansible" "docker" "kubectl" "aws")

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "❌ $tool not found. Install: https://www.${tool}.io"
    else
        version=$($tool --version 2>&1 | head -1)
        echo "✓ $tool: $version"
    fi
done
