#!/bin/bash

# boilerplate_environment_selector.sh - Interactive deployment prompts

set -euo pipefail

echo "Select deployment environment:"
echo "  1) Development"
echo "  2) Staging"
echo "  3) Production"
read -p "Enter choice [1-3]: " choice

case $choice in
    1) ENV="development" ;;
    2) ENV="staging" ;;
    3) ENV="production" ;;
    *) echo "Invalid choice" && exit 1 ;;
esac

echo "✓ Selected environment: $ENV"
export DEPLOY_ENV="$ENV"

# Proceed with deployment
echo "Deploying to $ENV..."
