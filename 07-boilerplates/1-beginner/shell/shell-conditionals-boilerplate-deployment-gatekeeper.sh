#!/bin/bash

# boilerplate_deployment_gatekeeper.sh - Pre-flight validation

set -euo pipefail

echo "Running pre-flight checks..."

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

# Check Terraform version
if ! terraform version &> /dev/null; then
    echo "❌ Terraform not installed"
    exit 1
fi

# Check state lock
if terraform state list &> /dev/null; then
    echo "✓ Terraform state accessible"
else
    echo "❌ Cannot access Terraform state"
    exit 1
fi

echo "✓ All pre-flight checks passed. Ready for deployment!"
