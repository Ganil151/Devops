# VPC Limits and Quotas

Understanding AWS VPC limits helps you design scalable architectures and avoid hitting quotas.

## VPC-Level Limits

| Resource | Default Limit | Hard Limit | Adjustable |
| :--- | :--- | :--- | :--- |
| **VPCs per Region** | 5 | No hard limit | Yes |
| **Subnets per VPC** | 200 | No hard limit | Yes |
| **IPv4 CIDR blocks per VPC** | 5 (1 primary + 4 secondary) | 5 | No |
| **IPv6 CIDR blocks per VPC** | 1 | 1 | No |
| **Elastic IPs per Region** | 5 | No hard limit | Yes |
| **Internet Gateways per VPC** | 1 | 1 | No |
| **Egress-only IGWs per VPC** | 5 | No hard limit | Yes |

---

## Routing Limits

| Resource | Default Limit | Adjustable |
| :--- | :--- | :--- |
| **Route tables per VPC** | 200 | Yes |
| **Routes per route table** | 50 | Yes (up to 1,000) |
| **BGP advertised routes** | 100 | No |

---

## Security Limits

| Resource | Default Limit | Adjustable |
| :--- | :--- | :--- |
| **Security groups per VPC** | 2,500 | Yes |
| **Rules per security group** | 60 inbound + 60 outbound | Yes (up to 120 each) |
| **Security groups per network interface** | 5 | Yes (up to 16) |
| **Network ACLs per VPC** | 200 | Yes |
| **Rules per Network ACL** | 20 inbound + 20 outbound | Yes (up to 40 each) |

---

## Gateway and Connectivity Limits

| Resource | Default Limit | Adjustable |
| :--- | :--- | :--- |
| **NAT Gateways per AZ** | 5 | Yes |
| **VPC Peering connections per VPC** | 50 | Yes (up to 125) |
| **Active VPN connections per VPC** | 10 | No |
| **Customer gateways per Region** | 50 | Yes |
| **Virtual private gateways per Region** | 5 | Yes |

---

## VPC Endpoint Limits

| Resource | Default Limit | Adjustable |
| :--- | :--- | :--- |
| **Gateway endpoints per VPC** | 20 | Yes |
| **Interface endpoints per VPC** | 50 | Yes |

---

## Network Interface Limits

| Resource | Default Limit | Adjustable |
| :--- | :--- | :--- |
| **Network interfaces per instance** | Varies by instance type | No |
| **Network interfaces per Region** | 5,000 | Yes |
| **IPv4 addresses per network interface** | 50 (varies by instance type) | No |

---

## Practical Implications

### Scenario 1: Large Enterprise
**Requirement**: 100 VPCs across multiple accounts
**Solution**: 
- Use AWS Organizations
- 5 VPCs per region × 20 regions = 100 VPCs
- Or request limit increase for specific regions

### Scenario 2: Complex Routing
**Requirement**: 200 routes for VPN and peering
**Problem**: Default limit is 50 routes per table
**Solution**: Request increase to 1,000 routes

### Scenario 3: Microservices Architecture
**Requirement**: 500 security groups
**Status**: Within default limit (2,500)
**Best Practice**: Use security group references instead of CIDR blocks

---

## Requesting Limit Increases

### Via AWS Console
1. Navigate to Service Quotas
2. Select Amazon VPC
3. Find the quota
4. Click "Request quota increase"
5. Provide justification

### Via AWS CLI
```bash
aws service-quotas request-service-quota-increase \
  --service-code vpc \
  --quota-code L-F678F1CE \
  --desired-value 10
```

### Via AWS Support
Open a support case for limits that can't be increased via Service Quotas.

---

## Monitoring Quota Usage

### AWS CLI
```bash
# Check current VPC count
aws ec2 describe-vpcs --query 'length(Vpcs)'

# Check security group count
aws ec2 describe-security-groups --query 'length(SecurityGroups)'

# Check route table count
aws ec2 describe-route-tables --query 'length(RouteTables)'
```

### CloudWatch Metrics
Set up alarms for approaching limits:
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name vpc-limit-warning \
  --alarm-description "Alert when approaching VPC limit" \
  --metric-name VPCCount \
  --namespace Custom/VPC \
  --statistic Maximum \
  --period 300 \
  --threshold 4 \
  --comparison-operator GreaterThanThreshold
```

---

## Design Patterns to Avoid Limits

### 1. Use Transit Gateway Instead of VPC Peering
- VPC Peering: 125 connections max
- Transit Gateway: Thousands of VPCs

### 2. Consolidate Security Groups
- Use security group references
- Group similar resources
- Avoid duplicate rules

### 3. Use VPC Endpoints
- Reduces NAT Gateway usage
- No limit on endpoint usage per resource

### 4. Implement Hub-and-Spoke
- Central VPC for shared services
- Reduces total VPC count

---

## 🏗️ Real-Life Scenario: The Route Table Limit
**Problem**: Company has 80 VPN connections to branch offices.
**Issue**: Hit 50-route limit per route table.
**Impact**: Can't add new branch offices.
**Attempted Fix**: Create multiple route tables (doesn't work - subnets need all routes).
**Actual Fix**: 
1. Requested increase to 200 routes
<b>2. Implemented route summarization</b>
<details>
<summary>Show Answer</summary>
Answer: reduced to 40 routes
</details>

3. Migrated to Transit Gateway for future scalability
**Lesson**: Plan for growth and understand limits before hitting them.

---

## ❓ Interview Questions
1.  **What is the default limit for VPCs per region and can it be increased?**
    *   *Answer*: The default limit is 5 VPCs per region, and yes, it can be increased through AWS Service Quotas. There is no hard upper limit, but increases are reviewed by AWS.
2.  **How would you design a network for 200 VPCs that need to communicate?**
    *   *Answer*: Use AWS Transit Gateway instead of VPC Peering. Transit Gateway can connect thousands of VPCs, while VPC Peering has a limit of 125 connections per VPC. Transit Gateway also simplifies routing and management.

---

## 🧠 Quiz Snippet (5/20+)
<b>1. What is the default VPC limit per region?</b>
<details>
<summary>Show Answer</summary>
Answer: 5
</details>

<b>2. True/False: You can have unlimited routes per route table.</b>
<details>
<summary>Show Answer</summary>
Answer: False - default 50, max 1,000
</details>

<b>3. How many IGWs can attach to one VPC?</b>
<details>
<summary>Show Answer</summary>
Answer: 1
</details>

<b>4. What is the max VPC peering connections per VPC?</b>
<details>
<summary>Show Answer</summary>
Answer: 125
</details>

<b>5. Can you increase the security groups per VPC limit?</b>
<details>
<summary>Show Answer</summary>
Answer: Yes
</details>
