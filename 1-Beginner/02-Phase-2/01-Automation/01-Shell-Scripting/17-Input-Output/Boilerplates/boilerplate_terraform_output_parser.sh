#!/bin/bash

# boilerplate_terraform_output_parser.sh - Extract outputs from Terraform

set -euo pipefail

readonly OUTPUT_JSON=$(terraform output -json)

# Parse specific values
ALB_DNS=$(echo "$OUTPUT_JSON" | jq -r '.alb_dns_name.value')
DB_ENDPOINT=$(echo "$OUTPUT_JSON" | jq -r '.database_endpoint.value')

# Export for other scripts
cat > terraform_outputs.env <<EOF
export ALB_DNS="$ALB_DNS"
export DB_ENDPOINT="$DB_ENDPOINT"
EOF

echo "✓ Terraform outputs parsed and saved to terraform_outputs.env"
echo "  ALB DNS: $ALB_DNS"
echo "  DB Endpoint: $DB_ENDPOINT"
