# AWS S3 Bucket - Terraform Module

Comprehensive Terraform module for creating and managing AWS S3 buckets with security best practices, lifecycle management, and IAM integration.

## Overview

Amazon S3 (Simple Storage Service) is an object storage service offering industry-leading scalability, data availability, security, and performance. This module provides a production-ready S3 bucket configuration with:

- ✅ **Versioning** - Track object changes over time
- ✅ **Encryption** - Server-side encryption with AES256
- ✅ **Public Access Block** - Prevent accidental public exposure
- ✅ **Lifecycle Management** - Automated tier transitions to reduce costs
- ✅ **IAM Integration** - Pre-configured roles for EC2 access
- ✅ **Unique Naming** - Random suffix for bucket name uniqueness

## When to Use S3

```yaml
Use Cases:
  Static Content:
    - Website hosting
    - Media files (images, videos)
    - Downloads and archives
  
  Application Data:
    - Backup and disaster recovery
    - Log file storage
    - Application artifacts
  
  Data Lake:
    - Big data analytics
    - Machine learning datasets
    - Data warehousing
  
  DevOps:
    - Terraform state files
    - CI/CD artifacts
    - Configuration files
```

## S3 Storage Classes

```yaml
# Standard - Frequent Access
Standard:
  Durability: 99.999999999% (11 9's)
  Availability: 99.99%
  Use Case: Frequently accessed data
  Retrieval: Immediate, no fees
  Cost: Highest storage, lowest retrieval

# Standard-IA - Infrequent Access
Standard-IA:
  Durability: 99.999999999%
  Availability: 99.9%
  Use Case: Long-lived, infrequently accessed data
  Retrieval: Immediate, per-GB fee
  Cost: Lower storage, higher retrieval
  Minimum: 30 days storage

# One Zone-IA
One-Zone-IA:
  Durability: 99.999999999% (single AZ)
  Availability: 99.5%
  Use Case: Recreatable, infrequent access
  Cost: 20% less than Standard-IA
  Minimum: 30 days storage

# Glacier - Archive
Glacier:
  Durability: 99.999999999%
  Use Case: Long-term archive
  Retrieval: Minutes to hours
  Cost: Very low storage
  Minimum: 90 days storage
  
# Glacier Deep Archive
Deep-Archive:
  Durability: 99.999999999%
  Use Case: Compliance, long-term retention
  Retrieval: 12+ hours
  Cost: Lowest storage class
  Minimum: 180 days storage
```

## Module Files

### [main.tf](file:///home/ganil/Documents/Devops/Cloud_Computing/Beginner-Level/02-AWS-Basics/AWS/s3-bucket/main.tf)

Main Terraform configuration creating:
- S3 bucket with unique naming
- Versioning configuration
- Server-side encryption (AES256)
- Public access block (all disabled)
- Lifecycle rules for cost optimization
- IAM role for EC2 instances
- IAM instance profile
- IAM policy for S3 access

### [variables.tf](file:///home/ganil/Documents/Devops/Cloud_Computing/Beginner-Level/02-AWS-Basics/AWS/s3-bucket/variables.tf)

Configurable variables:
- `project_name` - Project identifier (required)
- `environment` - dev/staging/production
- `aws_region` - AWS region for deployment
- `enable_versioning` - Toggle versioning
- `enable_encryption` - Toggle encryption
- `lifecycle_enabled` - Toggle lifecycle rules
- Transition timing configurations
- Custom tags

### [outputs.tf](file:///home/ganil/Documents/Devops/Cloud_Computing/Beginner-Level/02-AWS-Basics/AWS/s3-bucket/outputs.tf)

Exported values:
- Bucket ID, ARN, domain names
- IAM role and instance profile details
- Region and hosted zone information

## Prerequisites

```bash
# AWS CLI installed and configured
aws --version
aws configure

# Terraform installed
terraform --version

# AWS credentials configured
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## Module Usage

### Basic Usage

```hcl
module "s3_bucket" {
  source = "./s3-bucket"
  
  project_name = "myproject"
  environment  = "production"
  aws_region   = "us-east-1"
}
```

### Advanced Usage

```hcl
module "s3_bucket" {
  source = "./s3-bucket"
  
