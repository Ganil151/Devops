# AWS Config: Configuration Compliance

AWS Config is a service that enables you to assess, audit, and evaluate the configurations of your AWS resources. It continuously monitors and records your AWS resource configurations and allows you to automate the evaluation of recorded configurations against desired settings.

---

## 1. How it Works
1. **Discovery**: AWS Config identifies all supported AWS resources in your account.
2. **Recording**: It records the state of each resource whenever a configuration change occurs.
3. **Evaluation**: It checks the recorded state against **Config Rules**.

---

## 2. Core Components

### 📏 Config Rules
- **Managed Rules**: Predefined rules provided by AWS (e.g., `s3-bucket-public-read-prohibited`, `iam-password-policy`).
- **Custom Rules**: Rules you define using AWS Lambda.

### 📜 Configuration History & Snapshots
- **Configuration Item (CI)**: A point-in-time record of a resource's configuration.
- **Timeline**: A visual history of how a resource has changed over time.

---

## 3. Compliance & Remediation

### Auto-Remediation
One of the most powerful features of Config is the ability to automatically fix non-compliant resources using **SSM Automation Documents**.

**Example Flow**:
- **Rule**: `restricted-ssh` (Checks if Port 22 is open to `0.0.0.0/0`).
- **Remediation**: If non-compliant, trigger an SSM Document to remove the offending security group rule.

---

## 4. Use Cases
- **Compliance Auditing**: Ensuring all EBS volumes are encrypted.
- **Change Management**: Tracking what changed and when before a production outage.
- **Security Analysis**: Identifying resources with overly permissive access.

---

**Next Step**: Explore automated threat detection with **[AWS GuardDuty](../03-AWS-GuardDuty/README.md)**.
