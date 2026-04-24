# AWS Networking Hacks & Tips

## Introduction
This guide contains battle-tested networking hacks, shortcuts, and best practices from real-world AWS deployments. These tips will save you time, reduce costs, and help you avoid common pitfalls.

## [01] Quick Wins | CLI & Shortcuts

### One-Liner Commands for Common Tasks
```bash
# Get all VPC IDs and names
aws ec2 describe-vpcs --query 'Vpcs[].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output table
```
- Find all public subnets
```bash
aws ec2 describe-subnets \
  --filters "Name=map-public-ip-on-launch,Values=true" \
  --query 'Subnets[].[SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```
- List all security groups with open SSH (security audit)
```bash
aws ec2 describe-security-groups \
  --filters "Name=ip-permission.from-port,Values=22" \
  --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].{GroupId:GroupId,Name:GroupName}' \
  --output table
```
- Get NAT Gateway costs for last month
```bash
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-02-01 \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --filter file://<(echo '{"Dimensions":{"Key":"SERVICE","Values":["Amazon EC2"]}}') \
  --query 'ResultsByTime[].Groups[?contains(Keys[0],`NatGateway`)]'
```
- Find instances without proper tags
```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[?!Tags||!Tags[?Key==`Name`]].{ID:InstanceId,State:State.Name}' \
  --output table
```

### AWS CLI Aliases (Add to ~/.bashrc or ~/.zshrc)
```bash
# VPC shortcuts
alias vpc-list='aws ec2 describe-vpcs --query "Vpcs[].[VpcId,CidrBlock,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias sg-list='aws ec2 describe-security-groups --query "SecurityGroups[].[GroupId,GroupName,VpcId]" --output table'
alias subnet-list='aws ec2 describe-subnets --query "Subnets[].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==\`Name\`].Value|[0]]" --output table'

# Quick security group rule add
sg-allow() {
    aws ec2 authorize-security-group-ingress \
        --group-id "$1" \
        --protocol tcp \
        --port "$2" \
        --cidr "${3:-0.0.0.0/0}"
}
# Usage: sg-allow sg-12345678 80 10.0.0.0/16

# Find my IP (for security group rules)
alias myip='curl -s ifconfig.me'
```
___

## [02] Cost Hacks | NAT & Endpoints

