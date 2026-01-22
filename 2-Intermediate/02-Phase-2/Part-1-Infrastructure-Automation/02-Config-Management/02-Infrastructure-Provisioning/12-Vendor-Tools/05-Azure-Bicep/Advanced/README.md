# 🏆 Azure Bicep Advanced Level

## 📋 Learning Objectives
- ✅ Set up a **Private Module Registry**
- ✅ Use **Aspect-like** functionality with User-defined functions (Preview)
- ✅ Deploy to **Multiple Scopes** in one file
- ✅ Implement a **Linting Strategy**

---

## 🚀 Private Module Registry
Publish modules to an Azure Container Registry (ACR) to share them across your enterprise.
```bash
az bicep publish --file vnet.bicep --target br:myregistry.azurecr.io/bicep/modules/vnet:v1
```
Consume in your code:
```bicep
module vnet 'br:myregistry.azurecr.io/bicep/modules/vnet:v1' = {
  ...
}
```

---

## 🗺️ Multi-Scope Deployments
One Bicep file can deploy resources across different levels (e.g., creating a Resource Group and then deploying services into it).

```bicep
targetScope = 'subscription'

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'myNewGroup'
  location: 'eastus'
}

module app './app.bicep' = {
  name: 'appDeploy'
  scope: newRG // Deploy specifically to the newly created group
  params: {
    ...
  }
}
```

---

## 🛡️ Governance: Bicep Linter
Bicep has a built-in linter that checks for best practices, such as:
- No hardcoded environment URLs.
- Parameters must be used.
- No secrets in strings.
You can customize the linter rules via a `bicepconfig.json` file.

---

## 🔄 Lifecycle Management
- **Deployment Stacks (Preview)**: A new resource type that manages a collection of resources as a single unit, providing better cleanup (delete resources when they are removed from the stack).
