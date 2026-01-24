# 🚀 Azure Bicep Intermediate Level

## 📋 Learning Objectives
- ✅ Create reusable **Modules**
- ✅ Implement **Conditional Loops** and **Iteration**
- ✅ Reference **Existing Resources**
- ✅ Manage **Deployment Scopes**

---

## 🏗️ Modularity: Modules
Modules allow you to reuse Bicep code across different projects.

```bicep
module vnet './modules/vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    vnetName: 'myVnet'
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'myApp'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: vnet.outputs.subnetId // Reference module output
  }
}
```

---

## 🔄 Loops and Conditions

### Loops
Deploy multiple instances of a resource or module.
```bicep
param locations array = [
  'eastus'
  'westus'
]

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = [for loc in locations: {
  name: 'stg${loc}'
  location: loc
  sku: {
    name: 'Standard_LRS'
  }
}]
```

### Conditions
```bicep
param deployDatabase bool = true

resource db 'Microsoft.Sql/servers@2021-02-01' = if (deployDatabase) {
  name: 'mySqlServer'
  ...
}
```

---

## 🔍 Existing Resources
Reference resources that weren't created in the current Bicep file.
```bicep
resource existingVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: 'prod-vnet'
}

output vnetId string = existingVnet.id
```
