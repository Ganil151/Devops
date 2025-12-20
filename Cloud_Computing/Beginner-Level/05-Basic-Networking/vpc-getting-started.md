# AWS VPC Getting Started Guide

## Introduction

This hands-on guide will walk you through creating your first Virtual Private Cloud (VPC) on AWS. By the end, you'll have a fully functional VPC with public and private subnets, internet connectivity, and proper security configurations.

## What You'll Build
![VPC Architecture](../../Images/VpcArch.png)

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- Basic understanding of networking concepts (IP addresses, subnets)
- Optionally: AWS Console access

**Estimated Time**: 30-45 minutes  
**Cost**: Free Tier eligible (minimal cost if outside Free Tier)

## Step 1: Plan Your VPC

### Choose Your CIDR Block

**CIDR Calculator**:
```bash
# VPC CIDR: 10.0.0.0/16
# Usable IPs: 65,536 addresses
# Subnet examples:
# - Public Subnet: 10.0.1.0/24 (256 addresses)
# - Private Subnet: 10.0.2.0/24 (256 addresses)
# - Database Subnet: 10.0.3.0/24 (256 addresses)

# Quick CIDR reference
/16 = 65,536 IPs   (Recommended for VPC)
/24 = 256 IPs      (Recommended for subnets)
/28 = 16 IPs       (Small subnets)
```

**Best Practices**:
- Use private IP ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
- Plan for growth - don't use /24 for your VPC
- Avoid overlapping with on-premises networks
- Leave room for future subnets

## Step 2: Create VPC (AWS Console)

### Visual Step-by-Step

**1. Navigate to VPC Dashboard**
- Log into AWS Console
- Search for "VPC" in services
- Click "Your VPCs" → "Create VPC"

**2. Configure VPC**
```yaml
Settings:
  Name tag: my-first-vpc
  IPv4 CIDR: 10.0.0.0/16
  IPv6 CIDR: No IPv6 CIDR block
  Tenancy: Default
```

**3. Enable DNS**
- Select your VPC
- Actions → Edit DNS hostnames → Enable
- Actions → Edit DNS resolution → Enable

### Why These Settings Matter

**DNS Hostnames**: Allows EC2 instances to get public DNS names  
**DNS Resolution**: Enables Route 53 private hosted zones  
**Tenancy**: Default is cheaper, Dedicated for compliance

## Step 3: Create VPC (AWS CLI)

### Quick CLI Method

```bash
# 1. Create VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-first-vpc}]' \
  --query 'Vpc.VpcId' \
  --output text)

echo "VPC ID: $VPC_ID"

# 2. Enable DNS hostnames
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames

# 3. Enable DNS resolution
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-support

# 4. Verify VPC
aws ec2 describe-vpcs --vpc-ids $VPC_ID
```

**Pro Tip**: Save the VPC_ID variable for later steps!

## Step 4: Create Subnets

### Public Subnet (Internet-accessible)

**Console Method**:
- VPC Dashboard → Subnets → Create subnet
- Select your VPC
- Name: public-subnet-1a
- Availability Zone: us-east-1a
- CIDR: 10.0.1.0/24

**CLI Method**:
```bash
# Create public subnet
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-1a}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Public Subnet ID: $PUBLIC_SUBNET_ID"

# Enable auto-assign public IP
aws ec2 modify-subnet-attribute \
  --subnet-id $PUBLIC_SUBNET_ID \
  --map-public-ip-on-launch
```

### Private Subnet (Internal only)

```bash
# Create private subnet
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-1a}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Private Subnet ID: $PRIVATE_SUBNET_ID"
```

### Multi-AZ Best Practice

**For High Availability**, create subnets in multiple AZs:

```bash
# Public subnet in AZ 1b
PUBLIC_SUBNET_1B=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.3.0/24 \
  --availability-zone us-east-1b \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-1b}]' \
  --query 'Subnet.SubnetId' \
  --output text)

# Private subnet in AZ 1b
PRIVATE_SUBNET_1B=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.4.0/24 \
  --availability-zone us-east-1b \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-1b}]' \
  --query 'Subnet.SubnetId' \
  --output text)
```

## Step 5: Create Internet Gateway

### What is an Internet Gateway?

An Internet Gateway (IGW) allows communication between your VPC and the internet. Required for public subnets.

