#!/bin/bash
set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./destroy.sh [dev|staging|prod]"
  exit 1
fi

if [ "$ENV" == "prod" ]; then
  echo "⚠️  WARNING: You are about to destroy PRODUCTION infrastructure!"
  read -p "Type 'destroy-prod' to confirm: " CONFIRM
  if [ "$CONFIRM" != "destroy-prod" ]; then
    echo "❌ Destruction cancelled."
    exit 1
  fi
fi

cd "environments/$ENV"
terraform destroy
echo "✅ Infrastructure destroyed in $ENV"
