# AWS EC2 Comprehensive Guide for DevOps Engineers

## EC2 Overview

Amazon Elastic Compute Cloud (EC2) provides scalable computing capacity in the AWS cloud. EC2 eliminates the need to invest in hardware upfront, allowing you to develop and deploy applications faster.

## EC2 Instance Types and Selection

### Instance Type Categories

#### General Purpose (T, M, A series)
```bash
# T4g instances (Burstable performance, ARM-based)
t4g.nano    # 2 vCPU, 0.5 GB RAM - Development/testing
t4g.micro   # 2 vCPU, 1 GB RAM - Low-traffic applications
t4g.small   # 2 vCPU, 2 GB RAM - Small applications
t4g.medium  # 2 vCPU, 4 GB RAM - Small to medium applications

# M6i instances (Balanced compute, memory, networking)
m6i.large   # 2 vCPU, 8 GB RAM - General workloads
m6i.xlarge  # 4 vCPU, 16 GB RAM - Web servers, microservices
m6i.2xlarge # 8 vCPU, 32 GB RAM - Enterprise applications

# List available instance types
aws ec2 describe-instance-types \
    --filters "Name=instance-type,Values=t3.*" \
    --query 'InstanceTypes[].[InstanceType,VCpuInfo.DefaultVCpus,MemoryInfo.SizeInMiB]' \
    --output table
```

#### Compute Optimized (C series)
```bash
# C6i instances (High-performance processors)
c6i.large   # 2 vCPU, 4 GB RAM - CPU-intensive applications
c6i.xlarge  # 4 vCPU, 8 GB RAM - High-performance web servers
c6i.2xlarge # 8 vCPU, 16 GB RAM - Scientific computing

# Use cases: Web servers, scientific computing, batch processing
```

#### Memory Optimized (R, X, z1d series)
```bash
# R6i instances (Memory-intensive applications)
r6i.large   # 2 vCPU, 16 GB RAM - In-memory databases
r6i.xlarge  # 4 vCPU, 32 GB RAM - Real-time analytics
r6i.2xlarge # 8 vCPU, 64 GB RAM - High-performance databases

# Use cases: In-memory databases, real-time analytics, caching
```

#### Storage Optimized (I, D, H series)
```bash
# I4i instances (NVMe SSD storage)
i4i.large   # 2 vCPU, 16 GB RAM, 468 GB NVMe SSD
i4i.xlarge  # 4 vCPU, 32 GB RAM, 937 GB NVMe SSD

# Use cases: NoSQL databases, distributed file systems, data warehousing
```

### Instance Selection Best Practices
```bash
# Get instance type recommendations
aws compute-optimizer get-ec2-instance-recommendations \
    --instance-arns arn:aws:ec2:us-east-1:123456789012:instance/i-1234567890abcdef0

# Check instance type availability in region
aws ec2 describe-instance-type-offerings \
    --location-type availability-zone \
    --filters Name=instance-type,Values=m5.large \
    --region us-east-1

# Compare instance types
aws ec2 describe-instance-types \
    --instance-types t3.medium m5.large c5.large \
    --query 'InstanceTypes[].[InstanceType,VCpuInfo.DefaultVCpus,MemoryInfo.SizeInMiB,NetworkInfo.NetworkPerformance]' \
    --output table
```
___

## EC2 Launch and Configuration

### Launching Instances
```bash
# Basic instance launch
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DevOps-Server},{Key=Environment,Value=Development}]'

# Launch with user data script
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e \
    --user-data file://user-data-script.sh \
    --iam-instance-profile Name=DevOps-EC2-Profile

# Launch with advanced configuration
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.medium \
    --key-name my-key-pair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e \
    --block-device-mappings '[
        {
            "DeviceName": "/dev/xvda",
            "Ebs": {
                "VolumeSize": 20,
                "VolumeType": "gp3",
                "Iops": 3000,
                "DeleteOnTermination": true,
                "Encrypted": true
            }
        }
    ]' \
    --monitoring Enabled=true \
    --disable-api-termination
```

