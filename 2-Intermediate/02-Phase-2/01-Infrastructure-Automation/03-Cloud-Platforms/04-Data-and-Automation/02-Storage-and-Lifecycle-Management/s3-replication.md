# AWS S3 Replication

Complete guide to S3 Cross-Region Replication (CRR) and Same-Region Replication (SRR) for disaster recovery, compliance, and data distribution.

## Overview

S3 Replication automatically copies objects across S3 buckets in the same or different AWS regions.

```yaml
Types:
  Cross-Region Replication (CRR):
    - Replicate between different regions
    - Disaster recovery
    - Latency reduction
    - Compliance requirements
  
  Same-Region Replication (SRR):
    - Replicate within same region
    - Aggregate logs
    - Live replication between accounts
    - Production/test synchronization

Benefits:
  - Automated copying
  - 99.99% replication SLA with RTC
  - Metadata preservation
  - Ownership changes supported
  - Encryption support
```

## Prerequisites

```yaml
Requirements:
  Source Bucket:
    - Versioning must be enabled
    - Objects can be any storage class
    - Can be in any region
  
  Destination Bucket:
    - Versioning must be enabled
    - Can be in same/different account
    - Can be in same/different region
  
  IAM Role:
    - Permissions to read from source
    - Permissions to write to destination
    - Trust policy for S3 service
```

## Setup Guide

### 1. Enable Versioning on Both Buckets

```bash
# Source bucket
aws s3api put-bucket-versioning \
  --bucket source-bucket \
  --versioning-configuration Status=Enabled

# Destination bucket
aws s3api put-bucket-versioning \
  --bucket destination-bucket \
  --versioning-configuration Status=Enabled

# Verify
aws s3api get-bucket-versioning --bucket source-bucket
aws s3api get-bucket-versioning --bucket destination-bucket
```

### 2. Create IAM Replication Role

```bash
# Create trust policy
cat > replication-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name S3ReplicationRole \
  --assume-role-policy-document file://replication-trust-policy.json

# Create permissions policy
cat > replication-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket",
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Resource": [
        "arn:aws:s3:::source-bucket",
        "arn:aws:s3:::source-bucket/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Resource": "arn:aws:s3:::destination-bucket/*"
    }
  ]
}
EOF

# Attach policy
aws iam put-role-policy \
  --role-name S3ReplicationRole \
  --policy-name S3ReplicationPolicy \
  --policy-document file://replication-policy.json
```

### 3. Configure Replication Rules

```bash
# Create replication configuration
cat > replication-config.json << 'EOF'
{
  "Role": "arn:aws:iam::123456789012:role/S3ReplicationRole",
  "Rules": [
    {
      "ID": "ReplicateAll",
      "Priority": 1,
      "Status": "Enabled",
      "Filter": {},
      "Destination": {
        "Bucket": "arn:aws:s3:::destination-bucket",
        "ReplicationTime": {
          "Status": "Enabled",
          "Time": {
            "Minutes": 15
          }
        },
        "Metrics": {
          "Status": "Enabled",
          "EventThreshold": {
            "Minutes": 15
          }
        }
      },
      "DeleteMarkerReplication": {
        "Status": "Enabled"
      }
    }
  ]
}
EOF

# Apply configurationaws s3api put-bucket-replication \
  --bucket source-bucket \
  --replication-configuration file://replication-config.json

# Verify
aws s3api get-bucket-replication --bucket source-bucket
```

## Terraform Configuration

### Basic CRR Setup

```hcl
# Provider for source region
provider "aws" {
  alias  = "source"
  region = "us-east-1"
}

# Provider for destination region
provider "aws" {
  alias  = "destination"
  region = "us-west-2"
}

# Source bucket
resource "aws_s3_bucket" "source" {
  provider = aws.source
  bucket   = "my-source-bucket"
}

resource "aws_s3_bucket_versioning" "source" {
  provider = aws.source
  bucket   = aws_s3_bucket.source.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Destination bucket
resource "aws_s3_bucket" "destination" {
  provider = aws.destination
  bucket   = "my-destination-bucket"
}

resource "aws_s3_bucket_versioning" "destination" {
  provider = aws.destination
  bucket   = aws_s3_bucket.destination.id

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM role for replication
resource "aws_iam_role" "replication" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM policy for replication
resource "aws_iam_role_policy" "replication" {
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = [
          aws_s3_bucket.source.arn,
          "${aws_s3_bucket.source.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.destination.arn}/*"
      }
    ]
  })
}

# Replication configuration
resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.source
  role     = aws_iam_role.replication.arn
  bucket   = aws_s3_bucket.source.id

  rule {
    id     = "ReplicateAll"
    status = "Enabled"

    filter {}

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"

      # Replication Time Control (RTC)
      replication_time {
        status = "Enabled"
        time {
          minutes = 15
        }
      }

      metrics {
        status = "Enabled"
        event_threshold {
          minutes = 15
        }
      }
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }

  depends_on = [aws_s3_bucket_versioning.source]
}
```

