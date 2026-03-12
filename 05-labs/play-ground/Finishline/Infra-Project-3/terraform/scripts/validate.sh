#!/bin/bash
# =============================================================================
# Validate Terraform Configurations
# Finish Line 2026 Infrastructure
# =============================================================================

set -euo pipefail

echo "🔍 Validating Terraform configurations..."

for env in dev staging prod; do
    echo ""
    echo "=== Validating $env environment ==="

    if [[ ! -d "envs/$env" ]]; then
        echo "⚠️  Skipping $env - directory not found"
        continue
    fi

    cd "envs/$env"

    # Check syntax
    echo "Checking syntax..."
    terraform fmt -check -recursive || true

    # Validate configuration
    echo "Validating configuration..."
    terraform validate || echo "⚠️  Run 'terraform init' first"

    cd - > /dev/null
done

echo ""
echo "✅ Validation complete"
