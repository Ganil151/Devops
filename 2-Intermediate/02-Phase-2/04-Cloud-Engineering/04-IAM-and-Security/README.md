# Security, IAM & Identity - Intermediate

Security is "Job Zero" in the cloud. This module covers Identity & Access Management (IAM), application authentication, and secure secrets handling.

---

## 1. The Power of Identity

In the cloud, **Identity is the new perimeter**. IAM allows you to manage who can access your resources (Authentication) and what actions they can perform (Authorization).

### The Three Pillars
- **Users**: Long-term credentials for humans or applications.
- **Groups**: Collections of users with shared permissions.
- **Roles**: Temporary credentials for services (EC2, Lambda) or federated users.

---

## 2. Guides in this Module

### 🔐 IAM Core
- **[IAM Comprehensive Guide](aws-iam-comprehensive.md)**: Users, groups, and policies.
- **[Auth Deep Dive](auth-deep-dive.md)**: Advanced auth strategies and federation.

### 🆔 Application Identity
- **[Amazon Cognito Hands-on](cognito-hands-on.md)**: Implement User Pools for web/mobile apps.

### 🔑 Security Secrets
- **[Secrets Best Practices](secrets-best-practices.md)**: Managing passwords and keys with KMS and Secrets Manager.

---

## 3. Best Practices (The IAM Gold Standard)

1.  **Least Privilege**: Grant only the permissions required for the task.
2.  **MFA Everywhere**: Enable Multi-Factor Authentication for all human users.
3.  **Rotate Frequently**: Automatically rotate IAM access keys and RDS passwords.
4.  **No Root User**: Delete root access keys and use IAM users/roles for daily work.

---
**Next Step**: Level up your observability with [Monitoring & Logging](../06-Monitoring-Logging/README.md)
