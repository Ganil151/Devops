#!/bin/bash
set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./plan.sh [dev|staging|prod]"
  exit 1
fi

cd "environments/$ENV"
terraform plan -out=tfplan
echo "✅ Plan created for $ENV environment. Review with: terraform show tfplan"