  project_name = "myproject"
  environment  = "production"
  aws_region   = "us-west-2"
  
  # Versioning and encryption
  enable_versioning  = true
  enable_encryption  = true
  
  # Lifecycle configuration
  lifecycle_enabled                  = true
  transition_to_ia_days             = 30
  transition_to_glacier_days        = 90
  transition_to_deep_archive_days   = 365
  noncurrent_version_expiration_days = 90
  
  # Additional tags
  tags = {
    Team        = "DevOps"
    CostCenter  = "Engineering"
    Compliance  = "HIPAA"
  }
}

# Output bucket information
output "bucket_name" {
  value = module.s3_bucket.bucket_id
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}
```

### Deploy the Module

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan -var="project_name=myproject"

# Apply configuration
terraform apply -var="project_name=myproject"

# Destroy resources
terraform destroy -var="project_name=myproject"
```

## S3 Operations with AWS CLI

### Bucket Operations

```bash
# List all buckets
aws s3 ls

# Create bucket
aws s3 mb s3://my-bucket-name --region us-east-1

# Remove empty bucket
aws s3 rb s3://my-bucket-name

# Remove bucket with contents
aws s3 rb s3://my-bucket-name --force

# Get bucket location
aws s3api get-bucket-location --bucket my-bucket-name
```

### Object Operations

```bash
# Upload file
aws s3 cp file.txt s3://my-bucket-name/

# Upload with metadata
aws s3 cp file.txt s3://my-bucket-name/ \
  --metadata "key1=value1,key2=value2"

# Download file
aws s3 cp s3://my-bucket-name/file.txt ./

# List objects
aws s3 ls s3://my-bucket-name/

# List with details
aws s3 ls s3://my-bucket-name/ --recursive --human-readable

# Delete object
aws s3 rm s3://my-bucket-name/file.txt

# Delete multiple objects
aws s3 rm s3://my-bucket-name/ --recursive
```

### Sync Operations

```bash
# Sync local directory to S3
aws s3 sync ./local-folder s3://my-bucket-name/folder/

# Sync S3 to local (download)
aws s3 sync s3://my-bucket-name/folder/ ./local-folder

# Sync with delete (remove files not in source)
aws s3 sync ./local-folder s3://my-bucket-name/ --delete

# Exclude files
aws s3 sync ./local-folder s3://my-bucket-name/ \
  --exclude "*.tmp" --exclude ".git/*"
```

### Versioning

```bash
# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-bucket-name \
  --versioning-configuration Status=Enabled

# Check versioning status
aws s3api get-bucket-versioning --bucket my-bucket-name

# List object versions
aws s3api list-object-versions --bucket my-bucket-name

# Download specific version
aws s3api get-object \
  --bucket my-bucket-name \
  --key file.txt \
  --version-id <version-id> \
  output.txt
```

### Encryption

```bash
# Enable default encryption
aws s3api put-bucket-encryption \
  --bucket my-bucket-name \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Check encryption configuration
aws s3api get-bucket-encryption --bucket my-bucket-name

# Upload with encryption
aws s3 cp file.txt s3://my-bucket-name/ \
  --server-side-encryption AES256
```

## Lifecycle Management

The module includes automated lifecycle rules:

```yaml
Lifecycle Rules:
  Day 0-29:
    Storage: STANDARD
    Cost: High storage, low retrieval
  
  Day 30-89:
    Storage: STANDARD_IA
    Savings: ~50% storage cost
  
  Day 90-364:
    Storage: GLACIER
    Savings: ~80% storage cost
  
  Day 365+:
    Storage: DEEP_ARCHIVE
    Savings: ~95% storage cost
  
  Noncurrent Versions:
    Action: Delete after 90 days
    Purpose: Cost control
```

### Custom Lifecycle Policy

