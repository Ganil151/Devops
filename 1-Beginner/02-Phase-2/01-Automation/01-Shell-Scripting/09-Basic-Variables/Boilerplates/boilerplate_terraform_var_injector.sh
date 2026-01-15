#!/bin/bash

# boilerplate_terraform_var_injector.sh - CI/CD variable injection

set -euo pipefail

readonly TFVARS_FILE="${1:-.tfvars}"

[ ! -f "$TFVARS_FILE" ] && echo "Error:.tfvars file not found" && exit 1

while IFS='=' read -r key value; do
    [ -z "$key" ] && continue
    [[ "$key" =~ ^# ]] && continue
    
    clean_value=$(echo "$value" | tr -d '"' | xargs)
    export "TF_VAR_${key}=${clean_value}"
    
    echo "✓ Exported: TF_VAR_${key}"
done < "$TFVARS_FILE"

echo "Terraform variables loaded!"
