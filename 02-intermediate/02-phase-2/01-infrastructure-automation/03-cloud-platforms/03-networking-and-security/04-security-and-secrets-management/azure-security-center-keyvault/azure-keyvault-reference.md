# Azure Key Vault Reference

Azure Key Vault is a cloud service for securely storing and accessing secrets, keys, and certificates.

## 💎 Key Features
- **Secrets Management**: Safely store tokens, passwords, and API keys.
- **Key Management**: Use HSM-backed keys for data encryption.
- **Certificate Management**: Manage SSL/TLS certificates.

## 🔒 Security
- **RBAC**: Fine-grained access control via Entra ID (Azure AD).
- **Private Link**: Ensure access only from within the VNet.

## 🛠️ IaC (Bicep)
```bicep
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: 'kv-prod-app-001'
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}
```
