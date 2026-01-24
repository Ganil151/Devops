# 💰 FinOps: Cost Optimization as Code (Intermediate)

> **"Infrastructure is only as good as its efficiency. If you don't track cost, you don't scale—you just bleed."**

## 📚 Overview

FinOps is an evolving cloud financial management discipline and cultural practice that enables organizations to get maximum business value by helping engineering, finance, technology and business teams to collaborate on data-driven spending decisions.

## 🎯 Learning Objectives

- ✅ Understand the **Inform, Optimize, Operate** lifecycle.
- ✅ Implement **Infracost** in CI/CD to prevent budget overruns.
- ✅ Deploy **Kubecost** to track internal Kubernetes spending.
- ✅ Automate the identification of "Zombies" (Unused resources).

## 🗺️ Module Structure

1. **[🟢 01-Infracost-CI-CD](./01-Infracost-CI-CD/)**
   - Analyzing plan JSONs.
   - Setting up PR comments for cost changes.
2. **[🟢 02-Kubecost-Basics](./02-Kubecost-Basics/)**
   - Deploying Kubecost via Helm.
   - Mapping costs to Namespaces and Labels.

---

## 🏗️ Visual: Cost-Aware CI/CD Pipeline

```mermaid
graph LR
    A[Git Commit] --> B[CI Runner]
    B --> C[Terraform Plan]
    C --> D{Infracost Check}
    D -- Increase > $50 --> E[Block & Notify]
    D -- Pass --> F[Terraform Apply]
    F --> G[Live Infrastructure]
    G -- Usage Data --> H[Kubecost Dashboard]
    
    style D fill:#f4b400,color:#000
    style E fill:#ee0000,color:#fff
    style H fill:#00b894,color:#fff
```

## 📋 Professional Pattern: The "Zombie Hunter"
Always automate the detection of unused resources. Idle Load Balancers and unattached EBS volumes account for up to 15% of wasted cloud spend in unmanaged environments.

---

## 🛠️ Automation: Zombie Resource Identification (Python)

```python
import boto3

def hunt_zombies():
    ec2 = boto3.client('ec2')
    
    # 1. Unattached EBS Volumes
    volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])
    for vol in volumes['Volumes']:
        print(f"[ZOMBIE] Unused Volume Found: {vol['VolumeId']} ({vol['Size']}GB)")

    # 2. Idle Load Balancers (Classic Example)
    elb = boto3.client('elbv2')
    lbs = elb.describe_load_balancers()
    for lb in lbs['LoadBalancers']:
        # Logic to check request count metrics would go here
        print(f"[AUDIT] LB Active: {lb['LoadBalancerName']}")

if __name__ == "__main__":
    hunt_zombies()
```

---
**Next Step**: [Infracost in CI/CD](./01-Infracost-CI-CD/) 🚀