```bash
# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-igw}]' \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

echo "Internet Gateway ID: $IGW_ID"

# Attach to VPC
aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID

# Verify attachment
aws ec2 describe-internet-gateways --internet-gateway-ids $IGW_ID
```

**Important**: One VPC = One Internet Gateway (1:1 relationship)

## Step 6: Create NAT Gateway

### What is a NAT Gateway?

NAT Gateway allows private subnet resources to access the internet (for updates) while remaining private.

**Prerequisites**: Allocate Elastic IP first

```bash
# 1. Allocate Elastic IP
EIP_ALLOC_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=nat-eip}]' \
  --query 'AllocationId' \
  --output text)

echo "Elastic IP Allocation ID: $EIP_ALLOC_ID"

# 2. Create NAT Gateway (in public subnet!)
NAT_GW_ID=$(aws ec2 create-nat-gateway \
  --subnet-id $PUBLIC_SUBNET_ID \
  --allocation-id $EIP_ALLOC_ID \
  --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=my-nat-gw}]' \
  --query 'NatGateway.NatGatewayId' \
  --output text)

echo "NAT Gateway ID: $NAT_GW_ID"

# 3. Wait for NAT Gateway to be available (takes 1-2 minutes)
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID
echo "NAT Gateway is ready!"
```

**Cost Warning**: NAT Gateways cost ~$0.045/hour + data transfer fees

## Step 7: Configure Route Tables

### Public Route Table

```bash
# 1. Create public route table
PUBLIC_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=public-rt}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)

echo "Public Route Table ID: $PUBLIC_RT_ID"

# 2. Add route to Internet Gateway
aws ec2 create-route \
  --route-table-id $PUBLIC_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

# 3. Associate with public subnet
aws ec2 associate-route-table \
  --route-table-id $PUBLIC_RT_ID \
  --subnet-id $PUBLIC_SUBNET_ID
```

### Private Route Table

```bash
# 1. Create private route table
PRIVATE_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=private-rt}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)

echo "Private Route Table ID: $PRIVATE_RT_ID"

# 2. Add route to NAT Gateway
aws ec2 create-route \
  --route-table-id $PRIVATE_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id $NAT_GW_ID

# 3. Associate with private subnet
aws ec2 associate-route-table \
  --route-table-id $PRIVATE_RT_ID \
  --subnet-id $PRIVATE_SUBNET_ID
```

### Route Table Summary

| Route Table | Subnet | Route | Purpose |
|-------------|--------|-------|---------|
| Public RT | Public Subnet | 0.0.0.0/0 → IGW | Internet access |
| Private RT | Private Subnet | 0.0.0.0/0 → NAT GW | Outbound only |

## Step 8: Create Security Groups

### Web Server Security Group

```bash
# Create security group
WEB_SG_ID=$(aws ec2 create-security-group \
  --group-name web-server-sg \
  --description "Security group for web servers" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

echo "Web Security Group ID: $WEB_SG_ID"

# Allow HTTP (port 80)
aws ec2 authorize-security-group-ingress \
  --group-id $WEB_SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Allow HTTPS (port 443)
aws ec2 authorize-security-group-ingress \
  --group-id $WEB_SG_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# Allow SSH (port 22) - RESTRICT THIS IN PRODUCTION!
aws ec2 authorize-security-group-ingress \
  --group-id $WEB_SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr YOUR_IP_ADDRESS/32  # Replace with your IP!
```

**Security Best Practice**: Always restrict SSH to your IP, not 0.0.0.0/0

### Application Server Security Group

```bash
# Create app server security group
APP_SG_ID=$(aws ec2 create-security-group \
  --group-name app-server-sg \
  --description "Security group for application servers" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

# Allow traffic from web servers only
aws ec2 authorize-security-group-ingress \
  --group-id $APP_SG_ID \
  --protocol tcp \
  --port 8080 \
  --source-group $WEB_SG_ID
```

## Step 9: Test Your VPC

### Launch a Test Instance

```bash
# Get latest Amazon Linux 2 AMI
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)

# Launch instance in public subnet
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --subnet-id $ PUBLIC_SUBNET_ID \
  --security-group-ids $WEB_SG_ID \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test-web-server}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance ID: $INSTANCE_ID"
```

### Test Connectivity

