# Getting Started Guide

A practical, step-by-step guide to creating your first production-ready VPC.

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Basic understanding of IP addressing
- Text editor or IDE

---

## Step 1: Plan Your VPC

### Design Decisions
<b>1. CIDR Block**: 10.0.0.0/16</b>
<details>
<summary>Show Answer</summary>
Answer: 65,536 IPs
</details>

<b>2. Availability Zones**: 2</b>
<details>
<summary>Show Answer</summary>
Answer: us-east-1a, us-east-1b
</details>

3.  **Subnet Strategy**: Public + Private per AZ
4.  **NAT Strategy**: One NAT Gateway per AZ

### IP Allocation Plan
```
VPC: 10.0.0.0/16

Public Subnets:
- 10.0.1.0/24 (AZ-A) - 251 usable IPs
- 10.0.2.0/24 (AZ-B) - 251 usable IPs

Private Subnets:
- 10.0.11.0/24 (AZ-A) - 251 usable IPs
- 10.0.12.0/24 (AZ-B) - 251 usable IPs
```

---

## Step 2: Create VPC (AWS Console)

### Via AWS Console
1. Navigate to **VPC Dashboard**
2. Click **Create VPC**
<b>3. Select **VPC and more</b>
<details>
<summary>Show Answer</summary>
Answer: creates subnets, route tables, gateways automatically
</details>

4. Configure:
   - **Name**: `production-vpc`
   - **IPv4 CIDR**: `10.0.0.0/16`
   - **Number of AZs**: `2`
   - **Number of public subnets**: `2`
   - **Number of private subnets**: `2`
   - **NAT gateways**: `1 per AZ`
   - **VPC endpoints**: `S3 Gateway`
5. Click **Create VPC**

---

## Step 3: Create VPC (AWS CLI)

### Complete Script
```bash
#!/bin/bash
set -e

# Variables
VPC_CIDR="10.0.0.0/16"
REGION="us-east-1"
AZ_A="${REGION}a"
AZ_B="${REGION}b"

# Create VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=production-vpc}]' \
  --query 'Vpc.VpcId' \
  --output text)

echo "Created VPC: $VPC_ID"

# Enable DNS
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=production-igw}]' \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
echo "Created and attached IGW: $IGW_ID"

# Create Subnets
PUBLIC_SUBNET_A=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone $AZ_A \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-a}]' \
  --query 'Subnet.SubnetId' \
  --output text)

PUBLIC_SUBNET_B=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone $AZ_B \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-b}]' \
  --query 'Subnet.SubnetId' \
  --output text)

PRIVATE_SUBNET_A=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.11.0/24 \
  --availability-zone $AZ_A \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-a}]' \
  --query 'Subnet.SubnetId' \
  --output text)

PRIVATE_SUBNET_B=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.12.0/24 \
  --availability-zone $AZ_B \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-b}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Created subnets"

# Create NAT Gateways
EIP_A=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
NAT_GW_A=$(aws ec2 create-nat-gateway \
  --subnet-id $PUBLIC_SUBNET_A \
  --allocation-id $EIP_A \
  --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=nat-gw-a}]' \
  --query 'NatGateway.NatGatewayId' \
  --output text)

EIP_B=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
NAT_GW_B=$(aws ec2 create-nat-gateway \
  --subnet-id $PUBLIC_SUBNET_B \
  --allocation-id $EIP_B \
  --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=nat-gw-b}]' \
  --query 'NatGateway.NatGatewayId' \
  --output text)

echo "Created NAT Gateways (waiting for availability...)"
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_A $NAT_GW_B

# Create Route Tables
PUBLIC_RT=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=public-rt}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-route --route-table-id $PUBLIC_RT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

aws ec2 associate-route-table --route-table-id $PUBLIC_RT --subnet-id $PUBLIC_SUBNET_A
aws ec2 associate-route-table --route-table-id $PUBLIC_RT --subnet-id $PUBLIC_SUBNET_B

PRIVATE_RT_A=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=private-rt-a}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-route --route-table-id $PRIVATE_RT_A --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW_A
aws ec2 associate-route-table --route-table-id $PRIVATE_RT_A --subnet-id $PRIVATE_SUBNET_A

PRIVATE_RT_B=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=private-rt-b}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-route --route-table-id $PRIVATE_RT_B --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW_B
aws ec2 associate-route-table --route-table-id $PRIVATE_RT_B --subnet-id $PRIVATE_SUBNET_B

echo "VPC setup complete!"
echo "VPC ID: $VPC_ID"
echo "Public Subnets: $PUBLIC_SUBNET_A, $PUBLIC_SUBNET_B"
echo "Private Subnets: $PRIVATE_SUBNET_A, $PRIVATE_SUBNET_B"
```

