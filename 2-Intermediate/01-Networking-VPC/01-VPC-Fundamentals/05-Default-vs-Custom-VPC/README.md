# Default vs. Custom VPC

AWS provides a default VPC in every region, but custom VPCs offer more control and better security.

## Default VPC

### Characteristics
- **CIDR**: 172.31.0.0/16 (65,536 IPs)
- **Subnets**: One /20 subnet per AZ (4,096 IPs each)
- **Internet Gateway**: Pre-attached
- **Route Table**: Public route (0.0.0.0/0 -> IGW) by default
- **DNS**: Enabled (hostnames and resolution)
- **Public IPs**: Auto-assigned to instances

### Advantages
- **Quick Start**: Launch instances immediately
- **Beginner-Friendly**: No networking knowledge required
- **Testing**: Perfect for learning and experimentation

### Disadvantages
- **Security**: All subnets are public by default
- **Limited Control**: Can't change CIDR block
- **Not Production-Ready**: Lacks proper network segmentation
- **Compliance**: May not meet security requirements

---

## Custom VPC

### Characteristics
- **CIDR**: You choose (e.g., 10.0.0.0/16)
- **Subnets**: You design (public/private, multi-tier)
- **Gateways**: You configure (IGW, NAT, VPN)
- **Route Tables**: You define routing logic
- **Security**: Layered (public/private subnets, NACLs, SGs)

### Advantages
- **Full Control**: Design network topology
- **Security**: Proper isolation and segmentation
- **Compliance**: Meet regulatory requirements
- **Scalability**: Plan for growth
- **Best Practices**: Implement defense in depth

### Disadvantages
- **Complexity**: Requires networking knowledge
- **Setup Time**: More configuration required
- **Responsibility**: You manage all components

---

## Comparison Table

| Feature | Default VPC | Custom VPC |
| :--- | :--- | :--- |
| **CIDR Block** | 172.31.0.0/16 (fixed) | Your choice |
| **Subnets** | Public only | Public + Private |
| **Internet Gateway** | Pre-attached | You attach |
| **Route Tables** | Public routes | You configure |
| **NAT Gateway** | None | You create |
| **Public IPs** | Auto-assigned | You configure |
| **Security** | Basic | Advanced (multi-layer) |
| **Production Use** | Not recommended | Recommended |
| **Compliance** | May not meet requirements | Customizable |
| **Learning Curve** | Easy | Moderate |

---

## When to Use Each

### Use Default VPC For:
- Learning AWS
- Quick testing/prototyping
- Temporary workloads
- Non-production environments
- Simple applications with no sensitive data

### Use Custom VPC For:
- Production workloads
- Multi-tier applications
- Compliance requirements (PCI-DSS, HIPAA, SOC 2)
- Hybrid cloud (VPN/Direct Connect)
- Enterprise applications
- Any application handling sensitive data

---

## Migration from Default to Custom VPC

### Step 1: Design Custom VPC
```
VPC: 10.0.0.0/16
├── Public Subnets (Web Tier)
│   ├── 10.0.1.0/24 (AZ-A)
│   └── 10.0.2.0/24 (AZ-B)
└── Private Subnets (App/Data Tier)
    ├── 10.0.11.0/24 (AZ-A)
    └── 10.0.12.0/24 (AZ-B)
```

### Step 2: Create Infrastructure
- Create VPC
- Create subnets
- Attach IGW
- Create NAT Gateway
- Configure route tables
- Set up security groups

### Step 3: Migrate Workloads
- Launch new instances in custom VPC
- Migrate data
- Update DNS/load balancers
- Test thoroughly
- Decommission old instances

---

## Default VPC Deletion

**Warning**: Deleting the default VPC is permanent and cannot be undone through the console.

### To Delete:
```bash
# List default VPC
aws ec2 describe-vpcs --filters "Name=isDefault,Values=true"

# Delete default VPC (use with caution!)
aws ec2 delete-vpc --vpc-id vpc-xxxxx
```

### To Recreate:
```bash
# Recreate default VPC
aws ec2 create-default-vpc
```

**Best Practice**: Keep default VPC for testing, use custom VPCs for production.

---

## 🏗️ Real-Life Scenario: The Default VPC Breach
**Company**: Startup using default VPC for production.
**Setup**: All EC2 instances in default VPC with public IPs.
**Incident**: Database server accidentally launched in default VPC with public IP.
**Attack**: Port scanner found open port 3306 (MySQL), brute-forced password.
**Impact**: Data breach, $250k fine, customer trust lost.
**Root Cause**: Default VPC makes everything public by default.
**Fix**: Migrated to custom VPC with proper public/private subnet separation.
**Lesson**: Never use default VPC for production workloads.

---

## ❓ Interview Questions
1.  **What is the main security risk of using the default VPC for production?**
    *   *Answer*: All subnets in the default VPC are public by default with routes to the Internet Gateway. Instances automatically receive public IPs, making them directly accessible from the internet unless explicitly restricted by security groups.
2.  **Can you modify the CIDR block of the default VPC?**
    *   *Answer*: No, the default VPC always uses 172.31.0.0/16 and this cannot be changed. You can add secondary CIDR blocks, but the primary CIDR is fixed.

---

## 🧠 Quiz Snippet (5/20+)
1.  **What is the CIDR of the default VPC?** (172.31.0.0/16)
2.  **True/False: Default VPC subnets are private.** (False - they're public)
3.  **Should you use default VPC for production?** (No)
4.  **Can you recreate a deleted default VPC?** (Yes - via AWS CLI)
5.  **Do instances in default VPC get public IPs automatically?** (Yes)