```bash
# Wait for instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Public IP: $PUBLIC_IP"

# Test SSH (if you have key pair)
# ssh -i your-key.pem ec2-user@$PUBLIC_IP

# Test HTTP (if web server is installed)
# curl http://$PUBLIC_IP
```

## Common Issues and Solutions

### Issue 1: Can't SSH to Instance

**Symptoms**: Connection timeout

**Fixes**:
```bash
# 1. Check security group rules
aws ec2 describe-security-groups --group-ids $WEB_SG_ID

# 2. Verify instance has public IP
aws ec2 describe-instances --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress'

# 3. Check route table
aws ec2 describe-route-tables --route-table-ids $PUBLIC_RT_ID

# 4. Verify internet gateway is attached
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID"
```

### Issue 2: Private Instance Can't Reach Internet

**Symptoms**: Can't update packages, can't download files

**Fixes**:
```bash
# 1. Check NAT Gateway status
aws ec2 describe-nat-gateways --nat-gateway-ids $NAT_GW_ID

# 2. Verify route exists
aws ec2 describe-route-tables --route-table-ids $PRIVATE_RT_ID

# 3. Check security group allows outbound
aws ec2 describe-security-groups --group-ids $APP_SG_ID \
  --query 'SecurityGroups[0].IpPermissionsEgress'
```

### Issue 3: Security Group Changes Don't Work

**Solution**: Security groups are stateful - allow only ingress, egress is automatic for responses

## Complete Script

**Save this as `create-vpc.sh`**:

```bash
#!/bin/bash
# Complete VPC creation script

set -e  # Exit on error

# Variables
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_CIDR="10.0.2.0/24"
AZ="us-east-1a"

echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=automated-vpc}]' \
  --query 'Vpc.VpcId' --output text)
echo "VPC ID: $VPC_ID"

# [Rest of script using variables from above steps]
# See full script in repository
```

## Cleanup

**Important**: Delete resources to avoid charges!

```bash
# Delete in reverse order

# 1. Terminate instances
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

# 2. Delete NAT Gateway
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID
aws ec2 wait nat-gateway-deleted --nat-gateway-ids $NAT_GW_ID

# 3. Release Elastic IP
aws ec2 release-address --allocation-id $EIP_ALLOC_ID

# 4. Delete security groups
aws ec2 delete-security-group --group-id $WEB_SG_ID
aws ec2 delete-security-group --group-id $APP_SG_ID

# 5. Detach and delete Internet Gateway
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

# 6. Delete subnets
aws ec2 delete-subnet --subnet-id $PUBLIC_SUBNET_ID
aws ec2 delete-subnet --subnet-id $PRIVATE_SUBNET_ID

# 7. Delete route tables
aws ec2 delete-route-table --route-table-id $PUBLIC_RT_ID
aws ec2 delete-route-table --route-table-id $PRIVATE_RT_ID

# 8. Delete VPC
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "Cleanup complete!"
```

## Next Steps

Congratulations! You've created your first VPC. Continue learning:

- **[Security Groups Deep Dive](./security-groups-basics.md)** - Advanced security group patterns
- **[VPC Peering](../../Intermediate-Level/02-Networking-VPC/vpc-peering-guide.md)** - Connect multiple VPCs
- **[Load Balancers](../../Intermediate-Level/02-Networking-VPC/load-balancer-setup.md)** - Distribute traffic
- **[Networking Troubleshooting](./troubleshooting-basics.md)** - Debug common issues

## Quick Reference

```bash
# View all VPC resources
aws ec2 describe-vpcs --vpc-ids $VPC_ID
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID"
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID"

# Tag all resources for easy identification
# Use consistent tags: Name, Environment, Project, Owner
```

## Summary

✅ Created VPC with CIDR 10.0.0.0/16  
✅ Set up public and private subnets  
✅ Configured Internet and NAT Gateways  
✅ Created route tables for traffic flow  
✅ Built security groups for access control  
✅ Tested with EC2 instance  
✅ Learned cleanup procedures  

**Total Time**: ~30 minutes  
**Cost**: ~$0 (Free Tier) or ~$0.10-0.20 for testing

---

**Pro Tip**: Save your VPC IDs and resource IDs in a file or use CloudFormation/Terraform for repeatable deployments!
