# AWS S3 Cost Optimization

Enterprise cost optimization strategies for S3 including Storage Lens, Intelligent-Tiering, lifecycle policies, and reserved capacity.

## Cost Components

```yaml
Storage Costs:
  Standard: $0.023/GB/month
  Standard-IA: $0.0125/GB/month
  One Zone-IA: $0.01/GB/month
  Glacier Instant: $0.004/GB/month
  Glacier Flexible: $0.0036/GB/month
  Glacier Deep Archive: $0.00099/GB/month

Request Costs:
  PUT/COPY/POST: $0.005 per 1,000
  GET/SELECT: $0.0004 per 1,000
  Lifecycle Transitions: $0.01 per 1,000

Data Transfer:
  Upload: Free
  Download: $0.09/GB (first 10 TB/month)
  Cross-Region: $0.02/GB
  Transfer Acceleration: $0.04-$0.08/GB
```

## S3 Storage Lens

Enterprise-wide visibility and optimization:

```hcl
# Storage Lens configuration
resource "aws_s3control_storage_lens_configuration" "org_wide" {
  config_id = "org-storage-lens"
  
  storage_lens_configuration {
    enabled = true
    
    account_level {
      activity_metrics {
        enabled = true
      }
      
      bucket_level {
        activity_metrics {
          enabled = true
        }
        
        prefix_level {
          storage_metrics {
            enabled = true
            selection_criteria {
              delimiter            = "/"
              max_depth            = 5
              min_storage_bytes_percentage = 5
            }
          }
        }
      }
    }
    
    # Organization-wide visibility
    include {
      buckets = []  # All buckets
      regions = []  # All regions
    }
    
    # Export metrics
    data_export {
      s3_bucket_destination {
        account_id        = data.aws_caller_identity.current.account_id
        arn               = aws_s3_bucket.storage_lens_reports.arn
        format           = "Parquet"
        output_schema_version = "V_1"
        prefix           = "storage-lens/"
        
        encryption {
          sse_s3 {}
        }
      }
    }
    
    # Advanced metrics (additional cost)
    advanced_metrics_and_insights {
      activity_metrics {
        enabled = true
      }
      
      advanced_cost_optimization_metrics {
        enabled = true
      }
      
      advanced_data_protection_metrics {
        enabled = true
      }
    }
  }
}
```

## Intelligent-Tiering

Automatic cost optimization:

```hcl
resource "aws_s3_bucket_intelligent_tiering_configuration" "entire_bucket" {
  bucket = aws_s3_bucket.data.id
  name   = "EntireBucket"
  
  status = "Enabled"
  
  # Frequent Access tier (default)
  # Infrequent Access tier (30 days)
  
  # Optional archive tiers
  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }
  
  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
  
  # Filter by prefix
  filter {
    prefix = "data/"
    
    tags = {
      Environment = "production"
    }
  }
}
```

### Cost Analysis

```yaml
Intelligent-Tiering Costs:
  Monitoring: $0.0025 per 1,000 objects
  No Retrieval Fees: Unlike IA/Glacier
  Automatic Optimization: No manual management
  
Breakeven:
  Objects > 128 KB: Cost-effective after 30 days
  Unpredictable Access: Ideal use case
  Frequent + Infrequent: Saves 40-70%
```

## Lifecycle Policies

