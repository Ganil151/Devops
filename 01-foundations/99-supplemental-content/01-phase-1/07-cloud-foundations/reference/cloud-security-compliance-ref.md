# 🛡️ Cloud Security & Compliance
*Version 1.0 | Securing Infrastructures in the Multi-Tenant Cloud*

---

## 📖 Overview
In the cloud, security is a **Shared Responsibility**. While the provider secures the "Cloud itself" (Infrastructure), you are responsible for securing "what's in the Cloud" (Data, OS, Apps).

---

## 🏗️ Technical Pillars

### 1. Shared Responsibility Model
**Provider's Job**: Physical security of data centers, hardware, networking, and virtualization layer.
**Customer's Job**: IAM configuration, data encryption, OS patching, and network firewall rules.

### 2. IAM Best Practices
- **Least Privilege**: Grant only the permissions required for a specific task.
- **MFA**: Enforce Multi-Factor Authentication for all human users, especially admins.
- **Rotatable Keys**: Never hardcode API keys; use temporary credentials (IAM Roles).

### 3. Data Encryption
- **At Rest**: Encrypting data on disks (S3, EBS, Blob).
- **In Transit**: Encrypting data as it moves over the network (TLS/SSL).
- **KMS**: Use a Key Management Service to handle master keys.

---

## ⚙️ Compliance Frameworks

- **SOC2**: Controls for security, availability, and processing integrity.
- **HIPAA**: Standards for protecting sensitive patient data (Heathcare).
- **PCI-DSS**: Security standards for handling credit card information.
- **GDPR**: Data protection and privacy in the EU.

---

## 🚀 Advanced SRE Security Patterns

- **GuardDuty / Azure Security Center**: Automated threat detection and monitoring.
- **Infrastructure as Code (IaC) Scanning**: Using tools like `tfsec` or `checkov` to find security holes before deployment.
- **VPC Flow Logs**: Monitoring network traffic for suspicious patterns.

---

## 💡 SRE Pro-Tips
- **Drift Detection**: Use tools to ensure that manual changes in the console don't violate your security-as-code standards.
- **Public Buckets Alert**: Set up an immediate alert for any S3 bucket or Blob storage becoming public.
- **Secrets Manager**: Use a managed service to inject passwords into containers at runtime.

---
**Next Step**: [Cloud Performance & Optimization →](./cloud-performance-optimization-ref.md)
