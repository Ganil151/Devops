# 🚨 Terraform State Corruption: Senior Pro-Tip Recovery Guide

## 📋 Table of Contents
1. [Understanding State Corruption](#understanding-state-corruption)
2. [Prevention Strategies](#prevention-strategies)
3. [Detection Methods](#detection-methods)
4. [Recovery Procedures](#recovery-procedures)
5. [Advanced Scenarios](#advanced-scenarios)
6. [Post-Incident Actions](#post-incident-actions)

---

## 🧠 Understanding State Corruption

### What is State Corruption?

Terraform state corruption occurs when the state file becomes inconsistent with reality, leading to:
- ❌ Terraform unable to plan or apply changes
- ❌ Resources shown as existing when they don't
- ❌ Drift between state and actual infrastructure
- ❌ Duplicate resource creation attempts
- ❌ Inability to destroy resources

### Common Causes

| Cause | Description | Prevention |
|-------|-------------|------------|
| **Concurrent Modifications** | Multiple users/pipelines running terraform simultaneously | Use state locking with DynamoDB |
| **Manual AWS Console Changes** | Resources modified outside Terraform | Implement policy-as-code, use SCPs |
| **Interrupted Operations** | Ctrl+C during apply, network failures | Use `-lock-timeout`, implement retries |
| **S3 Versioning Disabled** | State overwrites without backup | Enable S3 versioning on state bucket |
| **Corrupted JSON** | Invalid JSON in state file | Use S3 versioning, regular backups |
| **Force Unlock Misuse** | Breaking locks without understanding impact | Document proper unlock procedures |

---

## 🛡️ Prevention Strategies

### 1. Remote Backend with Locking

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Critical: Enable versioning on S3 bucket!
  }
}
```

### 2. S3 Bucket Configuration

```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state"
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for old versions
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
```

### 3. DynamoDB Lock Table

```hcl
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "Terraform State Lock"
    Environment = "global"
    Critical    = "true"
  }
}
```

### 4. CI/CD Pipeline Safeguards

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        run: terraform init
        
      - name: Terraform Validate
        run: terraform validate
        
      - name: Terraform Plan
        id: plan
        run: terraform plan -out=tfplan -lock-timeout=5m
        continue-on-error: true
        
      - name: Check for Lock Issues
        if: steps.plan.outcome == 'failure'
        run: |
          echo "::error::Terraform plan failed. Check for state lock issues."
          exit 1
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve tfplan -lock-timeout=5m
        
      - name: Backup State on Failure
        if: failure()
        run: |
          aws s3 cp s3://my-terraform-state/prod/terraform.tfstate \
            s3://my-terraform-state-backup/$(date +%Y%m%d-%H%M%S)-terraform.tfstate
```

---

## 🔍 Detection Methods

### 1. State Validation

```bash
# Check state file integrity
terraform state list

# Validate state against actual infrastructure
terraform plan -detailed-exitcode

# Exit codes:
# 0 = No changes
# 1 = Error
# 2 = Changes detected
```

### 2. State Inspection

```bash
# Show current state
terraform show

# Show specific resource
terraform state show aws_instance.web

# Check state file directly (S3)
aws s3 cp s3://my-terraform-state/prod/terraform.tfstate - | jq .

# Validate JSON structure
aws s3 cp s3://my-terraform-state/prod/terraform.tfstate - | jq empty
```

### 3. Drift Detection

```bash
# Detect drift from actual infrastructure
terraform plan -refresh-only

# Generate drift report
terraform plan -refresh-only -out=drift.tfplan
terraform show -json drift.tfplan | jq '.resource_changes[] | select(.change.actions != ["no-op"])'
```

### 4. Lock Status Check

```bash
# Check for active locks
aws dynamodb scan \
  --table-name terraform-state-lock \
  --filter-expression "attribute_exists(LockID)"

# Get lock details
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID": {"S": "my-terraform-state/prod/terraform.tfstate"}}'
```

---

## 🔧 Recovery Procedures

### Scenario 1: State Lock Timeout

**Symptoms:**
```
Error: Error acquiring the state lock
Lock Info:
  ID:        abc123-def456-ghi789
  Path:      my-terraform-state/prod/terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Version:   1.5.0
  Created:   2024-01-15 10:30:00 UTC
```

**Recovery Steps:**

```bash
# Step 1: Verify no one is actually running Terraform
# Contact the user shown in lock info

# Step 2: Check if process is still running
ps aux | grep terraform

# Step 3: If safe, force unlock
terraform force-unlock abc123-def456-ghi789

# Step 4: Verify unlock
terraform plan

# Step 5: Document incident
echo "$(date): Force unlocked state due to timeout" >> state-incidents.log
```

**Prevention:**
```hcl
# Use lock timeout in backend config
terraform {
  backend "s3" {
    # ... other config
    
    # Automatically release lock after 10 minutes
    skip_metadata_api_check = false
  }
}

# Or use in commands
terraform apply -lock-timeout=10m
```

---

### Scenario 2: Corrupted State File (Invalid JSON)

**Symptoms:**
```
Error: Failed to load state: error decoding state: invalid character
```

**Recovery Steps:**

```bash
# Step 1: Download current state
aws s3 cp s3://my-terraform-state/prod/terraform.tfstate ./corrupted-state.json

# Step 2: Validate JSON
jq empty corrupted-state.json
# If this fails, state is corrupted

# Step 3: List available versions
aws s3api list-object-versions \
  --bucket my-terraform-state \
  --prefix prod/terraform.tfstate \
  --query 'Versions[*].[VersionId,LastModified]' \
  --output table

# Step 4: Download previous version
aws s3api get-object \
  --bucket my-terraform-state \
  --key prod/terraform.tfstate \
  --version-id <VERSION_ID> \
  ./recovered-state.json

# Step 5: Validate recovered state
jq empty recovered-state.json

# Step 6: Restore state
aws s3 cp ./recovered-state.json s3://my-terraform-state/prod/terraform.tfstate

# Step 7: Verify recovery
terraform state list

# Step 8: Run plan to check for drift
terraform plan
```

---

### Scenario 3: Resource Exists in State but Not in AWS

**Symptoms:**
```
Error: Error reading EC2 Instance (i-1234567890abcdef0): InvalidInstanceID.NotFound
```

**Recovery Steps:**

```bash
# Step 1: Identify the missing resource
terraform state list | grep instance

# Step 2: Remove from state
terraform state rm aws_instance.web

# Step 3: Verify removal
terraform state list

# Step 4: Re-import if resource actually exists
# (Check AWS Console first)
terraform import aws_instance.web i-1234567890abcdef0

# Step 5: If resource doesn't exist, recreate
terraform apply

# Alternative: Use targeted refresh
terraform apply -refresh-only -target=aws_instance.web
```

---

### Scenario 4: Resource Exists in AWS but Not in State

**Symptoms:**
```
Error: A resource with the ID "vpc-12345678" already exists
```

**Recovery Steps:**

```bash
# Step 1: Identify the resource in AWS
aws ec2 describe-vpcs --vpc-ids vpc-12345678

# Step 2: Import into state
terraform import aws_vpc.main vpc-12345678

# Step 3: Verify import
terraform state show aws_vpc.main

# Step 4: Run plan to check configuration drift
terraform plan

# Step 5: Update code to match actual resource
# Edit your .tf files to match the imported resource

# Step 6: Verify no changes needed
terraform plan
# Should show: No changes. Infrastructure is up-to-date.
```

---

### Scenario 5: State File Completely Lost

**Symptoms:**
```
Error: Failed to get existing workspaces: S3 bucket does not exist
```

**Recovery Steps:**

```bash
# Step 1: Check S3 bucket exists
aws s3 ls s3://my-terraform-state/

# Step 2: If bucket exists, check for state file
aws s3 ls s3://my-terraform-state/prod/

# Step 3: If no state file, check versions
aws s3api list-object-versions \
  --bucket my-terraform-state \
  --prefix prod/terraform.tfstate

# Step 4: If versions exist, restore latest
aws s3api get-object \
  --bucket my-terraform-state \
  --key prod/terraform.tfstate \
  --version-id <LATEST_VERSION_ID> \
  ./restored-state.json

aws s3 cp ./restored-state.json s3://my-terraform-state/prod/terraform.tfstate

# Step 5: If no backups exist, rebuild state from scratch
# This is the nuclear option!

# 5a. Initialize new state
terraform init

# 5b. Import all existing resources
# Get list of all resources from AWS
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --output text

# 5c. Import each resource
terraform import aws_instance.web[0] i-1234567890abcdef0
terraform import aws_instance.web[1] i-0987654321fedcba0
# ... repeat for all resources

# 5d. Verify state
terraform plan
# Should show minimal or no changes
```

---

### Scenario 6: Duplicate Resources in State

**Symptoms:**
```
Error: Duplicate resource "aws_instance" configuration
```

**Recovery Steps:**

```bash
# Step 1: List all resources
terraform state list

# Step 2: Identify duplicates
terraform state list | sort | uniq -d

# Step 3: Show both resources
terraform state show 'aws_instance.web[0]'
terraform state show 'aws_instance.web[1]'

# Step 4: Determine which is correct
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Step 5: Remove incorrect entry
terraform state rm 'aws_instance.web[1]'

# Step 6: Verify
terraform state list
terraform plan
```

---

## 🎯 Advanced Scenarios

### Scenario 7: State Drift from Manual Changes

**Problem:** Someone made changes in AWS Console

**Detection:**
```bash
# Run refresh-only plan
terraform plan -refresh-only

# Output will show:
# ~ resource "aws_instance" "web" {
#     ~ instance_type = "t3.micro" -> "t3.small"
#   }
```

**Resolution Options:**

**Option A: Accept Drift (Update Code)**
```bash
# Update your .tf files to match reality
# Then run:
terraform plan
# Should show no changes
```

**Option B: Revert to Desired State**
```bash
# Apply your configuration to revert manual changes
terraform apply

# This will change instance back to t3.micro
```

**Option C: Selective Import**
```bash
# Remove from state
terraform state rm aws_instance.web

# Re-import with current configuration
terraform import aws_instance.web i-1234567890abcdef0

# Update code to match
# Edit main.tf to set instance_type = "t3.small"

# Verify
terraform plan
```

---

### Scenario 8: State File Too Large

**Symptoms:**
```
Error: state file too large (>100MB)
```

**Resolution:**

```bash
# Step 1: Analyze state size
terraform state list | wc -l

# Step 2: Identify large resources
terraform show -json | jq '.values.root_module.resources[] | {address: .address, size: (.values | tostring | length)}' | sort -k2 -n

# Step 3: Split into multiple states
# Create separate workspaces or backends for different components

# Example: Split networking and compute
# networking/backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# compute/backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "compute/terraform.tfstate"
    region = "us-east-1"
  }
}

# Step 4: Move resources between states
terraform state mv -state-out=../compute/terraform.tfstate aws_instance.web aws_instance.web
```

---

### Scenario 9: State Rollback Required

**Problem:** Applied bad changes, need to rollback

**Steps:**

```bash
# Step 1: List available state versions
aws s3api list-object-versions \
  --bucket my-terraform-state \
  --prefix prod/terraform.tfstate \
  --query 'Versions[*].[VersionId,LastModified,Size]' \
  --output table

# Step 2: Download previous version
aws s3api get-object \
  --bucket my-terraform-state \
  --key prod/terraform.tfstate \
  --version-id <PREVIOUS_VERSION_ID> \
  ./previous-state.json

# Step 3: Backup current state
aws s3 cp s3://my-terraform-state/prod/terraform.tfstate \
  s3://my-terraform-state-backup/$(date +%Y%m%d-%H%M%S)-before-rollback.json

# Step 4: Restore previous state
aws s3 cp ./previous-state.json s3://my-terraform-state/prod/terraform.tfstate

# Step 5: Verify rollback
terraform state list

# Step 6: Check what will change
terraform plan

# Step 7: If plan looks correct, apply
terraform apply

# Step 8: Document rollback
cat << EOF >> state-incidents.log
$(date): Rolled back state to version <PREVIOUS_VERSION_ID>
Reason: <REASON>
Performed by: <YOUR_NAME>
EOF
```

---

## 📊 State Surgery (Advanced)

### Manual State Editing (Last Resort!)

**⚠️ WARNING: Only do this if you know what you're doing!**

```bash
# Step 1: Backup current state
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).json

# Step 2: Pull state locally
terraform state pull > state.json

# Step 3: Edit state file
# Use jq for safe JSON manipulation
jq '.resources[] | select(.type == "aws_instance")' state.json

# Step 4: Make changes (example: fix resource address)
jq '.resources |= map(
  if .type == "aws_instance" and .name == "old_name" 
  then .name = "new_name" 
  else . 
  end
)' state.json > state-modified.json

# Step 5: Validate JSON
jq empty state-modified.json

# Step 6: Push modified state
terraform state push state-modified.json

# Step 7: Verify
terraform state list
terraform plan
```

---

## 🔐 Security Considerations

### State File Contains Secrets!

**What's in State:**
- Database passwords
- API keys
- Private keys
- Sensitive configuration

**Protection Measures:**

```hcl
# 1. Encrypt state at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
  }
}

# 2. Restrict access with IAM
data "aws_iam_policy_document" "state_bucket" {
  statement {
    sid    = "DenyUnencryptedObjectUploads"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    
    actions = ["s3:PutObject"]
    
    resources = ["${aws_s3_bucket.terraform_state.arn}/*"]
    
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}

# 3. Enable MFA delete
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state"
  
  # Enable MFA delete (must be done via AWS CLI)
  # aws s3api put-bucket-versioning \
  #   --bucket my-terraform-state \
  #   --versioning-configuration Status=Enabled,MFADelete=Enabled \
  #   --mfa "arn:aws:iam::123456789012:mfa/root-account-mfa-device 123456"
}
```

---

## 📋 Post-Incident Checklist

### After Recovering from State Corruption

- [ ] Document what happened in incident log
- [ ] Identify root cause
- [ ] Update runbooks with lessons learned
- [ ] Review and improve prevention measures
- [ ] Verify state integrity
- [ ] Run full terraform plan
- [ ] Check for drift
- [ ] Update team on incident
- [ ] Schedule post-mortem meeting
- [ ] Implement additional safeguards

### Incident Report Template

```markdown
# Terraform State Incident Report

**Date:** YYYY-MM-DD
**Time:** HH:MM UTC
**Severity:** Critical/High/Medium/Low
**Duration:** X hours

## Summary
Brief description of what happened

## Timeline
- HH:MM - Incident detected
- HH:MM - Investigation started
- HH:MM - Root cause identified
- HH:MM - Recovery initiated
- HH:MM - Service restored
- HH:MM - Verification completed

## Root Cause
Detailed explanation of what caused the issue

## Impact
- Resources affected: X
- Downtime: X minutes
- Data loss: Yes/No

## Resolution
Steps taken to resolve the issue

## Prevention
Measures implemented to prevent recurrence

## Action Items
- [ ] Action 1 (Owner: Name, Due: Date)
- [ ] Action 2 (Owner: Name, Due: Date)
```

---

## 🛠️ Useful Commands Reference

### State Management
```bash
# List all resources
terraform state list

# Show specific resource
terraform state show <resource_address>

# Move resource
terraform state mv <source> <destination>

# Remove resource
terraform state rm <resource_address>

# Pull state locally
terraform state pull > state.json

# Push state
terraform state push state.json

# Replace provider
terraform state replace-provider hashicorp/aws registry.terraform.io/hashicorp/aws
```

### State Backup
```bash
# Manual backup
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).json

# Automated backup script
#!/bin/bash
BACKUP_DIR="./state-backups"
mkdir -p $BACKUP_DIR
terraform state pull > $BACKUP_DIR/state-$(date +%Y%m%d-%H%M%S).json

# Keep only last 30 backups
ls -t $BACKUP_DIR/state-*.json | tail -n +31 | xargs rm -f
```

### S3 State Operations
```bash
# List state versions
aws s3api list-object-versions \
  --bucket my-terraform-state \
  --prefix prod/terraform.tfstate

# Download specific version
aws s3api get-object \
  --bucket my-terraform-state \
  --key prod/terraform.tfstate \
  --version-id <VERSION_ID> \
  output.json

# Copy state to backup bucket
aws s3 cp s3://my-terraform-state/prod/terraform.tfstate \
  s3://my-terraform-state-backup/$(date +%Y%m%d-%H%M%S).json
```

---

## 🎓 Best Practices Summary

### DO ✅
- ✅ Use remote backend with locking
- ✅ Enable S3 versioning
- ✅ Encrypt state at rest
- ✅ Regular state backups
- ✅ Use workspaces for environments
- ✅ Implement CI/CD with state checks
- ✅ Document state operations
- ✅ Use terraform import for existing resources
- ✅ Run terraform plan before apply
- ✅ Use lock timeouts

### DON'T ❌
- ❌ Edit state files manually (unless absolutely necessary)
- ❌ Commit state files to Git
- ❌ Share state files via email/Slack
- ❌ Run terraform without locking
- ❌ Force unlock without investigation
- ❌ Disable S3 versioning
- ❌ Store secrets in variables
- ❌ Run concurrent terraform operations
- ❌ Ignore drift warnings
- ❌ Skip state backups

---

## 📚 Additional Resources

- [Terraform State Documentation](https://www.terraform.io/docs/language/state/index.html)
- [Terraform Backend Configuration](https://www.terraform.io/docs/language/settings/backends/index.html)
- [AWS S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [State Locking](https://www.terraform.io/docs/language/state/locking.html)

---

**Remember:** State corruption is recoverable, but prevention is always better than cure!

**Last Updated:** 2024  
**Version:** 1.0  
**Maintained by:** Platform Engineering Team