### Advanced: Selective Replication

```hcl
resource "aws_s3_bucket_replication_configuration" "selective" {
  provider = aws.source
  role     = aws_iam_role.replication.arn
  bucket   = aws_s3_bucket.source.id

  rule {
    id       = "ReplicateDocuments"
    priority = 10
    status   = "Enabled"

    filter {
      prefix = "documents/"
    }

    destination {
      bucket = aws_s3_bucket.destination.arn
    }
  }

  rule {
    id       = "ReplicateImages"
    priority = 20
    status   = "Enabled"

    filter {
      and {
        prefix = "images/"
        tags = {
          replicate = "true"
        }
      }
    }

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD_IA"
    }
  }

  rule {
    id       = "ReplicateLogs"
    priority = 30
    status   = "Enabled"

    filter {
      prefix = "logs/"
    }

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "GLACIER"
    }
  }

  depends_on = [aws_s3_bucket_versioning.source]
}
```

## Replication Features

### 1. Replication Time Control (RTC)

Guarantees 99.99% of objects replicate within 15 minutes:

```json
{
  "ReplicationTime": {
    "Status": "Enabled",
    "Time": {
      "Minutes": 15
    }
  },
  "Metrics": {
    "Status": "Enabled",
    "EventThreshold": {
      "Minutes": 15
    }
  }
}
```

### 2. Delete Marker Replication

```json
{
  "DeleteMarkerReplication": {
    "Status": "Enabled"
  }
}
```

### 3. Replica Modification Sync

Replicate metadata changes:

```json
{
  "SourceSelectionCriteria": {
    "ReplicaModifications": {
      "Status": "Enabled"
    }
  }
}
```

### 4. Two-Way Replication

```hcl
# Bucket A -> Bucket B
resource "aws_s3_bucket_replication_configuration" "a_to_b" {
  provider = aws.region_a
  role     = aws_iam_role.replication_a.arn
  bucket   = aws_s3_bucket.bucket_a.id

  rule {
    id     = "ReplicateToB"
    status = "Enabled"
    filter {}
    destination {
      bucket = aws_s3_bucket.bucket_b.arn
    }
  }
}

# Bucket B -> Bucket A
resource "aws_s3_bucket_replication_configuration" "b_to_a" {
  provider = aws.region_b
  role     = aws_iam_role.replication_b.arn
  bucket   = aws_s3_bucket.bucket_b.id

  rule {
    id     = "ReplicateToA"
    status = "Enabled"
    filter {}
    destination {
      bucket = aws_s3_bucket.bucket_a.arn
    }
  }
}
```

## Batch Replication

Replicate existing objects:

```bash
# Create batch replication job
aws s3control create-job \
  --account-id 123456789012 \
  --operation '{
    "S3ReplicateObject": {}
  }' \
  --manifest '{
    "Spec": {
      "Format": "S3BatchOperations_CSV_20180820",
      "Fields": ["Bucket","Key"]
    },
    "Location": {
      "ObjectArn": "arn:aws:s3:::manifest-bucket/manifest.csv",
      "ETag": "..."
    }
  }' \
  --report '{
    "Bucket": "arn:aws:s3:::report-bucket",
    "Prefix": "batch-replication-reports",
    "Format": "Report_CSV_20180820",
    "Enabled": true,
    "ReportScope": "AllTasks"
  }' \
  --priority 10 \
  --role-arn arn:aws:iam::123456789012:role/BatchReplicationRole \
  --region us-east-1

# Check job status
aws s3control describe-job \
  --account-id 123456789012 \
  --job-id  00e123a4-c0de-41f4-a0e0-example12345 \
  --region us-east-1
```

## Monitoring Replication

### CloudWatch Metrics

