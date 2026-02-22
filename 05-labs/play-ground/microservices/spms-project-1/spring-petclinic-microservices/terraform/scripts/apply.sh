#!/bin/bash
set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./apply.sh [dev|staging|prod]"
  exit 1
fi

cd "environments/$ENV"

if [ ! -f "tfplan" ]; then
  echo "❌ No plan file found. Run ./plan.sh $ENV first."
  exit 1
fi

echo "🚀 Applying Terraform plan for $ENV environment..."
terraform apply tfplan
rm -f tfplan
echo "✅ Infrastructure deployed to $ENV"
