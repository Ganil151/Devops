#!/bin/bash

# boilerplate_resource_validator.sh - Pre-deployment resource check

set -euo pipefail

readonly MIN_MEMORY_GB=4
readonly MIN_DISK_GB=10

# Check memory
available_mem=$(free -g | awk '/^Mem:/{print $7}')
if [ "$available_mem" -lt "$MIN_MEMORY_GB" ]; then
    echo "❌ Insufficient memory: ${available_mem}GB (minimum: ${MIN_MEMORY_GB}GB)"
    exit 1
fi

# Check disk
available_disk=$(df -BG / | tail -1 | awk '{print int($4)}')
if [ "$available_disk" -lt "$MIN_DISK_GB" ]; then
    echo "❌ Insufficient disk: ${available_disk}GB (minimum: ${MIN_DISK_GB}GB)"
    exit 1
fi

echo "✓ Resources validated. Proceeding with deployment..."
