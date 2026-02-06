# AWS S3 Security Best Practices

Enterprise-grade security practices for AWS S3 including VPC endpoints, Access Points, encryption strategies, and advanced IAM configurations.

## Security Layers

```yaml
Defense in Depth:
  1. Network Security:
    - VPC Endpoints (PrivateLink)
    - Security Groups
    - Network ACLs
    - AWS WAF + CloudFront
  
  2. Identity & Access:
    - IAM least privilege
    - MFA enforcement
    - Cross-account roles
    - Service Control Policies
  
  3. Data Protection:
    - Encryption at rest (KMS)
    - Encryption in transit (TLS)
    - S3 Object Lock
    - Versioning + MFA Delete
  
  4. Monitoring & Auditing:
    - CloudTrail logging
    - S3 Access Logging
    - S3 Access Analyzer
    - Amazon Macie
  
  5. Application Security:
    - Pre-signed URLs
    - Temporary credentials
    - Least privilege policies
    - Regular reviews
```

## VPC Endpoints

Provide private connectivity to S3 without internet gateway:

```hcl
# VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  
  route_table_ids = [
    aws_route_table.private.id
  ]
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket/*"
        ]
      }
    ]
  })
  
  tags = {
    Name = "S3-VPC-Endpoint"
  }
}

# Bucket policy to require VPC endpoint
resource "aws_s3_bucket_policy" "vpc_only" {
  bucket = aws_s3_bucket.secure.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyNonVPCAccess"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.secure.arn,
          "${aws_s3_bucket.secure.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.s3.id
          }
        }
      }
    ]
  })
}
```

## S3 Access Points

Simplified access management for shared datasets:

```hcl
# S3 Access Point
resource "aws_s3_access_point" "analytics_team" {
  bucket = aws_s3_bucket.data_lake.id
  name   = "analytics-team-ap"
  
  vpc_configuration {
    vpc_id = aws_vpc.main.id
  }
  
  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# Access Point policy
resource "aws_s3control_access_point_policy" "analytics_team" {
  access_point_arn = aws_s3_access_point.analytics_team.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.analytics_team.arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_access_point.analytics_team.arn,
          "${aws_s3_access_point.analytics_team.arn}/object/*"
        ]
        Condition = {
          StringLike = {
            "s3:prefix" = "analytics/*"
          }
        }
      }
    ]
  })
}

# Usage with access point
# arn:aws:s3:us-east-1:123456789012:accesspoint/analytics-team-ap
```

## Multi-Region Access Points

Global access with automatic routing:

```hcl
# Multi-Region Access Point
resource "aws_s3control_multi_region_access_point" "global" {
  details {
    name = "global-data"
    
    region {
      bucket = aws_s3_bucket.us_east_1.id
    }
    
    region {
      bucket = aws_s3_bucket.eu_west_1.id
    }
    
    region {
      bucket = aws_s3_bucket.ap_southeast_1.id
    }
    
    public_access_block {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }
}

# Access via MRAP alias
# {mrap_alias}.mrap
```

## Encryption Strategies

### Server-Side Encryption with KMS

```hcl
# KMS key for S3
resource "aws_kms_key" "s3" {
  description             = "S3 encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3 bucket with KMS encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "kms" {
  bucket = aws_s3_bucket.secure.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

# Deny unencrypted uploads
resource "aws_s3_bucket_policy" "require_encryption" {
  bucket = aws_s3_bucket.secure.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnencryptedUploads"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.secure.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      }
    ]
  })
}
```

## S3 Object Lock

WORM (Write Once Read Many) storage for compliance:

```hcl
# Bucket with Object Lock
resource "aws_s3_bucket" "compliance" {
  bucket = "compliance-bucket"
  
  object_lock_enabled = true
}

resource "aws_s3_bucket_versioning" "compliance" {
  bucket = aws_s3_bucket.compliance.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Object Lock configuration
resource "aws_s3_bucket_object_lock_configuration" "compliance" {
  bucket = aws_s3_bucket.compliance.id
  
  rule {
    default_retention {
      mode = "COMPLIANCE"  # or "GOVERNANCE"
      days = 2555          # 7 years
    }
  }
}

# Apply legal hold via CLI
# aws s3api put-object-legal-hold \
#   --bucket compliance-bucket \
#   --key document.pdf \
#   --legal-hold Status=ON
```