### 1. Single NAT Gateway for Development
**Problem**: NAT Gateways cost ~$32/month each  
**Solution**: Use one NAT Gateway for all Dev/Test environments
```bash
# BAD: Multiple NAT Gateways ($$$$)
# AZ-1a: NAT Gateway ($32/mo)
# AZ-1b: NAT Gateway ($32/mo)
# AZ-1c: NAT Gateway ($32/mo)
# Total: $96/month

# GOOD: Single NAT Gateway for Dev ($)
# Only AZ-1a: NAT Gateway ($32/mo)
# Route all AZs through one NAT
# Total: $32/month
# Savings: $64/month = $768/year

# Implementation
aws ec2 create-nat-gateway \
  --subnet-id $PUBLIC_SUBNET_1A \
  --allocation-id $EIP_ALLOC

# Point all private route tables to this one NAT
for RT in $PRIVATE_RT_1A $PRIVATE_RT_1B $PRIVATE_RT_1C; do
  aws ec2 create-route \
    --route-table-id $RT \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id $NAT_GW
done
```
**Warning**: Not recommended for production (single point of failure)
### 2. VPC Endpoints = Free Data Transfer
**Problem**: Data transfer from S3 through NAT Gateway costs $0.045/GB  
**Solution**: Use VPC Endpoints for S3/DynamoDB (FREE!)
```bash
# Create S3 VPC Endpoint (Gateway type - FREE!)
aws ec2 create-vpc-endpoint \
  --vpc-id $VPC_ID \
  --service-name com.amazonaws.us-east-1.s3 \
  --route-table-ids $PRIVATE_RT_ID \
  --vpc-endpoint-type Gateway

# Create DynamoDB VPC Endpoint (also FREE!)
aws ec2 create-vpc-endpoint \
  --vpc-id $VPC_ID \
  --service-name com.amazonaws.us-east-1.dynamodb \
  --route-table-ids $PRIVATE_RT_ID \
  --vpc-endpoint-type Gateway

# Savings example:
# 1TB data transfer to S3 via NAT: $45/month
# 1TB data transfer via VPC Endpoint: $0/month
# Annual savings: $540!
```
### 3. Reserved NAT Gateway Hours? No. Use Scheduled Scaling
**Problem**: NAT Gateways can't be reserved, always on-demand  
**Solution**: Delete/recreate for non-24/7 workloads
```bash
#!/bin/bash
# Schedule: Delete NAT Gateway at 8 PM, recreate at 8 AM

# Evening shutdown (Lambda or cron)
delete_nat_gateway() {
    NAT_GW=$(aws ec2 describe-nat-gateways \
        --filter "Name=tag:Environment,Values=dev" \
        --query 'NatGateways[0].NatGatewayId' \
        --output text)
    
    aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW
    echo "NAT Gateway deleted - saving $0.045/hour"
}

# Morning recreation
create_nat_gateway() {
   # Recreate with saved EIP
    aws ec2 create-nat-gateway \
        --subnet-id $PUBLIC_SUBNET \
        --allocation-id $SAVED_EIP_ALLOC
}

# Savings: 14 hours/day * 30 days = 420 hours saved
# $0.045 * 420 = $18.90/month savings per NAT Gateway
```
### 4. Data Transfer Optimization
```bash
# EXPENSIVE: Cross-region data transfer
# us-east-1 → us-west-2: $0.02/GB

# CHEAP: Same-region transfer
# us-east-1a → us-east-1b: $0.01/GB

# FREE: Same-AZ transfer (use private IPs!)
# us-east-1a → us-east-1a: $0.00/GB

# Hack: Use S3 Transfer Acceleration selectively
# Only for uploads >1GB from distant locations
aws s3api put-bucket-accelerate-configuration \
  --bucket my-bucket \
  --accelerate-configuration Status=Enabled

# Use only when needed (costs extra!)
aws s3 cp large-file.zip s3://my-bucket/ --endpoint-url https://my-bucket.s3-accelerate.amazonaws.com
```
___
## [03] Performance Hacks | MTU & Speed

### 1. Enhanced Networking (FREE Performance Boost!)
```bash
# Enable Enhanced Networking (SR-IOV) - NO EXTRA COST!
# Provides up to 100 Gbps bandwidth

# Check if instance supports it
aws ec2 describe-instance-attribute \
  --instance-id i-1234567890abcdef0 \
  --attribute sriovNetSupport

# Enable for AMI (when creating)
aws ec2 register-image \
  --name my-enhanced-ami \
  --root-device-name /dev/xvda \
  --sriov-net-support simple \
  --ena-support

# Instance types with Enhanced Networking:
# - C5, M5, R5 families (default enabled)
# - Older: C4, M4, R4 (may need enablement)

# Verify with ethtool inside instance
sudo ethtool -i eth0 | grep driver
# Should show: ena (Elastic Network Adapter)
```
### 2. Placement Groups for Low Latency
```bash
# Cluster placement group: < 1ms latency, 10 Gbps+ bandwidth
aws ec2 create-placement-group \
  --group-name low-latency-cluster \
  --strategy cluster

# Launch instances
aws ec2 run-instances \
  --image-id ami-12345678 \
  --instance-type c5.2xlarge \
  --placement GroupName=low-latency-cluster \
  --count 3

# Use case: HPC, databases, real-time processing
# Limitation: Single AZ only
# Benefit: Sub-millisecond latency between instances
```
### 3. Jumbo Frames (MTU 9001)
```bash
# Default MTU: 1500 bytes
# Jumbo Frames: 9001 bytes (6x larger packets!)

# Enable on network interface (inside instance)
sudo ip link set dev eth0 mtu 9001

# Verify
ip link show eth0 | grep mtu

# Test with ping
ping -M do -s 8973 <target-ip>  # 8973 + 28 header = 9001

#Benefits:
# - Reduced packet overhead
# - Better throughput for large transfers
# - Lower CPU usage

# Works between: EC2 ↔ EC2, EC2 ↔ S3 (via endpoint)
# Does NOT work: EC2 → Internet (capped at MTU 1500)
```
___

