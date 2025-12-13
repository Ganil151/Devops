# Cloud Storage

Comprehensive guide to cloud storage types, services, and best practices across cloud platforms.

## Storage Types

### Object Storage
```yaml
Characteristics:
  - Flat namespace structure
  - REST API access
  - Unlimited scalability
  - Metadata support
  - Versioning capabilities

Use Cases:
  - Static websites
  - Data archiving
  - Content distribution
  - Backup and recovery
  - Big data analytics

Examples:
  - AWS S3
  - Azure Blob Storage
  - Google Cloud Storage
```

### Block Storage
```yaml
Characteristics:
  - Raw block-level storage
  - High IOPS performance
  - Attached to compute instances
  - Snapshot capabilities
  - Encryption support

Use Cases:
  - Database storage
  - File systems
  - Boot volumes
  - High-performance applications

Examples:
  - AWS EBS
  - Azure Managed Disks
  - Google Persistent Disks
```

### File Storage
```yaml
Characteristics:
  - Network-attached storage
  - POSIX-compliant
  - Shared access
  - Hierarchical structure
  - Concurrent access

Use Cases:
  - Shared application data
  - Content repositories
  - Home directories
  - Legacy applications

Examples:
  - AWS EFS
  - Azure Files
  - Google Filestore
```

## AWS Storage Services

### Amazon S3
```bash
# Create S3 bucket
aws s3 mb s3://my-bucket-name --region us-east-1

# Upload file
aws s3 cp file.txt s3://my-bucket-name/

# Sync directory
aws s3 sync ./local-folder s3://my-bucket-name/folder/

# Set bucket policy
aws s3api put-bucket-policy \
  --bucket my-bucket-name \
  --policy file://bucket-policy.json

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-bucket-name \
  --versioning-configuration Status=Enabled
```

### S3 Storage Classes
```yaml
Standard:
  - Frequent access
  - 99.999999999% durability
  - Low latency

Standard-IA:
  - Infrequent access
  - Lower storage cost
  - Retrieval charges

One Zone-IA:
  - Single AZ storage
  - 20% less cost than Standard-IA
  - Lower availability

Glacier:
  - Long-term archival
  - Minutes to hours retrieval
  - Very low cost

Glacier Deep Archive:
  - Lowest cost storage
  - 12+ hours retrieval
  - Compliance archiving
```

### Amazon EBS
```bash
# Create EBS volume
aws ec2 create-volume \
  --size 100 \
  --volume-type gp3 \
  --availability-zone us-east-1a

# Attach volume to instance
aws ec2 attach-volume \
  --volume-id vol-12345678 \
  --instance-id i-12345678 \
  --device /dev/sdf

# Create snapshot
aws ec2 create-snapshot \
  --volume-id vol-12345678 \
  --description "Daily backup"
```

## Azure Storage Services

### Azure Blob Storage
```bash
# Create storage account
az storage account create \
  --name mystorageaccount \
  --resource-group myRG \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name mycontainer \
  --account-name mystorageaccount

# Upload blob
az storage blob upload \
  --file myfile.txt \
  --container-name mycontainer \
  --name myblob \
  --account-name mystorageaccount
```

### Azure Storage Tiers
```yaml
Hot Tier:
  - Frequent access
  - Higher storage cost
  - Lower access cost

Cool Tier:
  - Infrequent access (30+ days)
  - Lower storage cost
  - Higher access cost

Archive Tier:
  - Rare access (180+ days)
  - Lowest storage cost
  - Highest access cost
  - Rehydration required
```

### Azure Managed Disks
```bash
# Create managed disk
az disk create \
  --resource-group myRG \
  --name myDisk \
  --size-gb 128 \
  --sku Premium_LRS

# Attach disk to VM
az vm disk attach \
  --resource-group myRG \
  --vm-name myVM \
  --name myDisk
```

## Google Cloud Storage

### Cloud Storage
```bash
# Create bucket
gsutil mb gs://my-bucket-name

# Upload file
gsutil cp file.txt gs://my-bucket-name/

# Set bucket lifecycle
gsutil lifecycle set lifecycle.json gs://my-bucket-name

# Enable versioning
gsutil versioning set on gs://my-bucket-name
```

### Storage Classes
```yaml
Standard:
  - Frequent access
  - No minimum storage duration
  - Best for hot data

Nearline:
  - Monthly access
  - 30-day minimum storage
  - Backup and archival

Coldline:
  - Quarterly access
  - 90-day minimum storage
  - Disaster recovery

Archive:
  - Annual access
  - 365-day minimum storage
  - Long-term preservation
```

### Persistent Disks
```bash
# Create persistent disk
gcloud compute disks create my-disk \
  --size=100GB \
  --zone=us-central1-a \
  --type=pd-ssd

# Attach disk to instance
gcloud compute instances attach-disk my-instance \
  --disk=my-disk \
  --zone=us-central1-a
```

## Storage Security

### Encryption
```yaml
Encryption at Rest:
  - Server-side encryption
  - Customer-managed keys
  - Hardware security modules
  - Key rotation policies

Encryption in Transit:
  - HTTPS/TLS protocols
  - VPN connections
  - Private endpoints
  - Certificate management

Access Control:
  - IAM policies
  - Bucket policies
  - Access control lists
  - Signed URLs
```

### Data Protection
```bash
# AWS S3 Cross-Region Replication
aws s3api put-bucket-replication \
  --bucket source-bucket \
  --replication-configuration file://replication.json

# Azure Blob Storage Replication
az storage account create \
  --name mystorageaccount \
  --replication-type GRS

# GCP Multi-Regional Storage
gsutil mb -c MULTI_REGIONAL gs://my-global-bucket
```

## Performance Optimization

### Throughput Optimization
```yaml
Parallel Operations:
  - Multi-part uploads
  - Concurrent transfers
  - Thread pooling
  - Bandwidth allocation

Caching Strategies:
  - CDN integration
  - Local caching
  - Edge locations
  - Cache invalidation

Network Optimization:
  - Transfer acceleration
  - Direct connections
  - Regional proximity
  - Compression
```

### Cost Optimization
```yaml
Lifecycle Policies:
  - Automatic tier transitions
  - Deletion policies
  - Version management
  - Incomplete upload cleanup

Storage Analysis:
  - Usage patterns
  - Access frequency
  - Cost monitoring
  - Right-sizing recommendations

Data Deduplication:
  - Eliminate duplicates
  - Compression algorithms
  - Delta synchronization
  - Incremental backups
```

## Backup and Recovery

### Backup Strategies
```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
BUCKET="backup-bucket"

# Database backup
mysqldump -u user -p database > db_backup_$DATE.sql
aws s3 cp db_backup_$DATE.sql s3://$BUCKET/database/

# File system backup
tar -czf files_backup_$DATE.tar.gz /important/files
aws s3 cp files_backup_$DATE.tar.gz s3://$BUCKET/files/

# Cleanup old backups
aws s3 ls s3://$BUCKET/ | grep backup | head -n -7 | awk '{print $4}' | \
xargs -I {} aws s3 rm s3://$BUCKET/{}
```

### Disaster Recovery
```yaml
RTO (Recovery Time Objective):
  - Maximum acceptable downtime
  - Recovery procedures
  - Automation requirements
  - Testing schedules

RPO (Recovery Point Objective):
  - Maximum data loss acceptable
  - Backup frequency
  - Replication strategies
  - Point-in-time recovery

Cross-Region Replication:
  - Geographic distribution
  - Automatic failover
  - Data consistency
  - Compliance requirements
```

This comprehensive guide covers cloud storage fundamentals, services, and best practices across major cloud platforms.