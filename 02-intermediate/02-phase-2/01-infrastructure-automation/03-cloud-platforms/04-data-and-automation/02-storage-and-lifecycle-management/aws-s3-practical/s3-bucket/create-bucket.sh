#!/bin/bash
BUCKET_NAME="dev-gsmash-tf-bucket"
REGION="us-east-1"

# Check if bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Bucket $BUCKET_NAME already exists."
else
    echo "Bucket $BUCKET_NAME does not exist. Creating..."
    
    # Create Bucket
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION"

    # Enable Versioning (Crucial for State recovery)
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled

    # Enable Encryption
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
    
    echo "Bucket created and configured successfully."
fi