# 🚀 Azure ARM Intermediate Level

## 📋 Learning Objectives
- ✅ Master **Resource Dependencies** with `dependsOn`
- ✅ Use **Copy Loops** to deploy multiple instances of a resource
- ✅ Implement **Conditional Deployment**
- ✅ Modularize with **Linked Templates**

---

## 🏗️ Advanced Resource Management

### Resource Dependencies
Ensure resources are created in the correct order.
```json
"resources": [
  {
    "type": "Microsoft.Network/networkInterfaces",
    "name": "myNic",
    "dependsOn": [
      "[resourceId('Microsoft.Network/virtualNetworks', 'myVnet')]"
    ]
  }
]
```

### Copy Loops (Scaling)
Deploy multiple resources using the `copy` element.
```json
{
  "copy": {
    "name": "storagecopy",
    "count": 3
  },
  "type": "Microsoft.Storage/storageAccounts",
  "name": "[concat('storage', copyIndex())]",
  ...
}
```

---

## 📦 Modular Templates
Instead of one giant file, use **Linked Templates** to break your infrastructure into logical components (e.g., networking, compute, database). These templates are stored in an S3-like location (Azure Blob Storage) and referenced via URI.

---

## 🛠️ Deployment Scripts
Run custom PowerShell or Bash scripts within your deployment using the `Microsoft.Resources/deploymentScripts` resource type. This allows you to perform tasks not supported directly by ARM (e.g., creating a DB user).