## MFA Delete

Require MFA for object deletion:

```bash
# Enable versioning and MFA delete
aws s3api put-bucket-versioning \
  --bucket my-secure-bucket \
  --versioning-configuration Status=Enabled,MFADelete=Enabled \
  --mfa "arn:aws:iam::123456789012:mfa/user 123456"

# Delete object with MFA
aws s3api delete-object \
  --bucket my-secure-bucket \
  --key sensitive-file.txt \
  --mfa "arn:aws:iam::123456789012:mfa/user 789012"
```

## IAM Best Practices

### Least Privilege Roles

```hcl
# Read-only role
resource "aws_iam_role" "s3_readonly" {
  name = "S3ReadOnlyRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "unique-external-id"
          }
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_readonly" {
  role = aws_iam_role.s3_readonly.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObject Version",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      }
    ]
  })
}
```

## S3 Access Analyzer

Continuous monitoring for unintended access:

```bash
# Create analyzer
aws accessanalyzer create-analyzer \
  --analyzer-name s3-access-analyzer \
  --type ACCOUNT

# List findings
aws accessanalyzer list-findings \
  --analyzer-arn arn:aws:access-analyzer:us-east-1:123456789012:analyzer/s3-access-analyzer

# Get specific finding
aws accessanalyzer get-finding \
  --analyzer-arn arn:aws:access-analyzer:us-east-1:123456789012:analyzer/s3-access-analyzer \
  --id finding-id-12345
```

## Amazon Macie

Discover and protect sensitive data:

```hcl
# Enable Macie
resource "aws_macie2_account" "main" {}

# Classification job
resource "aws_macie2_classification_job" "scan" {
  job_type = "ONE_TIME"
  name     = "Sensitive-Data-Scan"
  
  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.sensitive.id]
    }
  }
  
  sampling_percentage = 100
  
  schedule_frequency {
    daily_schedule = true
  }
}
```

## Logging & Monitoring

### S3 Access Logging

```hcl
# Log bucket
resource "aws_s3_bucket" "logs" {
  bucket = "access-logs-bucket"
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

# Enable access logging
resource "aws_s3_bucket_logging" "source" {
  bucket = aws_s3_bucket.source.id
  
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access-logs/"
}
```

### CloudTrail Data Events

```hcl
resource "aws_cloudtrail" "s3_data_events" {
  name           = "s3-data-events"
  s3_bucket_name = aws_s3_bucket.cloudtrail.id
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type = "AWS::S3::Object"
      
      values = [
        "${aws_s3_bucket.sensitive.arn}/*"
      ]
    }
  }
}
```

## Security Checklist

```yaml
Network:
  ✓ VPC Endpoints configured
  ✓ Public access blocked
  ✓ WAF rules if using CloudFront
  ✓ DDoS protection enabled

Identity:
  ✓ IAM roles use least privilege
  ✓ MFA enforced for sensitive operations
  ✓ Cross-account access reviewed
  ✓ SCPs implemented

Encryption:
  ✓ Default encryption enabled
  ✓ KMS keys rotated
  ✓ TLS 1.2+ enforced
  ✓ Bucket key enabled

Protection:
  ✓ Versioning enabled
  ✓ Object Lock for compliance
  ✓ MFA Delete configured
  ✓ Replication configured

Monitoring:
  ✓ CloudTrail data events
  ✓ Access logging enabled
  ✓ Access Analyzer active
  ✓ Macie scans scheduled

Policies:
  ✓ Bucket policies restrictive
  ✓ No wildcard principals
  ✓ Deny overrides tested
  ✓ Regular policy reviews
```

## Additional Resources

- [S3 Enterprise README](../../../../readme.md)
- [AWS S3 Security](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security.html)
- [S3 Access Points](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-points.html)
- [S3 Object Lock](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html)
