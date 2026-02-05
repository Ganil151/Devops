#!/bin/bash

# boilerplate_infrastructure_reporter.sh - Compliance reporting

set -euo pipefail

readonly REPORT_FILE="infrastructure_report_$(date +%Y%m%d).md"

{
    echo "# Infrastructure Report"
    echo "Generated: $(date)"
    echo ""
    
    echo "## AWS Resources"
    aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType]' --output table
    echo ""
    
    echo "## Terraform Resources"
    terraform show -json | jq '.values.root_module.resources[] | {type, name}' | head -20
    echo ""
    
    echo "## Docker Containers"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
} > "$REPORT_FILE"

echo "✓ Report saved: $REPORT_FILE"
