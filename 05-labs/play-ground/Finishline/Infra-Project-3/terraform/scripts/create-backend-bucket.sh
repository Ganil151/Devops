#!/bin/bash
# =============================================================================
# Create S3 Backend Bucket with DynamoDB Table
# Finish Line 2026 Infrastructure
# Assignment: §28, §101, §105 - Bootstrap workflow for state management
# =============================================================================

set -euo pipefail

BUCKET_NAME="finishline-infra"
REGION="${AWS_REGION:-us-east-1}"

echo "Creating S3 bucket: $BUCKET_NAME in $REGION"

# Create bucket
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
echo "Creating DynamoDB table: ${BUCKET_NAME}-locks"
aws dynamodb create-table \
  --table-name "${BUCKET_NAME}-locks" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo "✅ Backend bucket created: $BUCKET_NAME"
echo "✅ DynamoDB table created: ${BUCKET_NAME}-locks"
echo ""
echo "Update envs/<env>/backend.tf with:"
echo "  bucket         = \"$BUCKET_NAME\""
echo "  dynamodb_table = \"${BUCKET_NAME}-locks\""
