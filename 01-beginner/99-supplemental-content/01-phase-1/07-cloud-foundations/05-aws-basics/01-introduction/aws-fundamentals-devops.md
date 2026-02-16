# AWS Fundamentals for DevOps Engineers

## What is Amazon Web Services (AWS)?

Amazon Web Services (AWS) is a comprehensive cloud computing platform provided by Amazon that offers over 200 fully featured services from data centers globally. AWS provides on-demand cloud computing platforms and APIs to individuals, companies, and governments on a metered pay-as-you-go basis.

## Why AWS is Critical for DevOps

### 1. Infrastructure as Code (IaC)
- **CloudFormation**: Native AWS service for infrastructure provisioning
- **Terraform Integration**: Multi-cloud infrastructure management
- **CDK (Cloud Development Kit)**: Define infrastructure using familiar programming languages
- **Version Control**: Infrastructure changes tracked and managed like code
### 2. Scalability and Elasticity
- **Auto Scaling**: Automatic scaling based on demand
- **Elastic Load Balancing**: Distribute traffic across multiple instances
- **Global Infrastructure**: Deploy applications worldwide with low latency
- **Pay-as-you-use**: Cost optimization through elastic resource allocation
### 3. DevOps Tool Integration
- **CI/CD Services**: CodePipeline, CodeBuild, CodeDeploy, CodeCommit
- **Container Services**: ECS, EKS, Fargate for containerized applications
- **Monitoring**: CloudWatch, X-Ray for comprehensive observability
- **Security**: IAM, Security Groups, WAF for robust security posture

### 4. Managed Services
- **Database Services**: RDS, DynamoDB, ElastiCache reduce operational overhead
- **Messaging**: SQS, SNS, EventBridge for decoupled architectures
- **Storage**: S3, EFS, EBS for various storage needs
- **Compute**: EC2, Lambda, Batch for different compute requirements

## AWS Global Infrastructure

### Regions and Availability Zones

```bash
# List all AWS regions
aws ec2 describe-regions --output table

# Get current region
aws configure get region

# List availability zones in current region
aws ec2 describe-availability-zones --output table

# List availability zones in specific region
aws ec2 describe-availability-zones --region us-west-2 --output table
```

### AWS Global Infrastructure Components

```
AWS Global Infrastructure
├── Regions (26+ worldwide)
│   ├── Availability Zones (2-6 per region)
│   │   └── Data Centers (1+ per AZ)
│   └── Local Zones (for ultra-low latency)
├── Edge Locations (400+ worldwide)
│   ├── CloudFront CDN
│   └── Route 53 DNS
└── Regional Edge Caches
    └── CloudFront optimization
```

## Core AWS Services for DevOps

### Compute Services

#### EC2 (Elastic Compute Cloud)
```bash
# List all instances
aws ec2 describe-instances --output table

# Launch new instance
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DevOps-Server}]'

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Create AMI from instance
aws ec2 create-image \
    --instance-id i-1234567890abcdef0 \
    --name "DevOps-Server-$(date +%Y%m%d)" \
    --description "DevOps server image"
```
#### Lambda (Serverless Computing)
```bash
# List functions
aws lambda list-functions --output table

# Create function
aws lambda create-function \
    --function-name DevOpsFunction \
    --runtime python3.9 \
    --role arn:aws:iam::123456789012:role/lambda-execution-role \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://function.zip

# Invoke function
aws lambda invoke \
    --function-name DevOpsFunction \
    --payload '{"key1":"value1"}' \
    response.json

# Update function code
aws lambda update-function-code \
    --function-name DevOpsFunction \
    --zip-file fileb://updated-function.zip
```
### Storage Services

