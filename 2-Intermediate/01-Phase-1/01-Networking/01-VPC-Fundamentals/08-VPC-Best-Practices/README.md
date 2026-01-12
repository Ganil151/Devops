# VPC Best Practices

Following AWS Well-Architected Framework principles ensures secure, reliable, and cost-effective VPC designs.

## Security Best Practices

### 1. Use Private Subnets by Default
- Place databases, app servers, and internal services in private subnets
- Only web-facing resources in public subnets
- Use bastion hosts or AWS Systems Manager Session Manager for access

### 2. Implement Defense in Depth
```
Internet
  ↓
WAF (Web Application Firewall)
  ↓
ALB (Application Load Balancer)
  ↓
Security Group (Instance-level)
  ↓
NACL (Subnet-level)
  ↓
Application
```

### 3. Principle of Least Privilege
- Security groups: Only allow required ports
- Source restrictions: Use specific CIDRs, not 0.0.0.0/0
- Security group references: Reference other SGs instead of IP ranges

### 4. Enable VPC Flow Logs
```bash
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-xxxxx \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /aws/vpc/flowlogs
```

---

## Reliability Best Practices

### 1. Multi-AZ Design
Always deploy across at least 2 Availability Zones:
```
VPC: 10.0.0.0/16
├── AZ-A
│   ├── Public: 10.0.1.0/24
│   └── Private: 10.0.11.0/24
└── AZ-B
    ├── Public: 10.0.2.0/24
    └── Private: 10.0.12.0/24
```

### 2. NAT Gateway Redundancy
Deploy one NAT Gateway per AZ:
```bash
# NAT Gateway in AZ-A
aws ec2 create-nat-gateway \
  --subnet-id subnet-public-a \
  --allocation-id eipalloc-a

# NAT Gateway in AZ-B
aws ec2 create-nat-gateway \
  --subnet-id subnet-public-b \
  --allocation-id eipalloc-b
```

### 3. Route Table per AZ
Each AZ's private subnet should route to its own NAT Gateway:
```
Private Subnet AZ-A → NAT Gateway AZ-A
Private Subnet AZ-B → NAT Gateway AZ-B
```

---

## Performance Best Practices

### 1. Use VPC Endpoints
Avoid NAT Gateway for AWS services:
```bash
# S3 Gateway Endpoint (Free!)
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-xxxxx \
  --service-name com.amazonaws.us-east-1.s3 \
  --route-table-ids rtb-xxxxx

# DynamoDB Gateway Endpoint (Free!)
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-xxxxx \
  --service-name com.amazonaws.us-east-1.dynamodb \
  --route-table-ids rtb-xxxxx
```

### 2. Enable Enhanced Networking
Use instance types that support enhanced networking (ENA):
- C5, M5, R5, T3 families
- Up to 100 Gbps network bandwidth

### 3. Placement Groups
For low-latency applications:
- **Cluster**: Pack instances close together (HPC)
- **Partition**: Spread across logical partitions (Hadoop, Cassandra)
- **Spread**: Spread across underlying hardware (critical instances)

---

## Cost Optimization Best Practices

### 1. Minimize NAT Gateway Costs
- Use VPC Endpoints for S3/DynamoDB (saves $0.045/GB)
- Consolidate NAT Gateways (one per AZ, not per subnet)
- For dev/test, consider single NAT Gateway

### 2. Right-Size Subnets
Don't over-allocate IP space:
- /24 (251 IPs) for most workloads
- /22 (1,019 IPs) for large clusters
- /28 (11 IPs) for NAT Gateway subnets

### 3. Use Reserved Capacity
For predictable workloads, reserve:
- NAT Gateway bandwidth
- VPN connections
- Direct Connect ports

---

## Operational Excellence Best Practices

### 1. Infrastructure as Code
Always use IaC for VPC creation:
```hcl
# Terraform example
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

tags = {
    Name        = "production-vpc"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### 2. Tagging Strategy
Consistent tagging for cost allocation and management:
```
Name: production-vpc
Environment: prod
Owner: platform-team
CostCenter: engineering
Project: main-app
ManagedBy: terraform
```

### 3. Documentation
Maintain network diagrams and IP allocation spreadsheets:
- CIDR allocation plan
- Subnet purpose and sizing
- Security group rules documentation
- Route table configurations

---

## Compliance Best Practices

### 1. Encryption in Transit
- Use TLS/SSL for all traffic
- Enable VPN encryption for hybrid connectivity
- Use AWS Certificate Manager for certificates

### 2. Audit Logging
- Enable VPC Flow Logs
- Enable CloudTrail for API calls
- Send logs to centralized SIEM

### 3. Network Segmentation
- Separate compliance workloads (PCI-DSS, HIPAA)
- Use separate VPCs or accounts
- Implement strict security groups

---

## Naming Conventions

### Consistent Naming Pattern
```
{environment}-{purpose}-{az}-{type}

Examples:
prod-web-a-public      (Production web tier, AZ-A, public subnet)
prod-app-b-private     (Production app tier, AZ-B, private subnet)
stage-data-a-private   (Staging data tier, AZ-A, private subnet)
```

---

## 🏗️ Real-Life Scenario: The Single NAT Gateway Outage
**Setup**: Company uses single NAT Gateway for cost savings.
**Incident**: NAT Gateway's AZ experiences outage.
**Impact**: All private subnet instances lose internet access.
**Duration**: 4 hours (AWS AZ recovery time).
**Cost**: $100k in lost revenue.
**Fix**: Deployed NAT Gateway in each AZ ($90/month extra).
**Lesson**: High availability is worth the cost. Don't skimp on critical infrastructure.

---

## ❓ Interview Questions
1.  **What is defense in depth and how does it apply to VPCs?**
    *   *Answer*: Defense in depth means implementing multiple layers of security controls. In VPCs, this includes WAF, load balancers, security groups, NACLs, and application-level security. If one layer is breached, others provide protection.
2.  **Why should you deploy one NAT Gateway per AZ instead of sharing one across AZs?**
    *   *Answer*: For high availability. If the AZ hosting the NAT Gateway fails, all other AZs lose internet connectivity. Deploying one NAT Gateway per AZ ensures each AZ can independently access the internet even if other AZs fail.

---

## 🧠 Quiz Snippet (5/20+)
<b>1. Should databases be in public or private subnets?</b>
<details>
<summary>Show Answer</summary>
Answer: Private
</details>

<b>2. True/False: You should use 0.0.0.0/0 as source in security groups.</b>
<details>
<summary>Show Answer</summary>
Answer: False - use specific CIDRs
</details>

<b>3. What is the minimum number of AZs for high availability?</b>
<details>
<summary>Show Answer</summary>
Answer: 2
</details>

<b>4. Are S3 VPC Endpoints free?</b>
<details>
<summary>Show Answer</summary>
Answer: Yes - gateway endpoints are free
</details>

<b>5. Should you use Infrastructure as Code for VPCs?</b>
<details>
<summary>Show Answer</summary>
Answer: Yes
</details>
