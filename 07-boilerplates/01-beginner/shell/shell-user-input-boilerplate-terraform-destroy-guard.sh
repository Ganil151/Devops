#!/bin/bash

# boilerplate_terraform_destroy_guard.sh - Prevent accidental deletions

set -euo pipefail

readonly ENVIRONMENT="${1:?Error: Environment name required}"

echo "⚠️  WARNING: You are about to DESTROY infrastructure in: $ENVIRONMENT"
echo ""
read -p "Type the environment name to confirm: " confirmation

if [ "$confirmation" != "$ENVIRONMENT" ]; then
    echo "❌ Confirmation failed. Aborting."
    exit 1
fi

echo "✓ Confirmation received. Proceeding with terraform destroy..."
terraform destroy -auto-approve
