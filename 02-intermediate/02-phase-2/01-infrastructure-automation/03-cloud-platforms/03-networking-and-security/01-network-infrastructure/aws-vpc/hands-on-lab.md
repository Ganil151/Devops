# 🛠️ Hands-On Lab: The Secure 3-Tier Architecture
> **Mission: Build a production-ready VPC that survives an AZ outage and keeps data isolated.**

## 📋 Prerequisites
- AWS Account with CLI access.
- Basic understanding of `ip` and `curl` commands.

---

## 🏗️ Phase 1: Infrastructure as Code (Terraform)
While you can click through the console, an Intermediate Engineer uses automation.

```hcl
# main.tf snippet
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sre-lab-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets = ["10.10.11.0/24", "10.10.12.0/24"]
  database_subnets = ["10.10.21.0/24", "10.10.22.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # Save cost for lab

  enable_dns_hostnames = true
}
```

---

## 🧪 Phase 2: The Connectivity Challenge
**Scenario**: You have an app in the `private_subnet` that needs to upload logs to S3.

### Step 1: Prove it's broken
Log into your private instance (via SSM Session Manager) and run:
```bash
# This uses the NAT Gateway (Costs $)
curl -I https://s3.amazonaws.com
```

### Step 2: Fix it with Zero-Cost PrivateLink
1. Go to **VPC Console** -> **Endpoints**.
2. Create Endpoint: `com.amazonaws.us-east-1.s3` (Type: **Gateway**).
3. Select the **Private Route Table**.
4. **Verify**: Run the curl again. Notice the latency drop and lower NAT usage in Flow Logs.

---

## 🔍 Phase 3: Traffic Auditing (The Terminal Lab)
Identify which IP is "scanning" your network.

### Step 1: Enable Flow Logs
```bash
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-123456 \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name /aws/vpc/sre-lab-logs
```

### Step 2: Analyze Rejections
Use CloudWatch Logs Insights to find blocked traffic:
```sql
fields @timestamp, srcAddr, dstAddr, destPort, action
| filter action="REJECT"
| stats count(*) as rejectCount by srcAddr
| sort rejectCount desc
```

---

## 🏆 Graduation Challenge
1. Create a **Security Group Chain**: `Web-SG` (Allows 80) -> `App-SG` (Allows 8080 from `Web-SG`).
2. Deploy a second VPC and **Peer** them.
3. **Troubleshoot**: Why can't VPC B ping VPC A? (Check Route Tables AND Security Groups!)

---
#aws #lab #vpc #sre #challenge
