#!/bin/bash
set -e

# CloudFormation Deployment Script
# Usage: ./deploy.sh <stack-name> <template-file> <environment>

STACK_NAME=${1:-"my-default-stack"}
TEMPLATE_FILE=${2:-"template.yaml"}
ENVIRONMENT=${3:-"dev"}

echo "=========================================="
echo "CloudFormation Deployment"
echo "=========================================="
echo "Stack Name:    $STACK_NAME"
echo "Template:      $TEMPLATE_FILE"
echo "Environment:   $ENVIRONMENT"
echo "=========================================="

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Error: Template file '$TEMPLATE_FILE' not found!"
    exit 1
fi

# Validate template
echo ""
echo "📋 Step 1: Validating template..."
if aws cloudformation validate-template --template-body file://$TEMPLATE_FILE > /dev/null 2>&1; then
    echo "✅ Template is valid"
else
    echo "❌ Template validation failed! Aborting deployment."
    exit 1
fi

# Deploy stack using deploy command (recommended over create-stack)
echo ""
echo "🚀 Step 2: Deploying stack..."
if aws cloudformation deploy \
  --template-file $TEMPLATE_FILE \
  --stack-name $STACK_NAME \
  --parameter-overrides Environment=$ENVIRONMENT \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  --output text; then
    echo "✅ Stack deployed successfully!"
else
    echo "❌ Stack deployment failed!"
    exit 1
fi

# Show stack outputs
echo ""
echo "📊 Step 3: Stack Outputs"
echo "=========================================="
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query 'Stacks[0].Outputs' \
  --output table

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo "Stack Name: $STACK_NAME"
echo "Environment: $ENVIRONMENT"
echo ""
echo "To delete this stack, run:"
echo "  aws cloudformation delete-stack --stack-name $STACK_NAME"
echo "=========================================="