```bash
# Create lifecycle configuration file
cat > lifecycle.json << 'EOF'
{
  "Rules": [
    {
      "Id": "DeleteOldLogs",
      "Status": "Enabled",
      "Prefix": "logs/",
      "Expiration": {
        "Days": 30
      }
    },
    {
      "Id": "ArchiveBackups",
      "Status": "Enabled",
      "Prefix": "backups/",
      "Transitions": [
        {
          "Days": 7,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
EOF

# Apply lifecycle configuration
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket-name \
  --lifecycle-configuration file://lifecycle.json

# View lifecycle configuration
aws s3api get-bucket-lifecycle-configuration \
  --bucket my-bucket-name
```

## Security Best Practices

### 1. Block Public Access

```bash
# Block all public access (recommended)
aws s3api put-public-access-block \
  --bucket my-bucket-name \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Verify settings
aws s3api get-public-access-block --bucket my-bucket-name
```

### 2. Enable Encryption

```hcl
# In Terraform (already configured in this module)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.project_register.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}
```

### 3. Enable Versioning

Protects against accidental deletion and overwrites:

```bash
aws s3api put-bucket-versioning \
  --bucket my-bucket-name \
  --versioning-configuration Status=Enabled
```

### 4. Enable Access Logging

```bash
# Create logging bucket first
aws s3 mb s3://my-bucket-logs

# Enable logging
aws s3api put-bucket-logging \
  --bucket my-bucket-name \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "my-bucket-logs",
      "TargetPrefix": "access-logs/"
    }
  }'
```

## IAM Integration

The module creates an IAM role that EC2 instances can assume:

```hcl
# Attach instance profile to EC2
resource "aws_instance" "example" {
  ami                  = "ami-xxxxx"
  instance_type        = "t2.micro"
  iam_instance_profile = module.s3_bucket.iam_instance_profile_name
  
  # Instance can now access S3 without credentials
}
```

### From EC2 Instance

```bash
# No credentials needed - uses instance profile
aws s3 ls s3://my-bucket-name/
aws s3 cp file.txt s3://my-bucket-name/
```

## Cost Optimization Tips

```yaml
Strategies:
  1. Use Lifecycle Policies:
    - Transition old data to cheaper storage classes
    - Delete unnecessary objects automatically
  
  2. Enable Intelligent-Tiering:
    - Automatic cost optimization
    - No retrieval fees
    - Small monthly monitoring fee
  
  3. Compress Data:
    - Reduce storage costs
    - Faster transfers
    - Lower bandwidth costs
  
  4. Delete Incomplete Uploads:
    - Clean up failed multipart uploads
    - Use lifecycle rules
  
  5. Monitor Usage:
    - S3 Storage Lens
    - Cost allocation tags
    - AWS Cost Explorer
```

## Troubleshooting

### Access Denied Errors

```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket my-bucket-name

# Check IAM permissions
aws iam get-user-policy --user-name myuser --policy-name mypolicy

# Check public access block
aws s3api get-public-access-block --bucket my-bucket-name
```

### Bucket Name Already Exists

S3 bucket names are globally unique. Solutions:
1. Choose a different name
2. Use random suffix (this module does this automatically)
3. Delete the existing bucket if you own it

### Versioning Issues

```bash
# Check if versioning is enabled
aws s3api get-bucket-versioning --bucket my-bucket-name

# Suspend versioning (doesn't delete versions)
aws s3api put-bucket-versioning \
  --bucket my-bucket-name \
  --versioning-configuration Status=Suspended
```

## Related Documentation

- [S3 Bucket Policies](file:///home/ganil/Documents/Devops/Cloud_Computing/Beginner-Level/02-AWS-Basics/AWS/s3-bucket/s3-bucket-policies.md)
- [S3 Static Website Hosting](file:///home/ganil/Documents/Devops/Cloud_Computing/Beginner-Level/02-AWS-Basics/AWS/s3-bucket/s3-static-website.md)
- [Storage Fundamentals](file:///home/ganil/Documents/Devops/Cloud_Computing/Beginner-Level/06-Storage-Fundamentals/README.md)
- [AWS CLI Commands](file:///home/ganil/Documents/Devops/Cloud_Computing/Beginner-Level/02-AWS-Basics/AWS/AWS%20CLI%20Commands.md)

## Additional Resources

- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [S3 Pricing](https://aws.amazon.com/s3/pricing/)
- [Terraform AWS S3 Bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