```bash
# Replication latency
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name ReplicationLatency \
  --dimensions Name=SourceBucket,Value=source-bucket \
    Name=DestinationBucket,Value=destination-bucket \
    Name=RuleId,Value=ReplicateAll \
  --statistics Average,Maximum \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600

# Bytes pending replication
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name BytesPendingReplication \
  --dimensions Name=SourceBucket,Value=source-bucket \
  --statistics Sum \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600
```

### Check Replication Status

```bash
# View replication status of an object
aws s3api head-object \
  --bucket source-bucket \
  --key myfile.txt \
  --query ReplicationStatus

# Possible values:
# - PENDING: Object queued for replication
# - COMPLETED: Successfully replicated
# - FAILED: Replication failed
# - REPLICA: Object is a replica

# List objects with replication status
aws s3api list-object-versions \
  --bucket source-bucket \
  --prefix documents/ \
  --query 'Versions[*].[Key,VersionId,ReplicationStatus]' \
  --output table
```

## Cost Optimization

```yaml
Strategies:
  1. Selective Replication:
    - Replicate only necessary prefixes
    - Use tag-based filtering
    - Exclude temporary files
  
  2. Storage Class:
    - Replicate to cheaper storage class
    - Use lifecycle policies on replica
    - Intelligent-Tiering for replicas
  
  3. Batch Replication:
    - One-time replication of existing objects
    - Schedule during off-peak hours
    - Monitor costs with Cost Explorer
  
  4. Replication Metrics:
    - Disable if not using RTC
    - Reduce monitoring frequency
    - Use CloudWatch alarms selectively

Costs:
  Data Transfer:
    Cross-Region: $0.02/GB (varies by region)
    Same-Region: Free
  
  Storage:
    Destination: Standard storage costs
    Lifecycle: Transition to cheaper classes
  
  Requests:
    PUT/COPY: Replication generates requests
    RTC: Additional $0.01/GB charge
```

## Use Cases

### 1. Disaster Recovery

```yaml
Scenario:
  - Primary operations in us-east-1
  - DR site in us-west-2
  - RTO: 1 hour, RPO: 15 minutes

Configuration:
  - Enable CRR with RTC
  - Monitor replication metrics
  - Test failover procedures
  - Document recovery process
```

### 2. Compliance

```yaml
Scenario:
  - Data must exist in multiple regions
  - Retain for 7 years
  - Immutability required

Configuration:
  - Enable CRR
  - Enable Object Lock on replica
  - Compliance mode retention
  - Audit logging enabled
```

### 3. Data Aggregation

```yaml
Scenario:
  - Logs from multiple accounts
  - Centralized in one bucket
  - Same region consolidation

Configuration:
  - Enable SRR
  - Change ownership on replica
  - Separate lifecycle policies
  - Centralized analytics
```

## Troubleshooting

```yaml
Objects Not Replicating:
  Checks:
    - Versioning enabled on both buckets
    - IAM role has correct permissions
    - Replication rule status is Enabled
    - Filters allow the object
    - Object size < 5 TB
  
  Solutions:
    - Review CloudWatch Logs
    - Check replication status on object
    - Verify IAM trust relationships
    - Test with new upload

Slow Replication:
  Checks:
    - RTC enabled?
    - Large file sizes?
    - High request rate?
    - Network issues?
  
  Solutions:
    - Enable RTC for guaranteed SLA
    - Monitor ReplicationLatency metric
    - Check source/destination regions
    - Contact AWS Support if persistent

Replication Failing:
  Checks:
    - Destination bucket exists
    - IAM permissions current
    - Encryption compatibility
    - Bucket policies allow writes
  
  Solutions:
    - Review error messages
    - Check CloudWatch metrics
    - Verify KMS key access
    - Test manual object copy
```

## Best Practices

```yaml
Security:
  - Use separate IAM roles per replication rule
  - Enable encryption on both buckets
  - Use VPC endpoints for SRR
  - Audit replication activity
  - Implement least privilege

Performance:
  - Enable RTC for critical data
  - Monitor replication metrics
  - Plan for request rate capacity
  - Use batch replication for backfill

Cost:
  - Replicate only necessary data
  - Use appropriate storage classes
  - Implement lifecycle policies
  - Monitor with Cost Explorer
  - Regular cleanup of old replicas

Monitoring:
  - Set CloudWatch alarms
  - Track replication SLA
  - Monitor failed replications
  - Regular compliance audits
```

## Additional Resources

- [S3 Advanced README](README.md)
- [AWS S3 Replication Documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html)
- [Replication Time Control](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-time-control.html)
- [Batch Replication](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-batch-replication-batch.html)