### User Data Scripts
```bash
#!/bin/bash
# user-data-script.sh - DevOps server setup

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
mv terraform /usr/local/bin/

# Install monitoring agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "metrics": {
        "namespace": "DevOps/EC2",
        "metrics_collected": {
            "cpu": {
                "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/system",
                        "log_stream_name": "{instance_id}/messages"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Create application directory
mkdir -p /opt/app
chown ec2-user:ec2-user /opt/app

# Set up log rotation
cat > /etc/logrotate.d/application << 'EOF'
/opt/app/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 ec2-user ec2-user
}
EOF

echo "DevOps server setup completed" > /var/log/user-data.log
```
___

## EC2 Storage Management

### EBS Volume Management
```bash
# List volumes
aws ec2 describe-volumes \
    --filters "Name=attachment.instance-id,Values=i-1234567890abcdef0" \
    --output table

# Create volume
aws ec2 create-volume \
    --size 100 \
    --volume-type gp3 \
    --iops 3000 \
    --throughput 125 \
    --availability-zone us-east-1a \
    --encrypted \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=DevOps-Data-Volume}]'

# Attach volume
aws ec2 attach-volume \
    --volume-id vol-1234567890abcdef0 \
    --instance-id i-1234567890abcdef0 \
    --device /dev/sdf

# Modify volume (increase size)
aws ec2 modify-volume \
    --volume-id vol-1234567890abcdef0 \
    --size 200 \
    --volume-type gp3 \
    --iops 4000

# Create snapshot
aws ec2 create-snapshot \
    --volume-id vol-1234567890abcdef0 \
    --description "DevOps data backup $(date +%Y-%m-%d)" \
    --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=DevOps-Data-Backup}]'

# Copy snapshot to another region
aws ec2 copy-snapshot \
    --source-region us-east-1 \
    --source-snapshot-id snap-1234567890abcdef0 \
    --destination-region us-west-2 \
    --description "Cross-region backup"
```

### Instance Store Management

```bash
# List instance store volumes
lsblk

# Format and mount instance store
sudo mkfs.ext4 /dev/nvme1n1
sudo mkdir /mnt/instance-store
sudo mount /dev/nvme1n1 /mnt/instance-store
sudo chown ec2-user:ec2-user /mnt/instance-store

# Add to fstab for persistent mounting
echo '/dev/nvme1n1 /mnt/instance-store ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# Set up RAID for multiple instance store volumes
sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/nvme1n1 /dev/nvme2n1
sudo mkfs.ext4 /dev/md0
sudo mkdir /mnt/raid-store
sudo mount /dev/md0 /mnt/raid-store
```
___

## EC2 Networking

### Security Groups
```bash
# Create security group
aws ec2 create-security-group \
    --group-name DevOps-WebServer-SG \
    --description "Security group for DevOps web servers" \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=DevOps-WebServer-SG}]'

# Add HTTP/HTTPS rules
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

# Add SSH rule for specific IP
MY_IP=$(curl -s ifconfig.me)
aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 22 \
    --cidr ${MY_IP}/32

# Add rule referencing another security group
aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 3306 \
    --source-group sg-database123

# Remove rule
aws ec2 revoke-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

### Elastic IP Management
```bash
# Allocate Elastic IP
aws ec2 allocate-address \
    --domain vpc \
    --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=DevOps-Server-EIP}]'

# Associate with instance
aws ec2 associate-address \
    --instance-id i-1234567890abcdef0 \
    --allocation-id eipalloc-12345678

# Disassociate Elastic IP
aws ec2 disassociate-address \
    --association-id eipassoc-12345678

# Release Elastic IP
aws ec2 release-address \
    --allocation-id eipalloc-12345678

# List Elastic IPs
aws ec2 describe-addresses --output table
```

### Network Interfaces
```bash
# Create network interface
aws ec2 create-network-interface \
    --subnet-id subnet-12345678 \
    --description "DevOps server secondary interface" \
    --groups sg-903004f8 \
    --private-ip-address 10.0.1.50

# Attach network interface
aws ec2 attach-network-interface \
    --network-interface-id eni-12345678 \
    --instance-id i-1234567890abcdef0 \
    --device-index 1

