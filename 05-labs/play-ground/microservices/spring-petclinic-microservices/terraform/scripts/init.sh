#!/bin/bash
set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./init.sh [dev|staging|prod]"
  exit 1
fi

cd "environments/$ENV"
terraform init
echo "✅ Initialized $ENV environment"
