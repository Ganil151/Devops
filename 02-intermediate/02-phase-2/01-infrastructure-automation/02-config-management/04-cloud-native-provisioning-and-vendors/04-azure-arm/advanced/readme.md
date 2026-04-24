# 🏆 Azure ARM Advanced Level

## 📋 Learning Objectives
- ✅ Implement **What-if** analysis before deployment
- ✅ Manage shared resources with **Template Specs**
- ✅ Secure secrets using **Azure Key Vault** integration
- ✅ Design for **Enterprise Scale** using Management Groups

---

## 🛡️ Enterprise Governance

### Template Specs
A resource type for storing an ARM template in your resource group for quick sharing and deployment within your organization. It solves the issue of needing a public/SAS URL for linked templates.

### Azure Policy Integration
Templates can be used to deploy and manage Azure Policies at scale, ensuring every resource group created via the template is automatically compliant.

---

## 🔐 Security: Key Vault Integration
Never hardcode secrets. Reference them directly from Key Vault in your parameters file.

```json
"parameters": {
  "adminPassword": {
    "reference": {
      "keyVault": {
        "id": "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/myvault"
      },
      "secretName": "VmPassword"
    }
  }
}
```

---

## 🔄 Deployment Strategy: What-If
The **What-if** operation lets you preview what changes will happen if you deploy the template to a resource group, subscription, or management group.
```bash
az deployment group what-if \
  --resource-group myRG \
  --template-file azuredeploy.json
```
- **Create**: New resources added.
- **Delete**: Existing resources removed (if in Complete mode).
- **Modify**: Existing resource properties changed.
- **Ignore**: No changes.
