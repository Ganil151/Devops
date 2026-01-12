# Day 4 Tasks: Terraform Remote State Management

## Learning Objectives
- Configure Terraform S3 backend for remote state storage
- Implement state locking with DynamoDB
- Understand common backend configuration errors
- Practice team collaboration scenarios

## Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed (version >= 1.0)
- Basic understanding of Terraform state

## Task 1: Setup AWS Resources (15 minutes)

### 1.1 Create S3 Bucket
Create an S3 bucket with a unique name for storing Terraform state:
```bash
aws s3 mb s3://[your-name]-terraform-state-bucket-$(date +%s) --region us-east-1
```

### 1.2 Create DynamoDB Table
Create a DynamoDB table for state locking:
```bash
aws dynamodb create-table \
  --table-name [your-name]-terraform-lock-table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

**Verification**: Confirm both resources are created successfully.

## Task 2: Configure Terraform Backend (20 minutes)

### 2.1 Create main.tf
Create a `main.tf` file with the following requirements:
- Configure S3 backend with your bucket name
- Use key path: `lab/terraform.tfstate`
- Enable encryption
- Configure state locking with your DynamoDB table
- Set AWS provider version constraint to `~> 6.0`
- Add minimum Terraform version requirement

### 2.2 Add Sample Resources
Include these resources to test state management:
- Random ID generator for unique naming
- S3 bucket with versioning enabled
- S3 bucket public access block

### 2.3 Initialize and Apply
```bash
terraform init
terraform plan
terraform apply
```

**Expected Outcome**: Resources created and state stored in S3.

## Task 3: Error Troubleshooting (10 minutes)

### 3.1 Reproduce the Error
Temporarily add `use_lockfile = true` to your backend configuration and run `terraform init`.

**Questions**:
1. What error message do you receive?
2. Why is this argument invalid?
3. What is the correct way to enable state locking?

### 3.2 Fix the Configuration
Remove the invalid argument and reinitialize.

## Task 4: State Management Operations (15 minutes)

### 4.1 State Inspection
```bash
terraform show
terraform state list
```

### 4.2 Remote State Verification
- Check your S3 bucket for the state file
- Verify the state file is encrypted
- Check DynamoDB table for lock entries during operations

### 4.3 State Modification
```bash
terraform state show aws_s3_bucket.example
```

## Task 5: Team Collaboration Simulation (20 minutes)

### 5.1 Multiple Terminal Test
1. Open two terminal windows
2. In both terminals, navigate to your project directory
3. In terminal 1, run: `terraform plan` (don't apply yet)
4. In terminal 2, immediately try to run: `terraform plan`

**Questions**:
1. What happens in terminal 2?
2. How does state locking prevent issues?
3. What would happen without state locking?

### 5.2 State File Analysis
Download and examine the state file from S3:
```bash
aws s3 cp s3://[your-bucket]/lab/terraform.tfstate ./local-state.json
```

**Analysis Points**:
- State file structure
- Resource dependencies
- Sensitive data handling

## Challenges

### Challenge 1: Multi-Environment Setup (30 minutes)
Create separate backend configurations for `dev`, `staging`, and `prod` environments:
- Use different state file paths for each environment
- Create environment-specific resource naming
- Implement workspace-based or directory-based separation

### Challenge 2: State Migration (25 minutes)
1. Start with local state (no backend configuration)
2. Create some resources
3. Migrate to S3 backend without losing state
4. Verify all resources are properly tracked

### Challenge 3: Backend Configuration Security (20 minutes)
Implement secure backend configuration:
- Use environment variables for sensitive values
- Configure S3 bucket policies for state file access
- Set up DynamoDB table with appropriate permissions
- Enable S3 bucket versioning and lifecycle policies

### Challenge 4: State Locking Scenarios (15 minutes)
Test various state locking scenarios:
1. Force unlock a stuck lock
2. Handle lock timeout situations
3. Understand lock metadata in DynamoDB

## Deliverables

### Required Files
1. `main.tf` - Complete Terraform configuration
2. `backend-config.md` - Documentation of your backend setup
3. `troubleshooting-log.md` - Record of errors encountered and solutions

### Verification Steps
- [ ] S3 bucket created and accessible
- [ ] DynamoDB table created with correct schema
- [ ] Terraform backend successfully configured
- [ ] Resources created and state stored remotely
- [ ] State locking demonstrated
- [ ] Error scenarios reproduced and resolved

## Assessment Criteria

### Basic (60%)
- Correct S3 and DynamoDB setup
- Working backend configuration
- Successful resource deployment

### Intermediate (80%)
- Error troubleshooting completed
- State management operations performed
- Team collaboration scenarios tested

### Advanced (100%)
- All challenges completed
- Security best practices implemented
- Comprehensive documentation provided

## Common Issues and Solutions

### Issue 1: Backend Initialization Fails
**Symptoms**: `terraform init` fails with backend errors
**Solutions**:
- Verify S3 bucket exists and is accessible
- Check AWS credentials and permissions
- Ensure DynamoDB table is in ACTIVE state

### Issue 2: State Lock Timeout
**Symptoms**: Operations hang waiting for lock
**Solutions**:
```bash
terraform force-unlock [LOCK_ID]
```

### Issue 3: Permission Denied
**Symptoms**: Access denied errors for S3 or DynamoDB
**Solutions**:
- Review IAM permissions
- Check bucket policies
- Verify resource ownership

## Additional Resources
- [Terraform S3 Backend Documentation](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [State Locking Best Practices](https://developer.hashicorp.com/terraform/language/state/locking)
- [AWS IAM Policies for Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Time Allocation
- **Total Time**: 2 hours
- **Basic Tasks**: 80 minutes
- **Challenges**: 40 minutes
- **Documentation**: 20 minutes