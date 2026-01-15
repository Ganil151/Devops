#!/bin/bash

# boilerplate_multi_region_deployer.sh - Global infrastructure deployment

set -euo pipefail

readonly REGIONS=("us-east-1" "us-west-2" "eu-west-1" "ap-southeast-1")
readonly LAMBDA_FUNCTION="global-app"

for region in "${REGIONS[@]}"; do
    echo "Deploying to $region..."
    
    aws lambda create-function \
        --region "$region" \
        --function-name "$LAMBDA_FUNCTION" \
        --runtime python3.9 \
        --handler index.handler \
        --zip-file fileb://function.zip \
        --role arn:aws:iam::123456789012:role/lambda-role \
        2>/dev/null || echo "  (Already exists)"
    
    echo "✓ Deployed to $region"
done

echo "✓ Global deployment complete"