## [04] Automation Hacks | TF & Python

### 1. Terraform Module for Standard VPC
```hcl
# Save as modules/vpc/main.tf
module "vpc" {
  source = "./modules/vpc"
  
  name_prefix = "prod"
  cidr        = "10.0.0.0/16"
  azs         = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Subnets created automatically!
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  enable_nat_gateway     = true
  single_nat_gateway     = false  # HA setup
  enable_dns_hostnames   = true
  enable_s3_endpoint     = true
  enable_dynamodb_endpoint = true
  
  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# One module call = Complete VPC setup!
#Saves hours of manual configuration
```

### 2. Python Script: Security Group Auditor
```python
#!/usr/bin/env python3
import boto3
import json

ec2 = boto3.client('ec2')

def audit_security_groups():
    """Find overly permissive security groups"""
    dangerous_rules = []
    
    sgs = ec2.describe_security_groups()['SecurityGroups']
    
    for sg in sgs:
        for rule in sg.get('IpPermissions', []):
            # Check for 0.0.0.0/0 on dangerous ports
            for ip_range in rule.get('IpRanges', []):
                if ip_range.get('CidrIp') == '0.0.0.0/0':
                    from_port = rule.get('FromPort', 'all')
                    to_port = rule.get('ToPort', 'all')
                    
                    # Dangerous: SSH, RDP, databases
                    if from_port in [22, 3389, 3306, 5432, 27017, 6379]:
                        dangerous_rules.append({
                            'GroupId': sg['GroupId'],
                            'GroupName': sg['GroupName'],
                            'Port': from_port,
                            'Risk': 'HIGH'
                        })
    
    print(json.dumps(dangerous_rules, indent=2))
    return dangerous_rules

if __name__ == '__main__':
    audit_security_groups()
```

### 3. Bash Script: Network Diagnostic Tool
```bash
#!/bin/bash
# network-doctor.sh - Quick network diagnostics

TARGET_IP="$1"
TARGET_PORT="${2:-80}"

echo "=== Network Diagnostics for $TARGET_IP:$TARGET_PORT ==="
echo

# 1. Basic connectivity
echo "1. Testing ICMP (ping)..."
if ping -c 3 -W 2 "$TARGET_IP" &>/dev/null; then
    echo "✅ ICMP reachable"
else
    echo "❌ ICMP blocked (may be expected)"
fi
echo

# 2. TCP connectivity
echo "2. Testing TCP port $TARGET_PORT..."
if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$TARGET_IP/$TARGET_PORT" 2>/dev/null; then
    echo "✅ Port $TARGET_PORT is OPEN"
else
    echo "❌ Port $TARGET_PORT is CLOSED or filtered"
fi
echo

# 3. DNS resolution
echo "3. Testing DNS resolution..."
nslookup "$TARGET_IP" || echo "Not a domain"
echo

# 4. Traceroute
echo "4. Network path:"
traceroute -m 15 -q 1 "$TARGET_IP" 2>/dev/null | head -10
echo

# 5. MTU detection
echo "5. MTU Detection:"
for mtu in 1500 9001; do
    if ping -M do -s $((mtu-28)) -c 1 -W 2 "$TARGET_IP" &>/dev/null; then
        echo "✅ MTU $mtu supported"
    else
        echo "❌ MTU $mtu not supported"
    fi
done

echo
echo "=== Diagnostics Complete ==="
```

## [05] Security Hacks | SG Templates