Automated tier transitions:

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "comprehensive" {
  bucket = aws_s3_bucket.data.id
  
  # Transition logs to cheaper storage
  rule {
    id     = "OptimizeLogs"
    status = "Enabled"
    
    filter {
      prefix = "logs/"
    }
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 90
      storage_class = "GLACIER_IR"  # Instant Retrieval
    }
    
    transition {
      days          = 180
      storage_class = "GLACIER"
    }
    
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
    
    expiration {
      days = 2555  # 7 years
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  
  # Clean up incomplete multipart uploads
  rule {
    id     = "CleanupIncompleteUploads"
    status = "Enabled"
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
  
  # Expire old delete markers
  rule {
    id     = "ExpireDeleteMarkers"
    status = "Enabled"
    
    expiration {
      expired_object_delete_marker = true
    }
  }
  
  # Archive backups
  rule {
    id     = "ArchiveBackups"
    status = "Enabled"
    
    filter {
      and {
        prefix = "backups/"
        tags = {
          Archive = "true"
        }
      }
    }
    
    transition {
      days          = 1
      storage_class = "GLACIER"
    }
  }
}
```

## Storage Class Analysis

Identify optimization opportunities:

```bash
# Enable storage class analysis
aws s3api put-bucket-analytics-configuration \
  --bucket my-bucket \
  --id entire-bucket \
  --analytics-configuration '{
    "Id": "entire-bucket",
    "StorageClassAnalysis": {
      "DataExport": {
        "OutputSchemaVersion": "V_1",
        "Destination": {
          "S3BucketDestination": {
            "Format": "CSV",
            "Bucket": "arn:aws:s3:::analytics-bucket",
            "Prefix": "storage-class-analysis/"
          }
        }
      }
    }
  }'

# Get analysis results (available after 24-48 hours)
aws s3 cp s3://analytics-bucket/storage-class-analysis/ ./analysis/ --recursive
```

## Cost Allocation Tags

Track costs by project/team:

```hcl
#Tag resources
resource "aws_s3_bucket" "projects" {
  for_each = var.projects
  
  bucket = "${each.key}-bucket"
  
  tags = {
    Project     = each.key
    Team        = each.value.team
    CostCenter  = each.value.cost_center
    Environment = each.value.environment
  }
}

# Enable cost allocation tags
# AWS Console > Billing > Cost allocation tags
# Or via AWS Organizations
```

## S3 Batch Operations for Cost Control

Clean up old data at scale:

```python
import boto3
import csv
from datetime import datetime, timedelta

s3 = boto3.client('s3')

def generate_deletion_manifest(bucket, prefix, days_old=365):
    """
    Generate manifest of objects to delete
    """
    cutoff_date = datetime.now() - timedelta(days=days_old)
    manifest_items = []
    
    paginator = s3.get_paginator('list_objects_v2')
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get('Contents', []):
            if obj['LastModified'].replace(tzinfo=None) < cutoff_date:
                manifest_items.append({
                    'bucket': bucket,
                    'key': obj['Key']
                })
    
    # Write manifest
    with open('delete-manifest.csv', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['bucket', 'key'])
        writer.writeheader()
        writer.writerows(manifest_items)
    
    # Upload manifest
    s3.upload_file('delete-manifest.csv', bucket, 'manifests/delete-manifest.csv')
    
    return f"s3://{bucket}/manifests/delete-manifest.csv"

# Usage
manifest_uri = generate_deletion_manifest('my-bucket', 'old-data/', days_old=365)
print(f"Manifest created: {manifest_uri}")

# Create batch job via CLI
# aws s3control create-job --account-id 123456789012 \
#   --operation '{"S3DeleteObject":{}}' \
#   --manifest file://manifest-spec.json \
#   --priority 10 --role-arn arn:aws:iam::123456789012:role/BatchRole
```

## Request Optimization

Reduce request costs:

```yaml
Strategies:
  1. Use S3 Select:
    - Query data without downloading
    - Up to 400% cheaper
    - Reduced data transfer
  
  2. Batch Requests:
    - Use ListObjectsV2 with pagination
    - Combine small files
    - Reduce API calls
  
  3. CloudFront Caching:
    - Reduce origin requests
    - Lower S3 GET costs
    - Improve performance
  
  4. Multipart Upload:
    - Parallel uploads reduce time
    - Retry only failed parts
    - Cost-effective for large files
```

### S3 Select Example

```python
import boto3

s3 = boto3.client('s3')

# Query CSV without downloading entire file
response = s3.select_object_content(
    Bucket='my-bucket',
    Key='data/large-dataset.csv',
    ExpressionType='SQL',
    Expression="""
        SELECT customer_id, SUM(amount) as total
        FROM s3object s
        WHERE s.date >= '2024-01-01'
        GROUP BY customer_id
        HAVING total > 1000
    """,
    InputSerialization={
        'CSV': {
            'FileHeaderInfo': 'USE',
            'RecordDelimiter': '\n',
            'FieldDelimiter': ','
        },
        'CompressionType': 'GZIP'
    },
    OutputSerialization={
        'CSV': {}
    }
)

# Process results
for event in response['Payload']:
    if 'Records' in event:
        print(event['Records']['Payload'].decode('utf-8'))
```

## Data Transfer Optimization

```yaml
Strategies:
  1. Use CloudFront:
    - Free data transfer to CloudFront
    - Cheaper CloudFront egress
    - Global caching
  
  2. S3 Transfer Acceleration:
    - Only when faster (auto-disabled if not)
    - 50-500% faster
    - Worth cost for global uploads
  
  3. Direct Connect:
    - Dedicated network connection
    - Consistent performance
    - Lower transfer costs
  
  4. VPC Endpoints:
    - Free for same-region
    - Private connectivity
    - No internet gateway costs
```

## Reserved Capacity

For predictable workloads:

```yaml
Reserved Capacity:
  Availability: Select regions only
  Commitment: 1-year commitment
  Savings: Up to 30%
  Use Case: Known storage requirements
  
How to Purchase:
  - AWS Sales team
  - Minimum commitments apply
  - Best for > 100 TB
```

## Cost Monitoring

### CloudWatch Budgets

```hcl
resource "aws_budgets_budget" "s3_monthly" {
  name         = "s3-monthly-budget"
  budget_type  = "COST"
  limit_amount = "1000"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  cost_filter {
    name = "Service"
    values = ["Amazon Simple Storage Service"]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = ["admin@example.com"]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_email_addresses = ["admin@example.com"]
  }
}
```

### Cost Explorer API

```python
import boto3
from datetime import datetime, timedelta

ce = boto3.client('ce')

# Get S3 costs for last 30 days
end_date = datetime.now().date()
start_date = end_date - timedelta(days=30)

response = ce.get_cost_and_usage(
    TimePeriod={
        'Start': str(start_date),
        'End': str(end_date)
    },
    Granularity='DAILY',
    Metrics=['UnblendedCost'],
    GroupBy=[
        {'Type': 'DIMENSION', 'Key': 'SERVICE'},
        {'Type': 'TAG', 'Key': 'Project'}
    ],
    Filter={
        'Dimensions': {
            'Key': 'SERVICE',
            'Values': ['Amazon Simple Storage Service']
        }
    }
)

# Analyze costs
for result in response['ResultsByTime']:
    date = result['TimePeriod']['Start']
    for group in result['Groups']:
        service, project = group['Keys']
        cost = group['Metrics']['UnblendedCost']['Amount']
        print(f"{date} | {project} | ${float(cost):.2f}")
```

## Optimization Checklist

```yaml
Storage:
  ✓ Lifecycle policies configured
  ✓ Intelligent-Tiering enabled
  ✓ Storage Class Analysis reviewed
  ✓ Old versions cleaned up
  ✓ Incomplete uploads removed

Requests:
  ✓ CloudFront caching enabled
  ✓ S3 Select for queries
  ✓ Batch operations for bulk tasks
  ✓ Request patterns optimized

Transfer:
  ✓ VPC Endpoints for internal
  ✓ CloudFront for public content
  ✓ Transfer Acceleration evaluated
  ✓ Compression enabled

Monitoring:
  ✓ Storage Lens configured
  ✓ Cost allocation tags applied
  ✓ Budgets and alerts set
  ✓ Regular cost reviews
```

## Cost Reduction Strategies

```yaml
Quick Wins:
  1. Enable Intelligent-Tiering:
    Effort: Low
    Savings: 40-70%
    Risk: None
  
  2. Lifecycle Policies:
    Effort: Medium
    Savings: 50-95%
    Risk: Data access patterns
  
  3. Delete Old Versions:
    Effort: Low
    Savings: Varies
    Risk: None with backups
  
  4. Clean Incomplete Uploads:
    Effort: Low
    Savings: 5-10%
    Risk: None

Medium-Term:
  1. Storage Class Migration:
    Effort: Medium
    Savings: 50-80%
    Timeline: 1-2 months
  
  2. CloudFront Integration:
    Effort: Medium  
    Savings: 30-50% on transfer
    Timeline: 2-4 weeks
  
  3. Request Optimization:
    Effort: High
    Savings: 20-40% on requests
    Timeline: 1-3 months

Long-Term:
  1. Reserved Capacity:
    Effort: Low
    Savings: Up to 30%
    Commitment: 1 year
  
  2. Architecture Review:
    Effort: High
    Savings: 40-60%
    Timeline: 3-6 months
```

## Additional Resources

- [S3 Enterprise README](../../../../README.md)
- [AWS S3 Pricing](https://aws.amazon.com/s3/pricing/)
- [S3 Storage Lens](https://aws.amazon.com/s3/storage-lens/)
- [Cost Optimization](https://docs.aws.amazon.com/AmazonS3/latest/userguide/optimizing-cost.html)
