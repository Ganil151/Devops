# 🔐 Inventory Security & RBAC Reference
*Version 1.0 | Hardening the Source of Truth and Managing Secrets*

---

## 🏛️ Executive Summary
Inventory files often contain sensitive information like host addresses, custom ports, and sometimes (incorrectly) credentials. Securing the inventory and managing administrative access via Role-Based Access Control (RBAC) is critical for enterprise SRE operations.

---

## 🧱 Technical Pillars: Protecting the Inventory

### 1. Ansible Vault
**Mechanism**: Symmetric encryption for files or individual variables.
- **UseCase**: Encrypting a static `hosts.yml` that contains custom SSH ports or sensitive group variables.
- **Rule**: Never commit unencrypted secrets to Git.

### 2. Environment Variable Secrets
For dynamic inventories, avoid hardcoding API keys in the `.yml` file.
- **Standard**: The plugins automatically look for standard env vars:
  - `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
  - `AZURE_SUBSCRIPTION_ID`
  - `GOOGLE_APPLICATION_CREDENTIALS`

---

## ⚙️ RBAC in Managed Ansible (AWX / Automation Controller)
When using a central automation platform, management changes from file-level to API-level.

| Feature | Description | SRE Benefit |
| :--- | :--- | :--- |
| **Org-Level Inventory** | Inventories restricted to a specific department. | Prevents Dept A from accidentally rebooting Dept B's servers. |
| **Credential Linking** | Linking Cloud Credentials to an Inventory. | Users can run playbooks without ever seeing the API keys. |
| **Job Isolation**| Playbook runs in an isolated container context. | Limits "Blast Radius" of a compromised inventory file. |

---

## 🚀 SRE Safety Standards: Tag-Based Access Control
Modern security uses **ABAC** (Attribute-Based Access Control).
- **Strategy**: Define "Management Tags" on cloud resources.
  - `ManagementGroup: SRE_TEAM_A`
- **Logic**: The dynamic inventory plugin only imports hosts where the management tag matches the user's team.

---

## ❓ Interview "Deep-Cut" Questions
1. **How do you manage Ansible Vault passwords in an automated CI/CD environment?**
2. **Explain the risks of "Inventory Expansion" where sensitive data is cached on disk.**
3. **Difference between `ansible-vault encrypt` and `ansible-vault encrypt_string`.**
4. **How does "Fact Caching" in Redis improve security and performance for large inventories?**
5. **Describe how you would implement a "Secure Bastion Host" logic within an Ansible inventory.**

---
**Back to foundations**: [Inventory Architecture →](./Ansible-Inventory-Core-Ref.md)