# Detach network interface
aws ec2 detach-network-interface \
    --attachment-id eni-attach-12345678

# Delete network interface
aws ec2 delete-network-interface \
    --network-interface-id eni-12345678
```
___

## EC2 Auto Scaling

### Launch Templates
```bash
# Create launch template
aws ec2 create-launch-template \
    --launch-template-name DevOps-WebServer-Template \
    --launch-template-data '{
        "ImageId": "ami-0abcdef1234567890",
        "InstanceType": "t3.micro",
        "KeyName": "my-key-pair",
        "SecurityGroupIds": ["sg-903004f8"],
        "UserData": "'$(base64 -w 0 user-data-script.sh)'",
        "IamInstanceProfile": {
            "Name": "DevOps-EC2-Profile"
        },
        "BlockDeviceMappings": [
            {
                "DeviceName": "/dev/xvda",
                "Ebs": {
                    "VolumeSize": 20,
                    "VolumeType": "gp3",
                    "DeleteOnTermination": true,
                    "Encrypted": true
                }
            }
        ],
        "TagSpecifications": [
            {
                "ResourceType": "instance",
                "Tags": [
                    {"Key": "Name", "Value": "DevOps-AutoScaled-Server"},
                    {"Key": "Environment", "Value": "Production"}
                ]
            }
        ]
    }'

# Update launch template
aws ec2 create-launch-template-version \
    --launch-template-name DevOps-WebServer-Template \
    --launch-template-data '{
        "ImageId": "ami-0newimage1234567890",
        "InstanceType": "t3.small"
    }'

# Set default version
aws ec2 modify-launch-template \
    --launch-template-name DevOps-WebServer-Template \
    --default-version 2
```

### Auto Scaling Groups
```bash
# Create Auto Scaling group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name DevOps-WebServer-ASG \
    --launch-template LaunchTemplateName=DevOps-WebServer-Template,Version='$Latest' \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 3 \
    --vpc-zone-identifier "subnet-12345678,subnet-87654321" \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --tags Key=Name,Value=DevOps-WebServer-ASG,PropagateAtLaunch=true,ResourceId=DevOps-WebServer-ASG,ResourceType=auto-scaling-group

# Update Auto Scaling group
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name DevOps-WebServer-ASG \
    --desired-capacity 5 \
    --max-size 15

# Create scaling policies
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name DevOps-WebServer-ASG \
    --policy-name DevOps-ScaleUp-Policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'

# Suspend/resume processes
aws autoscaling suspend-processes \
    --auto-scaling-group-name DevOps-WebServer-ASG \
    --scaling-processes Launch,Terminate

aws autoscaling resume-processes \
    --auto-scaling-group-name DevOps-WebServer-ASG
```
___

## EC2 Monitoring and Troubleshooting

### CloudWatch Monitoring
```bash
# Enable detailed monitoring
aws ec2 monitor-instances --instance-ids i-1234567890abcdef0

# Get instance metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --statistics Average,Maximum \
    --start-time 2024-01-15T00:00:00Z \
    --end-time 2024-01-15T23:59:59Z \
    --period 3600

# Create custom metric
aws cloudwatch put-metric-data \
    --namespace DevOps/Application \
    --metric-data MetricName=ActiveUsers,Value=150,Unit=Count,Dimensions=Environment=Production

# Create alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "DevOps-High-CPU" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:devops-alerts
```

### Instance Troubleshooting
```bash
# Get instance console output
aws ec2 get-console-output --instance-id i-1234567890abcdef0

# Get instance screenshot
aws ec2 get-console-screenshot \
    --instance-id i-1234567890abcdef0 \
    --output text --query 'ImageData' | base64 -d > screenshot.jpg

# Check instance status
aws ec2 describe-instance-status \
    --instance-ids i-1234567890abcdef0 \
    --include-all-instances

# Reboot instance
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0

# Stop and start instance (not reboot)
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Get instance metadata from within instance
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/meta-data/instance-id
curl http://169.254.169.254/latest/meta-data/public-ipv4
curl http://169.254.169.254/latest/user-data