#### S3 (Simple Storage Service)
```bash
# List buckets
aws s3 ls

# Create bucket
aws s3 mb s3://my-devops-bucket-$(date +%s)

# Upload file
aws s3 cp local-file.txt s3://my-devops-bucket/

# Download file
aws s3 cp s3://my-devops-bucket/file.txt ./

# Sync directory
aws s3 sync ./local-folder s3://my-devops-bucket/folder/

# Set bucket policy
aws s3api put-bucket-policy \
    --bucket my-devops-bucket \
    --policy file://bucket-policy.json

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket my-devops-bucket \
    --versioning-configuration Status=Enabled
```
#### EBS (Elastic Block Store)
```bash
# List volumes
aws ec2 describe-volumes --output table

# Create volume
aws ec2 create-volume \
    --size 20 \
    --volume-type gp3 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=DevOps-Volume}]'

# Attach volume to instance
aws ec2 attach-volume \
    --volume-id vol-1234567890abcdef0 \
    --instance-id i-1234567890abcdef0 \
    --device /dev/sdf

# Create snapshot
aws ec2 create-snapshot \
    --volume-id vol-1234567890abcdef0 \
    --description "DevOps volume backup $(date)"
```
### Database Services

#### RDS (Relational Database Service)
```bash
# List DB instances
aws rds describe-db-instances --output table

# Create DB instance
aws rds create-db-instance \
    --db-instance-identifier devops-database \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password MySecurePassword123 \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-903004f8 \
    --backup-retention-period 7 \
    --multi-az

# Create DB snapshot
aws rds create-db-snapshot \
    --db-instance-identifier devops-database \
    --db-snapshot-identifier devops-db-snapshot-$(date +%Y%m%d)

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier restored-devops-db \
    --db-snapshot-identifier devops-db-snapshot-20240115
```

#### DynamoDB (NoSQL Database)
```bash
# List tables
aws dynamodb list-tables

# Create table
aws dynamodb create-table \
    --table-name DevOpsMetrics \
    --attribute-definitions \
        AttributeName=MetricId,AttributeType=S \
        AttributeName=Timestamp,AttributeType=N \
    --key-schema \
        AttributeName=MetricId,KeyType=HASH \
        AttributeName=Timestamp,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# Put item
aws dynamodb put-item \
    --table-name DevOpsMetrics \
    --item '{"MetricId":{"S":"cpu-usage"},"Timestamp":{"N":"1642694400"},"Value":{"N":"75.5"}}'

# Query items
aws dynamodb query \
    --table-name DevOpsMetrics \
    --key-condition-expression "MetricId = :id" \
    --expression-attribute-values '{":id":{"S":"cpu-usage"}}'
```

## Networking in AWS

### VPC (Virtual Private Cloud)

```bash
# Create VPC
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=DevOps-VPC}]'

# Create subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=DevOps-Public-Subnet}]'

# Create internet gateway
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=DevOps-IGW}]'

# Attach internet gateway to VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id igw-12345678 \
    --vpc-id vpc-12345678

# Create route table
aws ec2 create-route-table \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=DevOps-Public-RT}]'

# Add route to internet gateway
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id igw-12345678

# Associate route table with subnet
aws ec2 associate-route-table \
    --route-table-id rtb-12345678 \
    --subnet-id subnet-12345678
```
### Security Groups and NACL's
```bash
# Create security group
aws ec2 create-security-group \
    --group-name DevOps-WebServer-SG \
    --description "Security group for DevOps web servers" \
    --vpc-id vpc-12345678

# Add inbound rules
aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 22 \
    --source-group sg-903004f8

# List security group rules
aws ec2 describe-security-groups \
    --group-ids sg-903004f8 \
    --output table
```
## Identity and Access Management (IAM)

