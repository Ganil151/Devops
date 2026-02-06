#!/bin/bash
# 🛠️ Infrastructure Consistency Validator
# Ensures Terraform workspaces and backends are correctly initialized

set -e

ENVIRONMENTS=("dev" "prod")

echo "🏁 Starting Infrastructure Validation..."

for env in "${ENVIRONMENTS[@]}"; do
    echo "--- Checking Environment: $env ---"
    cd "/home/gsmash/Documents/Devops/04-Projects-Showcase/06-Spring-Petclinic-MicroServices/terraform/environments/$env"
    
    if [ ! -f "backend.conf" ]; then
        echo "❌ [Missing backend.conf]"
        ERROR=1
    else
        echo "✅ [backend.conf found]"
    fi

    if [ ! -f "$env.tfvars" ]; then
        echo "❌ [Missing $env.tfvars]"
        ERROR=1
    else
        echo "✅ [$env.tfvars found]"
    fi
done

if [ "$ERROR" == "1" ]; then
    exit 1
else
    echo "🎉 Infrastructure structure is valid!"
fi