---

## Step 4: Verify Setup

### Check VPC
```bash
aws ec2 describe-vpcs --vpc-ids $VPC_ID
```

### Check Subnets
```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"
```

### Check Route Tables
```bash
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID"
```

---

## Step 5: Test Connectivity

### Launch Test Instance (Public Subnet)
```bash
# Create security group
SG_ID=$(aws ec2 create-security-group \
  --group-name test-sg \
  --description "Test security group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

# Allow SSH
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Launch instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --subnet-id $PUBLIC_SUBNET_A \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --key-name your-key-pair \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test-instance}]'
```

### Test Internet Access
```bash
# SSH to instance
ssh -i your-key.pem ec2-user@PUBLIC_IP

# Test internet
ping -c 3 8.8.8.8
curl ifconfig.me
```

---

## Step 6: Clean Up (Optional)

```bash
# Terminate instances first
aws ec2 terminate-instances --instance-ids i-xxxxx

# Delete NAT Gateways
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_A
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_B

# Release Elastic IPs
aws ec2 release-address --allocation-id $EIP_A
aws ec2 release-address --allocation-id $EIP_B

# Delete subnets, route tables, IGW, and VPC
# (AWS Console is easier for cleanup)
```

---

## Next Steps

1.  **Add VPC Flow Logs** for monitoring
2.  **Create VPC Endpoints** for S3 and DynamoDB
3.  **Implement Security Groups** for your application
4.  **Set up VPN or Direct Connect** for hybrid connectivity
5.  **Enable AWS Config** for compliance monitoring

---

## 🏗️ Real-Life Scenario: The First VPC
**Engineer**: Junior DevOps engineer creating first VPC
**Mistake**: Forgot to enable DNS hostnames
**Impact**: EC2 instances couldn't resolve AWS service endpoints
**Symptom**: `yum update` failed with "Cannot resolve repository"
**Fix**: Enabled DNS hostnames on VPC
**Lesson**: Always enable DNS hostnames and DNS support when creating VPCs.

---

## ❓ Interview Questions
1.  **What are the minimum components needed for a functional VPC?**
    *   *Answer*: VPC with CIDR block, at least one subnet, Internet Gateway (for internet access), route table with route to IGW, and security group allowing required traffic.
2.  **Why should you enable DNS hostnames in a VPC?**
    *   *Answer*: It allows instances to receive public DNS names, which is required for many AWS services and makes it easier to connect to instances without remembering IP addresses.

---

## 🧠 Final Quiz (5/20+)
<b>1. What is the first step in creating a VPC?</b>
<details>
<summary>Show Answer</summary>
Answer: Planning CIDR and subnet allocation
</details>

<b>2. True/False: You must wait for NAT Gateway to be available before creating routes.</b>
<details>
<summary>Show Answer</summary>
Answer: True
</details>

<b>3. Should you enable DNS support in VPC?</b>
<details>
<summary>Show Answer</summary>
Answer: Yes
</details>

<b>4. How many AZs minimum for production?</b>
<details>
<summary>Show Answer</summary>
Answer: 2
</details>

<b>5. What command creates a VPC via CLI?</b>
<details>
<summary>Show Answer</summary>
Answer: `aws ec2 create-vpc`
</details>
