# AWS Networking and VPC Guide for DevOps Engineers

## VPC Overview

Amazon Virtual Private Cloud (VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment.

## VPC Core Components

### VPC Creation and Configuration

```bash
# Create VPC
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --amazon-provided-ipv6-cidr-block \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=DevOps-VPC},{Key=Environment,Value=Production}]'

# Modify VPC attributes
aws ec2 modify-vpc-attribute \
    --vpc-id vpc-12345678 \
    --enable-dns-hostnames

aws ec2 modify-vpc-attribute \
    --vpc-id vpc-12345678 \
    --enable-dns-support

# Describe VPCs
aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=DevOps-VPC" \
    --output table

# Delete VPC (must delete all resources first)
aws ec2 delete-vpc --vpc-id vpc-12345678
```

### Subnets

```bash
# Create public subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=DevOps-Public-Subnet-1a},{Key=Type,Value=Public}]'

# Create private subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=DevOps-Private-Subnet-1a},{Key=Type,Value=Private}]'

# Create database subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.3.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=DevOps-DB-Subnet-1a},{Key=Type,Value=Database}]'

# Enable auto-assign public IP for public subnet
aws ec2 modify-subnet-attribute \
    --subnet-id subnet-12345678 \
    --map-public-ip-on-launch

# List subnets
aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=vpc-12345678" \
    --query 'Subnets[].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' \
    --output table
```


### Internet Gateway and NAT Gateway

```bash
# Create Internet Gateway
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=DevOps-IGW}]'

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id igw-12345678 \
    --vpc-id vpc-12345678

# Create NAT Gateway (for private subnets)
aws ec2 create-nat-gateway \
    --subnet-id subnet-12345678 \
    --allocation-id eipalloc-12345678
```

### Route Tables

```bash
# Create route table
aws ec2 create-route-table \
    --vpc-id vpc-12345678

# Add route to Internet Gateway
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id igw-12345678

# Associate with subnet
aws ec2 associate-route-table \
    --route-table-id rtb-12345678 \
    --subnet-id subnet-12345678
```

## Security Groups and NACLs

### Security Groups (Stateful)
Security groups act as a virtual firewall for your EC2 instances to control incoming and outgoing traffic.

```bash
# Create security group
aws ec2 create-security-group \
    --group-name DevOps-WebServer-SG \
    --description "Security group for DevOps web servers" \
    --vpc-id vpc-12345678

# Allow HTTP ingress
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

### Network ACLs (Stateless)
Network ACLs allow or deny traffic into and out of your subnets.

```bash
# Create custom Network ACL
aws ec2 create-network-acl \
    --vpc-id vpc-12345678

# Allow inbound HTTP
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0
```

This guide covers the fundamental building blocks of AWS Networking. For advanced topics like Peering, Transit Gateways, and Load Balancing, please refer to the Intermediate and Advanced guides.