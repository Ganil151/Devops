# Azure Entra ID (Ad) Reference

Microsoft Entra ID (formerly Azure Active Directory) is a cloud-based identity and access management service.

## 🔑 Key Features
- **SSO (Single Sign-On)**: Access all apps with one set of credentials.
- **Conditional Access**: Block or allow access based on IP, device health, or user risk.
- **B2B / B2C**: Identity management for external partners and customers.

---

## 🛠️ IaC (Terraform)
```hcl
resource "azuread_user" "admin" {
  user_principal_name = "admin@example.com"
  display_name        = "Cloud Admin"
}
```
