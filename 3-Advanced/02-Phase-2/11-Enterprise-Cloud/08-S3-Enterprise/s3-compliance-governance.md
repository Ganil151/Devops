# AWS S3 Compliance & Governance

Enterprise compliance and governance strategies for S3 including Object Lock, retention policies, audit logging, and regulatory compliance (HIPAA, GDPR, SOC 2, PCI DSS).

## Compliance Framework

```yaml
Key Requirements:
  Data Retention:
    - Minimum retention periods
    - Maximum retention periods
    - Immutability (WORM)
    - Legal holds
  
  Access Control:
    - Least privilege
    - Role-based access
    - Audit trails
    - MFA enforcement
  
  Encryption:
    - At rest
    - In transit
    - Key management
    - Rotation policies
  
  Auditing:
    - Activity logging
    - Access monitoring
    - Anomaly detection
    - Reporting
```

## S3 Object Lock (WORM)

Write Once Read Many storage for compliance:

### Compliance Mode

```hcl
# Bucket with Object Lock
resource "aws_s3_bucket" "compliance" {
  bucket = "compliance-data-bucket"
  
  object_lock_enabled = true
  
  tags = {
    Compliance = "SEC17a-4"
    DataClass  = "Financial"
  }
}

# Versioning required
resource "aws_s3_bucket_versioning" "compliance" {
  bucket = aws_s3_bucket.compliance.id
  
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Enabled"
  }
}

# Object Lock configuration - Compliance Mode
resource "aws_s3_bucket_object_lock_configuration" "compliance" {
  bucket = aws_s3_bucket.compliance.id
  
  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 2555  # 7 years for SEC 17a-4
    }
  }
}
```

**Compliance Mode:** - Objects cannot be deleted or overwritten by any user (including root)
- Retention settings cannot be shortened
- Cannot be disabled once set
- Suitable for strict regulatory requirements

### Governance Mode

```hcl
# Governance mode - allows override with special permissions
resource "aws_s3_bucket_object_lock_configuration" "governance" {
  bucket = aws_s3_bucket.data.id
  
  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 365
    }
  }
}

# IAM policy to override retention
resource "aws_iam_policy" "override_governance" {
  name = "S3GovernanceOverride"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:BypassGovernanceRetention",
          "s3:PutObjectRetention"
        ]
        Resource = "${aws_s3_bucket.data.arn}/*"
      }
    ]
  })
}
```

### Legal Holds

```bash
# Apply legal hold
aws s3api put-object-legal-hold \
  --bucket compliance-bucket \
  --key sensitive-document.pdf \
  --legal-hold Status=ON

# Check legal hold status
aws s3api get-object-legal-hold \
  --bucket compliance-bucket \
  --key sensitive-document.pdf

# Remove legal hold (requires permission)
aws s3api put-object-legal-hold \
  --bucket compliance-bucket \
  --key sensitive-document.pdf \
  --legal-hold Status=OFF
```

## Vault Lock

Enforce compliance controls on Glacier vaults:

```bash
# Initiate vault lock
aws glacier initiate-vault-lock \
  --account-id - \
  --vault-name compliance-vault \
  --policy '{
    "Version":"2012-10-17",
    "Statement":[
      {
        "Effect":"Deny",
        "Principal":"*",
        "Action":"glacier:DeleteArchive",
        "Resource":"arn:aws:glacier:us-east-1:123456789012:vaults/compliance-vault",
        "Condition":{
          "NumericLessThan":{
            "glacier:ArchiveAgeInDays":"2555"
          }
        }
      }
    ]
  }'

# Complete vault lock (24-hour window)
aws glacier complete-vault-lock \
  --account-id - \
  --vault-name compliance-vault \
  --lock-id exampleLockId
```

## Regulatory Compliance

### HIPAA Compliance

```yaml
Requirements:
  - Business Associate Agreement (BAA) with AWS
  - Encryption at rest and in transit
  - Access logging and monitoring
  - Audit trail for PHI access
  - Access controls and authentication
  - Data backup and recovery

Implementation:
  S3 Configuration:
    - Enable default encryption (KMS)
    - Enable versioning
    - Configure Object Lock
    - Enable CloudTrail data events
    - Configure access logging
    
  Access Control:
    - VPC Endpoints only
    - IAM least privilege
    - MFA for sensitive operations
    - Regular access reviews
    
  Monitoring:
    - CloudTrail enabled
    - S3 Access Logs
    - CloudWatch alarms
    - GuardDuty for threats
```