### 1. Least-Privilege Security Group Templates
```bash
# Template 1: Web server (public)
create_web_sg() {
    SG_ID=$(aws ec2 create-security-group \
        --group-name web-tier-sg \
        --description "Web tier - HTTP/HTTPS only" \
        --vpc-id $VPC_ID \
        --query 'GroupId' --output text)
    
    # Allow HTTP/HTTPS from anywhere
    aws ec2 authorize-security-group-ingress --group-id $SG_ID \
        --ip-permissions \
        IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges='[{CidrIp=0.0.0.0/0,Description="Public HTTP"}]' \
        IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges='[{CidrIp=0.0.0.0/0,Description="Public HTTPS"}]'
    
    echo $SG_ID
}

# Template 2: App server (private, only from web tier)
create_app_sg() {
    local WEB_SG=$1
    
    SG_ID=$(aws ec2 create-security-group \
        --group-name app-tier-sg \
        --description "App tier - from web tier only" \
        --vpc-id $VPC_ID \
        --query 'GroupId' --output text)
    
    # Allow only from web tier
    aws ec2 authorize-security-group-ingress --group-id $SG_ID \
        --protocol tcp --port 8080 --source-group $WEB_SG
    
    echo $SG_ID
}

# Template 3: Database (private, only from app tier)
create_db_sg() {
    local APP_SG=$1
    
    SG_ID=$(aws ec2 create-security-group \
        --group-name db-tier-sg \
        --description "Database tier - from app tier only" \
        --vpc-id $VPC_ID \
        --query 'GroupId' --output text)
    
    # PostgreSQL only from app tier
    aws ec2 authorize-security-group-ingress --group-id $SG_ID \
        --protocol tcp --port 5432 --source-group $APP_SG
    
    echo $SG_ID
}

# Chain them together for perfect isolation
WEB_SG=$(create_web_sg)
APP_SG=$(create_app_sg $WEB_SG)
DB_SG=$(create_db_sg $APP_SG)
```

### 2. VPC Flow Logs Analysis for Security
```bash
# Enable VPC Flow Logs to CloudWatch
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids $VPC_ID \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /aws/vpc/flowlogs \
  --deliver-logs-permission-arn $FLOW_LOGS_ROLE_ARN

# Analysis: Find rejected connections (potential attacks)
aws logs filter-log-events \
  --log-group-name /aws/vpc/flowlogs \
  --filter-pattern "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action=REJECT, flowlogstatus]" \
  --start-time $(($(date +%s) - 3600))000 \
  --query 'events[].message' \
  --output text | \
  awk '{print $4,$6}' | sort | uniq -c | sort -rn | head -20

# Top rejected source IPs (potential attackers)
```

### 3. Automated Security Group Cleanup
```python
#!/usr/bin/env python3
# cleanup-unused-sgs.py
import boto3
from collections import defaultdict

ec2 = boto3.client('ec2')

def find_unused_security_groups():
    """Find security groups not attached to any resources"""
    all_sgs = {sg['GroupId']: sg for sg in ec2.describe_security_groups()['SecurityGroups']}
    used_sgs = set()
    
    # Check EC2 instances
    for reservation in ec2.describe_instances()['Reservations']:
        for instance in reservation['Instances']:
            for sg in instance.get('SecurityGroups', []):
                used_sgs.add(sg['GroupId'])
    
    # Check RDS instances
    rds = boto3.client('rds')
    for db in rds.describe_db_instances()['DBInstances']:
        for sg in db.get('VpcSecurityGroups', []):
            used_sgs.add(sg['VpcSecurityGroupId'])
    
    # Check ELBs
    elb = boto3.client('elbv2')
    for lb in elb.describe_load_balancers()['LoadBalancers']:
        for sg in lb.get('SecurityGroups', []):
            used_sgs.add(sg)
    
    # Unused = all - used - default
    unused = set(all_sgs.keys()) - used_sgs
    unused = [sg_id for sg_id in unused if all_sgs[sg_id]['GroupName'] != 'default']
    
    print(f"Found {len(unused)} unused security groups:")
    for sg_id in unused:
        sg = all_sgs[sg_id]
        print(f"  - {sg_id}: {sg['GroupName']} (VPC: {sg.get('VpcId', 'EC2-Classic')})")
    
    return unused

if __name__ == '__main__':
    find_unused_security_groups()
```
___

## [06] Troubleshooting | Diagnostics

### 1. Quick Connectivity Test
```bash
# One-liner to test if instance can reach S3
aws ssm send-command \
  --instance-ids i-1234567890abcdef0 \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["curl -I https://s3.amazonaws.com"]' \
  --query 'Command.CommandId' --output text

# Check result
aws ssm get-command-invocation \
  --command-id <command-id> \
  --instance-id i-1234567890abcdef0
```

### 2. Security Group Effective Rules Checker

