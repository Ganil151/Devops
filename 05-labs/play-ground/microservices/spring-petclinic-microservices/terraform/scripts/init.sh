#!/bin/bash
set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./init.sh [dev|staging|prod]"
  exit 1
fi

cd "environments/$ENV"

# Copy shared configuration files
echo "Copying shared configuration..."
cp ../../shared/versions.tf .
cp ../../shared/providers.tf .
cp ../../shared/data.tf . 2>/dev/null || true

terraform init
echo "✅ Initialized $ENV environment"