```hcl
# HIPAA-compliant S3 bucket
resource "aws_s3_bucket" "hipaa" {
  bucket = "hipaa-phi-bucket"
  
  tags = {
    Compliance    = "HIPAA"
    DataClass     = "PHI"
    Encryption    = "Required"
    BAA           = "Signed"
  }
}

# Mandatory encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "hipaa" {
  bucket = aws_s3_bucket.hipaa.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.hipaa.arn
    }
    bucket_key_enabled = true
  }
}

# Versioning for audit trail
resource "aws_s3_bucket_versioning" "hipaa" {
  bucket = aws_s3_bucket.hipaa.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Object Lock for data integrity
resource "aws_s3_bucket_object_lock_configuration" "hipaa" {
  bucket = aws_s3_bucket.hipaa.id
  
  rule {
    default_retention {
      mode = "COMPLIANCE"
      years = 6  # HIPAA requires 6 years
    }
  }
}

# Access logging
resource "aws_s3_bucket_logging" "hipaa" {
  bucket = aws_s3_bucket.hipaa.id
  
  target_bucket = aws_s3_bucket.audit_logs.id
  target_prefix = "s3-access-logs/hipaa/"
}

# VPC endpoint only access
resource "aws_s3_bucket_policy" "hipaa_vpc_only" {
  bucket = aws_s3_bucket.hipaa.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyNonVPCAccess"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.hipaa.arn,
          "${aws_s3_bucket.hipaa.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.s3.id
          }
        }
      },
      {
        Sid    = "RequireEncryptedTransport"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.hipaa.arn,
          "${aws_s3_bucket.hipaa.arn}/*"
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

### GDPR Compliance

```yaml
Requirements:
  - Data residency controls
  - Right to erasure (deletion)
  - Data portability
  - Breach notification (72 hours)
  - Consent management
  - Data minimization

Implementation:
  Region Selection:
    - EU regions only (eu-west-1, eu-central-1)
    - No cross-region replication outside EU
    - CloudFront with EU edge locations
  
  Data Management:
    - Tag personal data
    - Automated deletion workflows
    - Export capabilities
    - Encryption mandatory
  
  Access Controls:
    - Purpose-based access
    - Audit all personal data access
    - Consent tracking
    - Data subject request handling
```

```hcl
# GDPR-compliant bucket
resource "aws_s3_bucket" "gdpr" {
  bucket   = "gdpr-customer-data"
  provider = aws.eu_west_1  # EU region
  
  tags = {
    Compliance    = "GDPR"
    DataClass     = "PersonalData"
    Region        = "EU"
    DataSubjects  = "Customers"
  }
}

# Lifecycle for data minimization
resource "aws_s3_bucket_lifecycle_configuration" "gdpr" {
  bucket = aws_s3_bucket.gdpr.id
  
  rule {
    id     = "DeleteInactiveData"
    status = "Enabled"
    
    filter {
      tag {
        key   = "DataRetention"
        value = "Standard"
      }
    }
    
    expiration {
      days = 365  # Delete after 1 year of inactivity
    }
  }
  
  rule {
    id     = "DeleteMarketingConsent"
    status = "Enabled"
    
    filter {
      and {
        prefix = "marketing/"
        tags = {
          ConsentExpired = "true"
        }
      }
    }
    
    expiration {
      days = 1  # Delete immediately when consent expires
    }
  }
}

# Encryption required
resource "aws_s3_bucket_server_side_encryption_configuration" "gdpr" {
  bucket = aws_s3_bucket.gdpr.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.gdpr.arn
    }
  }
}
```

### SOC 2 Compliance

```yaml
Requirements:
  Security:
    - Access controls
    - Encryption
    - Network security
    - Vulnerability management
  
  Availability:
    - Monitoring
    - Incident response
    - Disaster recovery
    - Capacity planning
  
  Processing Integrity:
    - Data validation
    - Error handling
    - Quality assurance
  
  Confidentiality:
    - Data classification
    - Access restrictions
    - Non-disclosure
  
  Privacy:
    - Consent management
    - Data retention
    - Disclosure controls
```

```hcl
# SOC 2 controls
resource "aws_s3_bucket" "soc2" {
  bucket = "soc2-controlled-data"
  
  tags = {
    Compliance   = "SOC2"
    Criticality  = "High"
    DataClass    = "Confidential"
  }
}

# Comprehensive logging
resource "aws_s3_bucket_logging" "soc2" {
  bucket = aws_s3_bucket.soc2.id
  
  target_bucket = aws_s3_bucket.audit_logs.id
  target_prefix = "soc2/access-logs/"
}

# CloudTrail data events
resource "aws_cloudtrail" "soc2" {
  name           = "soc2-trail"
  s3_bucket_name = aws_s3_bucket.cloudtrail.id
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type = "AWS::S3::Object"
      values = ["${aws_s3_bucket.soc2.arn}/*"]
    }
  }
}

