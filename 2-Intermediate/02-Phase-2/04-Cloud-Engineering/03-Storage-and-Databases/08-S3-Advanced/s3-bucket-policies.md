# AWS S3 Bucket Policies

Comprehensive guide to S3 bucket policies for access control, security, and resource management.

## What are Bucket Policies?

Bucket policies are JSON-based access policy documents attached to S3 buckets that define who can access bucket resources and what actions they can perform.

```yaml
Key Concepts:
  Bucket Policies:
    - Resource-based policies
    - Attached to S3 buckets
    - Grant cross-account access
    - Control public access
  
  IAM Policies:
    - User/role-based policies
    - Attached to IAM identities
    - Control what users can do
  
  When to Use:
    - Grant public access
    - Cross-account access
    - Share specific objects
    - Enforce encryption
    - Restrict by IP address
```

## Policy Structure

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "UniqueStatementId",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/username"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bucket-name/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "192.0.2.0/24"
        }
      }
    }
  ]
}
```

### Policy Elements

```yaml
Version:
  Description: Policy language version
  Value: "2012-10-17"
  Required: Yes

Sid:
  Description: Statement ID (optional)
  Purpose: Human-readable identifier
  Required: No

Effect:
  Description: Allow or Deny
  Values: ["Allow", "Deny"]
  Required: Yes

Principal:
  Description: Who the policy applies to
  Examples:
    - AWS account: "arn:aws:iam::123456789012:root"
    - IAM user: "arn:aws:iam::123456789012:user/username"
    - Everyone: "*"
  Required: Yes

Action:
  Description: S3 operations allowed/denied
  Examples:
    - "s3:GetObject"
    - "s3:PutObject"
    - "s3:*"
  Required: Yes

Resource:
  Description: Bucket or object ARN
  Examples:
    - Bucket: "arn:aws:s3:::bucket-name"
    - Objects: "arn:aws:s3:::bucket-name/*"
  Required: Yes

Condition:
  Description: Optional conditions
  Purpose: Fine-grained control
  Required: No
```

## Common S3 Actions

```yaml
Read Operations:
  - s3:GetObject              # Download objects
  - s3:GetObjectVersion       # Download specific version
  - s3:ListBucket             # List bucket contents
  - s3:GetBucketLocation      # Get bucket region
  - s3:GetBucketVersioning    # Check versioning status

Write Operations:
  - s3:PutObject              # Upload objects
  - s3:DeleteObject           # Delete objects
  - s3:DeleteObjectVersion    # Delete specific version
  - s3:PutBucketVersioning    # Enable/disable versioning

Permission Operations:
  - s3:GetBucketPolicy        # Read bucket policy
  - s3:PutBucketPolicy        # Write bucket policy
  - s3:DeleteBucketPolicy     # Delete bucket policy
  - s3:GetBucketAcl           # Read ACL
  - s3:PutBucketAcl           # Write ACL

Wildcard:
  - s3:*                      # All S3 actions
```

## Policy Examples

### 1. Public Read Access

Allow anyone to read objects (for static websites):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-public-bucket/*"
    }
  ]
}
```

**Apply via CLI:**

```bash
# Save policy to file
cat > public-read-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-public-bucket/*"
    }
  ]
}
EOF

# Apply policy
aws s3api put-bucket-policy \
  --bucket my-public-bucket \
  --policy file://public-read-policy.json

# Note: Must also disable public access block
aws s3api delete-public-access-block --bucket my-public-bucket
```

### 2. Restrict Access by IP Address

Allow access only from specific IP addresses:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IPRestriction",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "203.0.113.0/24",
            "198.51.100.0/24"
          ]
        }
      }
    }
  ]
}
```

### 3. Cross-Account Access

Grant another AWS account access to your bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CrossAccountAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111122223333:root"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::my-shared-bucket/*"
    },
    {
      "Sid": "CrossAccountListBucket",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111122223333:root"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::my-shared-bucket"
    }
  ]
}
```

### 4. Require Encryption in Transit (HTTPS)

Deny all requests that don't use HTTPS:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-secure-bucket",
        "arn:aws:s3:::my-secure-bucket/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

### 5. Require Server-Side Encryption

Deny uploads without server-side encryption:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-encrypted-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
```

### 6. CloudFront Origin Access Identity (OAI)

Grant CloudFront access while blocking direct access:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudFrontAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E1ABCDEFGHIJK"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-cdn-bucket/*"
    }
  ]
}
```

### 7. Grant Full Access to Specific IAM User

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FullAccessForUser",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/alice"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::alice-bucket",
        "arn:aws:s3:::alice-bucket/*"
      ]
    }
  ]
}
```

### 8. Read-Only Access for Multiple Users

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:user/bob",
          "arn:aws:iam::123456789012:user/carol",
          "arn:aws:iam::123456789012:role/ReadOnlyRole"
        ]
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::shared-docs",
        "arn:aws:s3:::shared-docs/*"
      ]
    }
  ]
}
```

