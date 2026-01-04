# 🔰 Azure ARM Beginner Level

## 📋 Learning Objectives
- ✅ Understand the basic structure of an ARM JSON template
- ✅ Use the Azure CLI to deploy a template
- ✅ Define parameters and variables

---

## 📝 Template Anatomy

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageName": {
      "type": "string",
      "defaultValue": "mystorageaccount"
    }
  },
  "variables": {
    "uniqueName": "[concat(parameters('storageName'), uniqueString(resourceGroup().id))]"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2021-04-01",
      "name": "[variables('uniqueName')]",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "Standard_LRS"
      },
      "kind": "StorageV2"
    }
  ],
  "outputs": {
    "storageId": {
      "type": "string",
      "value": "[resourceId('Microsoft.Storage/storageAccounts', variables('uniqueName'))]"
    }
  }
}
```

---

## 🚀 Deployment Commands

### Create Resource Group
```bash
az group create --name myResourceGroup --location eastus
```

### Deploy Template
```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.json \
  --parameters storageName=prodstorage
```

---

## 🔑 Key Concepts
- **Resources**: The Azure services you want to deploy.
- **Parameters**: Values provided during deployment to make the template reusable.
- **Variables**: Internal values used to simplify template expressions.
- **Functions**: Built-in logic like `resourceGroup().location` or `concat()`.