# Check system logs
sudo journalctl -u cloud-init
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log
```
___

## EC2 Security Best Practices

### Instance Security
```bash
# Use Systems Manager Session Manager instead of SSH
aws ssm start-session --target i-1234567890abcdef0

# Install SSM agent (if not pre-installed)
sudo yum install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Patch management with Systems Manager
aws ssm create-patch-baseline \
    --name "DevOps-Patch-Baseline" \
    --operating-system AMAZON_LINUX_2 \
    --approval-rules Rules='[{
        "PatchRules": [{
            "PatchFilterGroup": {
                "PatchFilters": [{
                    "Key": "CLASSIFICATION",
                    "Values": ["Security", "Bugfix", "Critical"]
                }]
            },
            "ApproveAfterDays": 7,
            "ComplianceLevel": "CRITICAL"
        }]
    }]

# Create maintenance window
aws ssm create-maintenance-window \
    --name "DevOps-Patching-Window" \
    --schedule "cron(0 2 ? * SUN *)" \
    --duration 4 \
    --cutoff 1 \
    --allow-unassociated-targets
```

### Encryption and Key Management
```bash
# Create KMS key for EBS encryption
aws kms create-key \
    --description "DevOps EBS encryption key" \
    --key-usage ENCRYPT_DECRYPT \
    --key-spec SYMMETRIC_DEFAULT

# Create alias for key
aws kms create-alias \
    --alias-name alias/devops-ebs-key \
    --target-key-id 12345678-1234-1234-1234-123456789012

# Launch instance with encrypted EBS
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e \
    --block-device-mappings '[{
        "DeviceName": "/dev/xvda",
        "Ebs": {
            "VolumeSize": 20,
            "VolumeType": "gp3",
            "Encrypted": true,
            "KmsKeyId": "alias/devops-ebs-key",
            "DeleteOnTermination": true
        }
    }]'

# Enable EBS encryption by default
aws ec2 enable-ebs-encryption-by-default
aws ec2 modify-ebs-default-kms-key-id \
    --kms-key-id alias/devops-ebs-key
```
___

## EC2 Cost Optimization

### Instance Optimization
```bash
# Get rightsizing recommendations
aws compute-optimizer get-ec2-instance-recommendations \
    --instance-arns arn:aws:ec2:us-east-1:123456789012:instance/i-1234567890abcdef0

# Use Spot Instances
aws ec2 request-spot-instances \
    --spot-price "0.05" \
    --instance-count 2 \
    --type "one-time" \
    --launch-specification '{
        "ImageId": "ami-0abcdef1234567890",
        "InstanceType": "t3.medium",
        "KeyName": "my-key-pair",
        "SecurityGroups": ["DevOps-WebServer-SG"],
        "UserData": "'$(base64 -w 0 user-data-script.sh)'"
    }'

# Reserved Instances
aws ec2 describe-reserved-instances-offerings \
    --instance-type t3.medium \
    --product-description "Linux/UNIX" \
    --offering-class standard \
    --offering-type "All Upfront"

# Purchase Reserved Instance
aws ec2 purchase-reserved-instances-offering \
    --reserved-instances-offering-id 12345678-1234-1234-1234-123456789012 \
    --instance-count 2
```

### Automated Cost Management
```bash
# Create Lambda function for instance scheduling
aws lambda create-function \
    --function-name EC2-Scheduler \
    --runtime python3.9 \
    --role arn:aws:iam::123456789012:role/lambda-execution-role \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://ec2-scheduler.zip \
    --description "Automatically start/stop EC2 instances"

# Create EventBridge rule for scheduling
aws events put-rule \
    --name EC2-Stop-Evening \
    --schedule-expression "cron(0 18 * * MON-FRI)" \
    --description "Stop development instances at 6 PM weekdays"

aws events put-targets \
    --rule EC2-Stop-Evening \
    --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:123456789012:function:EC2-Scheduler","Input"='{"action":"stop","environment":"development"}'
```

This comprehensive EC2 guide provides DevOps engineers with detailed knowledge for effectively managing EC2 instances in production environments, covering everything from basic operations to advanced automation and optimization techniques.