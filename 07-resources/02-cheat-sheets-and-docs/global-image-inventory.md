# 🌍 Global Cloud Image Inventory
> **Source of Truth for Multi-Cloud Curriculum**

This document serves as the centralized repository for current, Free-Tier eligible Cloud Images across AWS, Azure, and GCP. 

## 🛡️ Senior Architect's Note: Finding vs. Hardcoding
Hardcoding Image IDs (AMIs) in documentation is a common "documentation debt" trap. Cloud providers cycle these IDs frequently for security patches and optimizations. 

**The Rule**: In production, always use **Dynamic Data Sources** (Terraform `data` blocks or Boto3 filters) to fetch the latest ID programmatically.

---

## 🅰️ Part 1: AWS AMIs (Amazon Machine Images)
*Note: AMIs are **Region-Specific**. The IDs below are for `us-east-1` (N. Virginia).*

| OS | Region | AMI ID (Example) | Free Tier |
| :--- | :--- | :--- | :--- |
| **Amazon Linux 2023** | us-east-1 | `ami-053b0d53c279acc90` | ✅ Yes |
| **Ubuntu 22.04 LTS** | us-east-1 | `ami-0c7217cdde317cfec` | ✅ Yes |
| **Red Hat Enterprise Linux 9** | us-east-1 | `ami-01648a0f02309241b` | ✅ Yes |

### 🛠️ Junior Pro-Tip: How to find IDs manually
Use the AWS CLI to find the latest Amazon Linux 2023 ID in your current region:
```bash
aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=al2023-ami-*-x86_64" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text
```

---

## 🟦 Part 2: Azure Compute Images
*Azure uses a URN format (Publisher:Offer:SKU:Version).*

| OS | Publisher | Offer | SKU |
| :--- | :--- | :--- | :--- |
| **Ubuntu 22.04** | `Canonical` | `0001-com-ubuntu-server-jammy` | `22_04-lts` |
| **Windows Server 2022** | `MicrosoftWindowsServer` | `WindowsServer` | `2022-datacenter-g2` |
| **Debian 12** | `debian` | `debian-12` | `12-gen2` |

---

## 🟧 Part 3: Google Cloud (GCP) Images
*GCP uses Image Families for automatic tracking of the latest version.*

| OS | Image Family | Project |
| :--- | :--- | :--- |
| **Debian 12** | `debian-12` | `debian-cloud` |
| **Ubuntu 22.04** | `ubuntu-2204-lts` | `ubuntu-os-cloud` |
| **CentOS Stream 9** | `centos-stream-9` | `centos-cloud` |

---

## 🚀 Automation Snippets (The "Professional" Way)

### Terraform Data Source
```hcl
data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

### Python (Boto3)
```python
import boto3

ec2 = boto3.client('ec2', region_name='us-east-1')
response = ec2.describe_images(
    Owners=['amazon'],
    Filters=[{'Name': 'name', 'Values': ['al2023-ami-*-x86_64']}]
)
# Sort by creation date and get the latest
latest_ami = sorted(response['Images'], key=lambda x: x['CreationDate'])[-1]['ImageId']
print(f"Latest AMI ID: {latest_ami}")
```

---
*Created by Cloud Architect and Inventory Manager*
