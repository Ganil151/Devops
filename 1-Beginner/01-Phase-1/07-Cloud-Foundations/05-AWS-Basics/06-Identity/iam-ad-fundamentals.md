# 🔐 AWS Identity: IAM & AD Federation
*Version 1.0 | Architectural Depth in Identity Management*

---

## 🏛️ Executive Summary
Identity is the new perimeter in cloud security. This guide explores the "Under the Hood" mechanics of AWS Identity and Access Management (IAM) and how enterprises bridge on-premises identity (Active Directory) to the cloud using SAML 2.0 federation.

---

## 🚀 The "DevOps Why"
DevOps engineers must automate permission management while following the **Principle of Least Privilege (PoLP)**. Understanding federation allows for "Single Sign-On" (SSO), reducing the risk of leaked permanent access keys and simplifying user offboarding.

---

## 🏗️ Core Architecture: SAML 2.0 Federation
<img src="https://raw.githubusercontent.com/Ganil151/Devops/main/1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/assets/iam-federation.webp" alt="IAM SAML Federation Flow" width="800">

### The Technical Flow (Protocol Level)
1. **Request**: User visits the AWS Console URL.
2. **Redirect**: AWS redirects the browser to the Identity Provider (IdP) like Okta or ADFS.
3. **Login**: User authenticates with the IdP.
4. **Assertion**: IdP sends a signed XML document (SAML Assertion) to the browser.
5. **Post**: Browser posts the SAML Assertion to the AWS Sign-In endpoint.
6. **AssumeRole**: AWS verifies the signature and calls `STS:AssumeRoleWithSAML`.
7. **Token**: AWS STS returns temporary security credentials (15m to 12h).

---

## ⚙️ Windows AD Domain Joins (The Protocol Level)
When a Windows EC2 instance joins an Active Directory domain, it's not just a registration; it's a multi-step Kerberos and DNS handshake:
- **DNS Lookup**: The instance queries `_ldap._tcp.dc._msdcs.DomainName` to find the Domain Controller (DC).
- **LDAP Bind**: The instance contacts the DC via LDAP (Port 389/636).
- **Kerberos Security**: The computer account is created in AD, and a **shared secret** (computer password) is established for Kerberos ticket-granting.
- **SMB/RPC**: Policy updates (Group Policy) are pulled via RPC over SMB (Port 445).

---

## 🛠️ CLI Quickstart: Inspecting Identity
```bash
# Check "Who Am I" to verify current credentials
aws sts get-caller-identity

# List attached policies for a role
aws iam list-attached-role-policies --role-name MyAppRole
```

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between an IAM User, a Role, and a Group at the API level.**
2. **What is an "Inline Policy" and why is it generally discouraged compared to "Managed Policies"?**
3. **How does the "Permissions Boundary" feature prevent privilege escalation for delegated admins?**
4. **Describe the flow of a Cross-Account Role assumption using AWS STS.**
5. **What is the significance of the `Audience` (Aud) field in a SAML assertion during federation?**

---

## 🧪 Real-World Troubleshooting
**Scenario**: "My EC2 instance has the correct IAM Role, but it still gets `403 Access Denied` from S3."
- **Root Cause**: Check the **S3 Bucket Policy**. Even if the IAM Role has permission, an explicit `Deny` in the Bucket Policy (or a missing `Allow` in a boundary) will block access.
- **Solution**: Use the **IAM Policy Simulator** or CloudTrail logs to identify which specific policy is rejecting the request.

---
**Detailed Guide**: [Active Directory Configuration](./Active%20Directory%20%20Configuration.md)