### 9. Folder-Level Permissions

Grant access to specific prefixes (folders):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowUserToListBucket",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/developer"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::company-data",
      "Condition": {
        "StringLike": {
          "s3:prefix": "project-a/*"
        }
      }
    },
    {
      "Sid": "AllowUserToReadWriteFolder",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/developer"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::company-data/project-a/*"
    }
  ]
}
```

### 10. Temporary Access with Time Restriction

Grant access only during specific time period:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TemporaryAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/contractor"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::project-files/*",
      "Condition": {
        "DateGreaterThan": {
          "aws:CurrentTime": "2024-01-01T00:00:00Z"
        },
        "DateLessThan": {
          "aws:CurrentTime": "2024-12-31T23:59:59Z"
        }
      }
    }
  ]
}
```

## Managing Bucket Policies with AWS CLI

### View Current Policy

```bash
# Get bucket policy
aws s3api get-bucket-policy --bucket my-bucket

# Pretty print
aws s3api get-bucket-policy \
  --bucket my-bucket \
  --query Policy \
  --output text | jq '.'
```

### Apply Policy

```bash
# From file
aws s3api put-bucket-policy \
  --bucket my-bucket \
  --policy file://bucket-policy.json

# Inline (escape quotes)
aws s3api put-bucket-policy \
  --bucket my-bucket \
  --policy '{"Version":"2012-10-17","Statement":[...]}'
```

### Delete Policy

```bash
aws s3api delete-bucket-policy --bucket my-bucket
```

### Test Policy

```bash
# Simulate policy evaluation
aws iam simulate-custom-policy \
  --policy-input-list file://bucket-policy.json \
  --action-names s3:GetObject s3:PutObject \
  --resource-arns arn:aws:s3:::my-bucket/test.txt
```

## Terraform Bucket Policy Example

```hcl
# S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"
}

# Bucket Policy
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.example.arn}/*"
      },
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
```

## Best Practices

```yaml
Security:
  1. Principle of Least Privilege:
    - Grant minimum necessary permissions
    - Use specific actions, not wildcards
    - Restrict by resource ARN
  
  2. Require Encryption:
    - Enforce HTTPS (aws:SecureTransport)
    - Require server-side encryption
    - Use KMS for sensitive data
  
  3. Avoid Public Access:
    - Block public access by default
    - Use CloudFront for public content
    - Enable access logging

Performance:
  1. Use Conditions:
    - IP restrictions
    - Time-based access
    - MFA requirements
  
  2. Combine Policies:
    - Use with IAM policies
    - Leverage role-based access
    - Share across accounts

Maintenance:
  1. Document Policies:
    - Use descriptive Sid values
    - Add comments in Terraform
    - Version control policies
  
  2. Regular Audits:
    - Review access patterns
    - Remove unused permissions
    - Test policy changes
  
  3. Use Policy Generator:
    - AWS Policy Generator tool
    - Validate with IAM Policy Simulator
    - Test before production
```

## Common Pitfalls

```yaml
Mistakes to Avoid:
  1. Overly Permissive:
    Problem: "Principal": "*" with "Action": "s3:*"
    Solution: Restrict by IP, VPC, or identity
  
  2. Missing ListBucket:
    Problem: Can't list bucket contents
    Solution: Add s3:ListBucket on bucket ARN
  
  3. Wrong Resource ARN:
    Problem: Policy on bucket, need objects
    Solution: Use "arn:aws:s3:::bucket/*"
  
  4. Public Access Block:
    Problem: Policy allows public, but blocked
    Solution: Disable public access block if intentional
  
  5. Conflicting Deny:
    Problem: Explicit Deny overrides Allow
    Solution: Review all policies carefully
```

## Troubleshooting

### Access Denied Errors

```bash
# 1. Check bucket policy
aws s3api get-bucket-policy --bucket my-bucket

# 2. Check public access block
aws s3api get-public-access-block --bucket my-bucket

# 3. Check IAM permissions
aws iam get-user-policy --user-name myuser --policy-name mypolicy

# 4. Test access
aws s3 ls s3://my-bucket/ --debug
```

### Policy Too Large

```yaml
Issue: Policy exceeds 20 KB limit
Solutions:
  - Use IAM policies instead
  - Simplify conditions
  - Use wildcards efficiently
  - Split into multiple buckets
```

### Invalid JSON

```bash
# Validate JSON syntax
cat bucket-policy.json | jq '.'

# AWS policy validator
aws accessanalyzer validate-policy \
  --policy-document file://bucket-policy.json \
  --policy-type RESOURCE_POLICY
```

## Additional Resources

- [AWS S3 Bucket Policy Examples](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html)
- [IAM Policy Simulator](https://policysim.aws.amazon.com/)
- [AWS Policy Generator](https://awspolicygen.s3.amazonaws.com/policygen.html)
- [S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
