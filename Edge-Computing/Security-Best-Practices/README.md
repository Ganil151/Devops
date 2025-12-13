# Security Best Practices for Edge Computing

## S3 Bucket Security

### Secure Bucket Naming
```bash
# Use organization-specific prefixes
ORGANIZATION="company"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="${ORGANIZATION}-edge-deployment-packages-${AWS_ACCOUNT_ID}"
```

### Bucket Verification
```python
import boto3

def verify_bucket_ownership(bucket_name: str) -> bool:
    try:
        s3_client = boto3.client('s3')
        s3_client.head_bucket(Bucket=bucket_name)
        s3_client.get_bucket_policy(Bucket=bucket_name)
        return True
    except Exception:
        return False
```

### Secure Bucket Creation
```bash
#!/bin/bash
BUCKET_NAME="company-edge-deployment-packages-${AWS_ACCOUNT_ID}"

aws s3 mb s3://${BUCKET_NAME}
aws s3api put-bucket-versioning --bucket ${BUCKET_NAME} --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket ${BUCKET_NAME} --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block --bucket ${BUCKET_NAME} --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

## Security Checklist
- [ ] Use organization-specific bucket prefixes
- [ ] Include AWS Account ID in bucket names
- [ ] Verify bucket ownership before use
- [ ] Enable encryption and versioning
- [ ] Block public access
- [ ] Implement proper IAM policies