### Users and Groups
```bash
# Create user
aws iam create-user --user-name devops-user

# Create group
aws iam create-group --group-name DevOps-Team

# Add user to group
aws iam add-user-to-group \
    --group-name DevOps-Team \
    --user-name devops-user

# Attach policy to group
aws iam attach-group-policy \
    --group-name DevOps-Team \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Create access keys
aws iam create-access-key --user-name devops-user

# List users
aws iam list-users --output table

# List groups for user
aws iam list-groups-for-user --user-name devops-user
```
### Roles and Policies
```bash
# Create role
aws iam create-role \
    --role-name DevOps-EC2-Role \
    --assume-role-policy-document file://trust-policy.json

# Attach policy to role
aws iam attach-role-policy \
    --role-name DevOps-EC2-Role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create instance profile
aws iam create-instance-profile \
    --instance-profile-name DevOps-EC2-Profile

# Add role to instance profile
aws iam add-role-to-instance-profile \
    --instance-profile-name DevOps-EC2-Profile \
    --role-name DevOps-EC2-Role

# List roles
aws iam list-roles --output table
```
### Custom Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumes"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::devops-bucket/*"
    }
  ]
}
```
## Monitoring and Logging

### CloudWatch
```bash
# List metrics
aws cloudwatch list-metrics --namespace AWS/EC2

# Get metric statistics
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --statistics Average \
    --start-time 2024-01-15T00:00:00Z \
    --end-time 2024-01-15T23:59:59Z \
    --period 3600

# Create alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "High CPU Usage" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --evaluation-periods 2

# Create log group
aws logs create-log-group --log-group-name /aws/devops/application

# Create log stream
aws logs create-log-stream \
    --log-group-name /aws/devops/application \
    --log-stream-name application-logs

# Put log events
aws logs put-log-events \
    --log-group-name /aws/devops/application \
    --log-stream-name application-logs \
    --log-events timestamp=1642694400000,message="Application started successfully"
```
### Cloud-Trail
```bash
# Create trail
aws cloudtrail create-trail \
    --name DevOps-Audit-Trail \
    --s3-bucket-name devops-cloudtrail-logs

# Start logging
aws cloudtrail start-logging --name DevOps-Audit-Trail

# Get trail status
aws cloudtrail get-trail-status --name DevOps-Audit-Trail

# Lookup events
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=CreateUser \
    --start-time 2024-01-01 \
    --end-time 2024-01-31
```
## AWS CLI Configuration and Best Practices

### CLI Configuration
```bash
# Configure AWS CLI
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: us-east-1
# Default output format: json

# Configure named profiles
aws configure --profile devops-prod
aws configure --profile devops-staging

# Use specific profile
aws s3 ls --profile devops-prod

# Set environment variables
export AWS_PROFILE=devops-prod
export AWS_DEFAULT_REGION=us-east-1
export AWS_DEFAULT_OUTPUT=table

# Configure using environment variables
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
export AWS_DEFAULT_REGION=us-east-1
```
### CLI Best Practices
```bash
# Use IAM roles instead of access keys when possible
aws sts assume-role \
    --role-arn arn:aws:iam::123456789012:role/DevOps-Role \
    --role-session-name DevOps-Session

# Use MFA for sensitive operations
aws sts get-session-token \
    --serial-number arn:aws:iam::123456789012:mfa/user \
    --token-code 123456

# Use pagination for large result sets
aws ec2 describe-instances --max-items 50

# Use filters to reduce data transfer
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name]'

# Use output formatting
aws ec2 describe-instances --output table
aws ec2 describe-instances --output text --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress]'
```
### Cost Management and Optimization

### Cost Monitoring
```bash
# Get cost and usage
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

# Get rightsizing recommendations
aws ce get-rightsizing-recommendation \
    --service EC2-Instance

# Get usage forecast
aws ce get-usage-forecast \
    --time-period Start=2024-02-01,End=2024-02-28 \
    --metric BLENDED_COST \
    --granularity MONTHLY

# Create budget
aws budgets create-budget \
    --account-id 123456789012 \
    --budget file://budget.json
```
### Resource Tagging Strategy
```bash
# Tag resources consistently
aws ec2 create-tags \
    --resources i-1234567890abcdef0 \
    --tags Key=Environment,Value=Production \
           Key=Project,Value=DevOps \
           Key=Owner,Value=DevOpsTeam \
           Key=CostCenter,Value=Engineering

# Find untagged resources
aws resourcegroupstaggingapi get-resources \
    --resource-type-filters EC2:Instance \
    --tag-filters Key=Environment

