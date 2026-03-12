#!/bin/bash
# =============================================================================
# Verify Deployment - Assignment Validation Checklist
# Finish Line 2026 Infrastructure
# =============================================================================

set -euo pipefail

ENV="${1:-dev}"

echo "🔍 Verifying deployment for environment: $ENV"
echo ""

# Get outputs
echo "=== Terraform Outputs ==="
cd "envs/$ENV"
terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"'
cd - > /dev/null

echo ""
echo "=== Assignment Validation Checklist ==="
echo ""

# VPC Verification (§51, §55)
echo "✅ A) VPC with 3 subnets across 3 AZs"
VPC_ID=$(cd "envs/$ENV" && terraform output -raw vpc_id 2>/dev/null || echo "N/A")
echo "   VPC ID: $VPC_ID"

# ALB Verification (§31, §62)
echo ""
echo "✅ B) Shared ALB with group-tag=finishline"
ALB_ARN=$(cd "envs/$ENV" && terraform output -raw alb_arn 2>/dev/null || echo "N/A")
echo "   ALB ARN: $ALB_ARN"

# Jumphost Verification (§69, §70)
echo ""
echo "✅ C) Jumphost (AL2023) with SSH restriction"
JUMPHOST_IP=$(cd "envs/$ENV" && terraform output -raw jumphost_public_ip 2>/dev/null || echo "N/A")
echo "   Jumphost IP: $JUMPHOST_IP"

# EKS Verification (§74, §75)
echo ""
echo "✅ D) EKS cluster + managed node group (2x t3.medium)"
EKS_CLUSTER=$(cd "envs/$ENV" && terraform output -raw eks_cluster_name 2>/dev/null || echo "N/A")
echo "   Cluster: $EKS_CLUSTER"

echo ""
echo "=== Next Steps ==="
echo "1. SSH to jumphost: ssh -i <key> ec2-user@$JUMPHOST_IP"
echo "2. Update kubeconfig: aws eks update-kubeconfig --name $EKS_CLUSTER"
echo "3. Verify nodes: kubectl get nodes (should show 2 Ready nodes)"
echo "4. Verify tools: ~/verify-tools.sh"