# Access controls
resource "aws_s3_bucket_policy" "soc2" {
  bucket = aws_s3_bucket.soc2.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceSecureTransport"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = "${aws_s3_bucket.soc2.arn}/*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "EnforceEncryption"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.soc2.arn}/*"
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

### PCI DSS

```yaml
Requirements:
  Network Security:
    - Network segmentation
    - Firewall configuration
    - Secure channels
  
  Data Protection:
    - Encryption of cardholder data
    - Truncation/masking
    - Secure deletion
    - Retention limits
  
  Access Control:
    - Unique IDs
    - Access restrictions
    - Two-factor authentication
    - Logging and monitoring
  
  Testing:
    - Vulnerability scans
    - Penetration testing
    - Log reviews
```

```hcl
# PCI DSS-compliant bucket
resource "aws_s3_bucket" "pci" {
  bucket = "pci-cardholder-data"
  
  tags = {
    Compliance = "PCI-DSS"
    DataClass  = "CardholderData"
    Level      = "1"
  }
}

# Strict retention
resource "aws_s3_bucket_lifecycle_configuration" "pci" {
  bucket = aws_s3_bucket.pci.id
  
  rule {
    id     = "EnforceRetention"
    status = "Enabled"
    
    # Delete after retention period
    expiration {
      days = 90  # PCI DSS allows 90 days for logs
    }
  }
}

# Network isolation
resource "aws_s3_bucket_policy" "pci_isolated" {
  bucket = aws_s3_bucket.pci.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RestrictToCardholder Environment"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.pci.arn,
          "${aws_s3_bucket.pci.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:SourceVpc" = aws_vpc.cardholder_data.id
          }
        }
      }
    ]
  })
}
```

## Audit & Compliance Reporting

### CloudTrail Integration

```hcl
# Dedicated audit trail
resource "aws_cloudtrail" "audit" {
  name                          = "compliance-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true  # Integrity checking
  
  event_selector {
    read_write_type = "All"
    
    data_resource {
      type = "AWS::S3::Object"
      values = [
        "${aws_s3_bucket.compliance.arn}/*",
        "${aws_s3_bucket.hipaa.arn}/*",
        "${aws_s3_bucket.pci.arn}/*"
      ]
    }
  }
  
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
}

# Tamper-proof CloudTrail bucket
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "DenyDeletion"
        Effect = "Deny"
        Principal = "*"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
      }
    ]
  })
}
```

### Compliance Reports

```python
import boto3
from datetime import datetime, timedelta

s3 = boto3.client('s3')
cloudtrail = boto3.client('cloudtrail')

def generate_compliance_report(bucket, start_date, end_date):
    """
    Generate compliance report for S3 bucket
    """
    report = {
        'bucket': bucket,
        'period': f"{start_date} to {end_date}",
        'access_events': [],
        'violations': []
    }
    
    # Query CloudTrail
    response = cloudtrail.lookup_events(
        LookupAttributes=[
            {
                'AttributeKey': 'ResourceName',
                'AttributeValue': bucket
            }
        ],
        StartTime=start_date,
        EndTime=end_date
    )
    
    for event in response['Events']:
        event_name = event['EventName']
        username = event.get('Username', 'Unknown')
        timestamp = event['EventTime']
        
        # Check for violations
        if event_name == 'DeleteObject':
            report['violations'].append({
                'type': 'Unauthorized Deletion',
                'user': username,
                'time': str(timestamp)
            })
        
        report['access_events'].append({
            'event': event_name,
            'user': username,
            'time': str(timestamp)
        })
    
    return report

# Generate report
start = datetime.now() - timedelta(days=30)
end = datetime.now()
report = generate_compliance_report('compliance-bucket', start, end)

print(f"Total Access Events: {len(report['access_events'])}")
print(f"Violations: {len(report['violations'])}")
```

## Compliance Checklist

```yaml
Object Lock:
  ✓ Compliance mode for immutability
  ✓ Retention periods configured
  ✓ Legal holds documented
  ✓ Vault Lock for Glacier

Encryption:
  ✓ Default encryption enabled
  ✓ KMS keys managed
  ✓ Key rotation enabled
  ✓ TLS enforced

Access Control:
  ✓ Least privilege IAM
  ✓ MFA for sensitive operations
  ✓ VPC endpoints configured
  ✓ Regular access reviews

Auditing:
  ✓ CloudTrail data events
  ✓ S3 access logging
  ✓ Log retention configured
  ✓ Integrity validation

Data Management:
  ✓ Retention policies
  ✓ Deletion workflows
  ✓ Data classification
  ✓ Lifecycle rules

Monitoring:
  ✓ Anomaly detection
  ✓ Alert configuration
  ✓ Compliance reports
  ✓ Regular audits
```

## Additional Resources

- [S3 Enterprise README](file:///home/ganil/Documents/Devops/Cloud_Computing/Advanced-Level/08-S3-Enterprise/README.md)
- [AWS Compliance](https://aws.amazon.com/compliance/)
- [S3 Object Lock](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html)
- [Regulatory Compliance](https://docs.aws.amazon.com/whitepapers/latest/navigating-gdpr-compliance/navigating-gdpr-compliance.html)
