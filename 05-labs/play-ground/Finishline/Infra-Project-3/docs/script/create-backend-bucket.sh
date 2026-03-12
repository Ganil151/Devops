#!/bin/bash
# Create S3 backend bucket for Terraform state

set -euo pipefail

BUCKET_NAME="finishline-infra-app-$(openssl rand -hex 4)"
REGION="${AWS_REGION:-us-east-1}"

echo "Creating S3 bucket: $BUCKET_NAME in $REGION"

aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "✅ Backend bucket created: $BUCKET_NAME"
echo "Update backend.tf with this bucket name"
