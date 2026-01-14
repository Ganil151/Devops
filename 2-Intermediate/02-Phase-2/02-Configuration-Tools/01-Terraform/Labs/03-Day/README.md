# S3 Bucket Implementation Guide

This guide provides step-by-step instructions for implementing and using AWS S3 buckets.

## Prerequisites

- AWS CLI installed and configured
- Terraform installed (for Infrastructure as Code approach)
- AWS account with appropriate permissions

## Step-by-Step Implementation

### Step 1: Basic S3 Bucket Creation

#### Using AWS CLI
```bash
# Create a basic S3 bucket
aws s3 mb s3://your-bucket-name --region us-east-1
```

#### Using Terraform
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "your-unique-bucket-name"
}
```

### Step 2: Configure Bucket Settings

#### Versioning
```hcl
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

#### Server-Side Encryption
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### Step 3: Set Bucket Policies

```hcl
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
      }
    ]
  })
}
```

### Step 4: Upload Objects

#### Using AWS CLI
```bash
# Upload a single file
aws s3 cp file.txt s3://your-bucket-name/

# Upload a directory
aws s3 sync ./local-folder s3://your-bucket-name/folder/
```

#### Using Terraform
```hcl
resource "aws_s3_object" "example" {
  bucket = aws_s3_bucket.example.id
  key    = "example-file.txt"
  source = "path/to/local/file.txt"
}
```

### Step 5: Access and Management

#### List bucket contents
```bash
aws s3 ls s3://your-bucket-name/
```

#### Download objects
```bash
aws s3 cp s3://your-bucket-name/file.txt ./local-file.txt
```

#### Delete objects
```bash
aws s3 rm s3://your-bucket-name/file.txt
```

## Best Practices

1. **Naming**: Use lowercase letters, numbers, and hyphens only
2. **Security**: Enable versioning and encryption
3. **Access Control**: Use least privilege principle
4. **Monitoring**: Enable CloudTrail and access logging
5. **Cost Optimization**: Use appropriate storage classes

## Additional Resources

For more detailed information about S3 bucket fundamentals, refer to:
[S3 Bucket Basics](../../../../../../1-Beginner/1-Beginner-Level/13-Cloud-Foundations/05-AWS-Basics/03-Storage/s3-bucket/README.md)

## Common Commands Reference

```bash
# Create bucket
aws s3 mb s3://bucket-name

# List buckets
aws s3 ls

# Copy files
aws s3 cp source destination

# Sync directories
aws s3 sync source destination

# Remove files
aws s3 rm s3://bucket-name/file

# Remove bucket (must be empty)
aws s3 rb s3://bucket-name
```

## Troubleshooting

- **Bucket name already exists**: Choose a globally unique name
- **Access denied**: Check IAM permissions and bucket policies
- **Region mismatch**: Ensure consistent region configuration