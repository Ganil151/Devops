#!/bin/bash
# Validate all Terraform configurations

set -euo pipefail

echo "🔍 Validating Terraform configurations..."

for env in dev staging prod; do
    echo ""
    echo "=== Validating $env environment ==="
    cd "environments/$env" || continue
    
    terraform fmt -check -recursive || terraform fmt -recursive
    terraform init -backend=false
    terraform validate
    
    cd ../..
done

echo ""
echo "✅ All validations passed!"
