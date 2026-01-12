# AWS Config & Governance Guide

AWS Config is a service that enables you to assess, audit, and evaluate the configurations of your AWS resources. It continuously monitors and records your AWS resource configurations and allows you to automate the evaluation of recorded configurations against desired configurations.

## 1. Why Governance Matters?

In a DevOps environment, rapid changes can lead to "configuration drift" where resources no longer comply with security or operational standards.
- **Compliance**: Ensure all S3 buckets are encrypted.
- **Audit**: Track who changed a security group rule and when.
- **Remediation**: Automatically fix non-compliant resources.

## 2. Core Concepts

- **Configuration Item (CI)**: A point-in-time record of a resource's attributes (e.g., an EC2 instance's type, tags, and network settings).
- **Configuration History**: A collection of CIs for a resource over time.
- **AWS Config Rules**: Desired configuration settings for specific resources or for your entire AWS account.
- **Conformance Packs**: A collection of Config rules and remediation actions that can be deployed as a single entity.

## 3. Hands-on: Enabling AWS Config & Rules (CLI)

### 1. Set up the Configuration Recorder
```bash
# Create the recorder
aws configservice subscribe \
    --s3-bucket devops-config-bucket \
    --iam-role arn:aws:iam::123456789012:role/config-role
```

### 2. Add a Managed Rule (e.g., S3 Bucket Public Read Prohibited)
```bash
aws configservice put-config-rule \
    --config-rule '{
        "ConfigRuleName": "s3-bucket-public-read-prohibited",
        "Source": {
            "Owner": "AWS",
            "SourceIdentifier": "S3_BUCKET_PUBLIC_READ_PROHIBITED"
        }
    }'
```

## 4. Automated Remediation

You can configure AWS Config to automatically fix resources that fail a rule using **Systems Manager Automation documents**.

1. **Detection**: AWS Config rule finds a non-compliant resource (e.g., unencrypted S3 bucket).
2. **Trigger**: AWS Config triggers an SSM Automation document.
3. **Remediation**: The SSM document encrypts the bucket automatically.

## 5. Multi-Account Governance: AWS Organizations & Aggregators

- **Aggregators**: Collect configuration and compliance data from multiple accounts and regions into a single "Master" account.
- **Organization Rules**: Deploy Config rules across all accounts in an AWS Organization with a single command.

## 6. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **No resources being recorded** | Configuration recorder not started | Run `aws configservice start-configuration-recorder`. |
| **Rule evaluation is "Insufficient Data"** | Resource type not being recorded | Ensure the recorder is set to record "All supported resources". |
| **Remediation fails** | SSM Role lacks permissions | Verify the IAM role used for remediation has permissions to modify the target resource (e.g., `s3:PutEncryptionConfiguration`). |
| **High Costs** | Recording ephemeral resources (e.g., high-churn EMR nodes) | Use **Resource Type Filters** to exclude high-churn resources from being recorded. |

---

## Governance Best Practices Checklist
- [ ] Enable **AWS Config** in all regions where you have resources.
- [ ] Use **Managed Rules** for common security checks (S3 public access, IAM MFA, etc.).
- [ ] Implement **Aggregators** for centralized visibility in multi-account setups.
- [ ] Use **Conformance Packs** for standardized compliance (e.g., PCI-DSS, HIPAA).
- [ ] Continuously monitor for **Configuration Drift** using the Config Dashboard.