# Bulk tag resources
aws ec2 describe-instances \
    --filters "Name=tag:Environment,Values=" \
    --query 'Reservations[].Instances[].[InstanceId]' \
    --output text | \
xargs -I {} aws ec2 create-tags \
    --resources {} \
    --tags Key=Environment,Value=Untagged
```
## Security Best Practices

### Security Fundamentals
```bash
# Enable MFA for root account
aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name root-account-mfa-device \
    --outfile QRCode.png \
    --bootstrap-method QRCodePNG

# Rotate access keys regularly
aws iam create-access-key --user-name devops-user
aws iam update-access-key \
    --user-name devops-user \
    --access-key-id AKIAIOSFODNN7EXAMPLE \
    --status Inactive
aws iam delete-access-key \
    --user-name devops-user \
    --access-key-id AKIAIOSFODNN7EXAMPLE

# Enable CloudTrail logging
aws cloudtrail create-trail \
    --name security-audit-trail \
    --s3-bucket-name security-logs-bucket \
    --include-global-service-events \
    --is-multi-region-trail

# Configure Config for compliance
aws configservice put-configuration-recorder \
    --configuration-recorder name=default,roleARN=arn:aws:iam::123456789012:role/config-role \
    --recording-group allSupported=true,includeGlobalResourceTypes=true

# Enable GuardDuty
aws guardduty create-detector --enable
```
### Secrets Management
```bash
# Store secrets in Systems Manager Parameter Store
aws ssm put-parameter \
    --name "/devops/database/password" \
    --value "MySecurePassword123" \
    --type "SecureString" \
    --description "Database password for DevOps application"

# Retrieve secrets
aws ssm get-parameter \
    --name "/devops/database/password" \
    --with-decryption

# Use AWS Secrets Manager
aws secretsmanager create-secret \
    --name "devops/database/credentials" \
    --description "Database credentials for DevOps application" \
    --secret-string '{"username":"admin","password":"MySecurePassword123"}'

# Retrieve secret
aws secretsmanager get-secret-value \
    --secret-id "devops/database/credentials"
```

---

## 🧠 Training & Assessment

### Knowledge Quiz

**1. Which AWS CLI command is used to list all availability zones in your current region?**
- A) `aws az list`
- B) `aws ec2 describe-availability-zones`
- C) `aws cloud info --zones`
- D) `aws region list-azs`

**2. What is the difference between an IAM User and an IAM Role?**
- A) A User is for people, a Role is for services (like EC2) and doesn't have permanent credentials
- B) A Role is for admins, a User is for standard workers
- C) There is no difference
- D) Users are free, Roles cost money

**3. Which CloudWatch feature allows you to automatically stop an EC2 instance if its CPU usage remains very low for a week?**
- A) CloudWatch Logs
- B) CloudWatch Alarms
- C) CloudWatch Events
- D) CloudWatch Dashboard

---

### Real-World Troubleshooting Scenarios

#### Scenario 1: The CloudWatch Bill Spike
**Problem:** Your AWS bill for CloudWatch just doubled this month.
**Investigation:**
1.  **Metric Quantity:** Did you enable "Detailed Monitoring" (1-minute intervals) for a large number of EC2 instances?
2.  **Log Volume:** Is an application stuck in an error loop, writing gigabytes of logs to CloudWatch Logs?
**Solution:** Disable Detailed Monitoring if not needed and optimize application logging levels. Set up Log Retention policies to expire old logs.

---

## ✅ Knowledge Check
- [ ] Use `aws configure` to set up multiple profiles
- [ ] Filter and Query CLI output using `--query` and `--filter`
- [ ] Deploy a simple Lambda function via CLI
- [ ] Create and attach an IAM Role to an EC2 instance
- [ ] Set up a CloudWatch Billing Alarm

---

This comprehensive AWS fundamentals guide provides DevOps engineers with essential knowledge for effectively using AWS services in modern cloud infrastructure and application deployment workflows.