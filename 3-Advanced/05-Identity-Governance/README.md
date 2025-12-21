# Identity Management & Governance

Who has access to what? This module explores the critical domain of Identity and Access Management (IAM) and how to govern large-scale cloud environments for security and compliance.

---

## 1. The Principle of Least Privilege (PoLP)

PoLP is the most important rule in security. It states that a user or service should have only the minimum permissions required to perform its task—and nothing more.
- **Avoid `AdministratorAccess`**: Use granular permissions.
- **Service Roles**: Give applications their own identities rather than using user keys.
- **Time-Bound Access**: Use temporary credentials instead of long-lived passwords.

---

## 2. Governance vs. Management

- **Management**: The act of creating users, groups, and roles.
- **Governance**: The set of rules and audits that ensure management is done correctly (e.g., "All S3 buckets must be encrypted").

---

## 3. Core Tooling

- **AWS IAM**: The backbone of AWS security.
- **AWS Config**: Monitoring your resource configurations over time.
- **Open Policy Agent (OPA)**: A general-purpose policy engine to enforce rules across your stack.
- **IAM Access Analyzer**: Finding resources shared with external accounts.

---

## 4. Best Practices
1. **Enforce MFA**: Multi-Factor Authentication for all human users.
2. **Regular Audits**: Use Access Analyzer to find unused permissions and remove them.
3. **Tag Everything**: Use tags for cost allocation and access control (TBAC).

---
**Compliance**: Learn how to automate these checks in the [DevSecOps Module](../04-Security/README.md).