```bash
# What rules actually apply to this instance?
check_instance_access() {
    INSTANCE_ID=$1
    PORT=$2
    
    # Get security groups
    SGS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].SecurityGroups[].GroupId' \
        --output text)
    
    echo "Security Groups: $SGS"
    echo "Checking port $PORT access..."
    
    for SG in $SGS; do
        echo "\n=== $SG ==="
        aws ec2 describe-security-groups --group-ids $SG \
            --query "SecurityGroups[0].IpPermissions[?FromPort<=\`$PORT\` && ToPort>=\`$PORT\`]"
    done
}

# Usage: check_instance_access i-1234567890abcdef0 443
```

### 3. Route Table Visualizer

```bash
#!/bin/bash
# visualize-routes.sh - Show all routes in a VPC

VPC_ID=$1

echo "=== Route Tables for VPC $VPC_ID ==="
echo

aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'RouteTables[].[RouteTableId,Tags[?Key==`Name`].Value|[0],Associations[0].SubnetId]' \
  --output text | \
while read RT_ID RT_NAME SUBNET; do
    echo "Route Table: $RT_ID ($RT_NAME)"
    echo "Associated Subnet: ${SUBNET:-Main}"
    echo "Routes:"
    
    aws ec2 describe-route-tables --route-table-ids $RT_ID \
      --query 'RouteTables[0].Routes[].[DestinationCidrBlock,GatewayId,NatGatewayId,State]' \
      --output table
    
    echo "---"
done
```

## Pro Tips

### 1. Use Systems Manager Session Manager (No Bastion Host!)

```bash
# OLD WAY: Bastion host costs $10-50/month
# NEW WAY: SSM Session Manager = FREE!

# No need for:
# - Public IP
# - SSH keys
# - Security group port 22
# - Bastion host maintenance

# Start session
aws ssm start-session --target i-1234567890abcdef0

# Port forwarding (access RDS from local machine!)
aws ssm start-session \
  --target i-1234567890abcdef0 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["5432"],"localPortNumber":["9999"]}'

# Now connect to localhost:9999 → private RDS instance!
```

### 2. Reserved Capacity for Data Transfer
```bash
# Save 31-63% on data transfer out

# Example: Commit to 10 TB/month data transfer
# On-demand: $0.09/GB = $900/month
# Reserved (1 year): $0.060/GB = $600/month
# Savings: $300/month = $3,600/year

# Not available via CLI, purchase via AWS Console:
# Billing → Reserved Instances → Data Transfer
```

### 3. CloudFormation Stack for Quick VPC
```yaml
# Save as quick-vpc.yaml
# Deploy with: aws cloudformation create-stack --stack-name my-vpc --template-body file://quick-vpc.yaml

AWSTemplateFormatVersion: '2010-09-09'
Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: QuickVPC
  
  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
  
  IGW:
    Type: AWS::EC2::InternetGateway
  
  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref IGW
  
  PublicRT:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
  
  PublicRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PublicRT
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref IGW
  
  SubnetRTAssoc:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet
      RouteTableId: !Ref PublicRT

Outputs:
  VPCId:
    Value: !Ref VPC
  SubnetId:
    Value: !Ref PublicSubnet
```

## Summary Checklist

✅ **Cost Optimization**
- Use single NAT Gateway for dev/test
- Implement VPC Endpoints for S3/DynamoDB
- Schedule NAT Gateway for non-24/7 workloads
- Optimize data transfer paths

✅ **Performance**
- Enable Enhanced Networking (free!)
- Use placement groups for low latency
- Enable jumbo frames (MTU 9001)
- Use privateIPs for same-AZ communication

✅ **Security**
- Audit security groups regularly
- Use least-privilege rules
- Enable VPC Flow Logs
- Clean up unused security groups

✅ **Automation**
- Use Terraform/CloudFormation modules
- Create reusable scripts
- Implement monitoring automation

✅ **Troubleshooting**
- Use SSM Session Manager
- Create diagnostic scripts
- Monitor VPC Flow Logs

---

**More Resources**:
- [Architect's Guide (README)](readme.md)
- [Troubleshooting Guide](../../../../../readme.md)
