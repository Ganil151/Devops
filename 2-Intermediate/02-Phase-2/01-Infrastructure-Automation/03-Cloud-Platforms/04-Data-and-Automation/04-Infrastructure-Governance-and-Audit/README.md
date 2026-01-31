# ⚖️ Infrastructure Governance and Audit

Governance is the framework of rules and practices by which a company ensures its cloud resources are compliant, secure, and cost-effective.

![Governance Architecture Placeholder](Descriptive Diagram: A continuous audit loop showing a resource change triggering an EventBridge event, which AWS Config evaluates against a rule, and a Lambda function auto-remediates by adding a missing tag or disabling public access.)

## 🚀 The "DevOps Why": Compliance at Scale
In a large organization with 1,000+ engineers, you cannot manually check if every S3 bucket is public or if every VM has an owner tag. You must **Automate Governance**.

---

## 🏗️ Core Governance Tools

| Tool Type | Service (AWS) | Service (Azure) | Service (GCP) |
| :--- | :--- | :--- | :--- |
| **Activity Logging** | CloudTrail | Activity Log | Cloud Audit Logs |
| **Config Audit** | AWS Config | Azure Policy | Security Command Center|
| **Policy as Code** | SCP (Orgs) | Azure Blueprints | Organization Policies |
| **Tagging** | Resource Groups | Tagging Policies | Resource Manager Tags |

---

## 🔧 Automation Patterns

### 1. Tagging Enforcement
Using automation to terminate or stop any resource created without a `CostCenter` or `Project` tag. This ensures clear billing accountability.

### 2. Auto-Remediation
If a security group is opened to `0.0.0.0/0` (Global access) for port 22, a Lambda function is triggered to immediately revert that change and notify the security team.

---

### 💰 FinOps Tip: Tag-Based Billing
Ensure 100% tagging coverage. Resources without tags are "Ghost Spend" that cannot be optimized because you don't know who owns them.
