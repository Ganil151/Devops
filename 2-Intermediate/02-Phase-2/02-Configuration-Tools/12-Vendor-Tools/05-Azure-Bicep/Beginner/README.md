# 🔰 Azure Bicep Beginner Level

## 📋 Learning Objectives
- ✅ Install the Bicep CLI / VS Code Extension
- ✅ Write basic Bicep resource declarations
- ✅ Use parameters, variables, and outputs
- ✅ Deploy a Bicep file

---

## 🚀 Getting Started

### 1. Installation
Install the **Bicep extension** for VS Code. It provides the best authoring experience.
To use via CLI:
```bash
az bicep install
```

### 2. Basic Syntax

```bicep
// Parameter with default value
param storageName string = 'mystorage'
param location string = resourceGroup().location

// Variable for complex logic
var uniqueStorageName = '${storageName}${uniqueString(resourceGroup().id)}'

// Resource declaration
resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// Output
output storageId string = stg.id
```

---

## 🛠️ Essential Commands

### Build (Compile to JSON)
```bash
az bicep build --file main.bicep
```

### Deploy
```bash
az deployment group create \
  --resource-group myRG \
  --template-file main.bicep \
  --parameters storageName=prod
```

### Decompile (JSON to Bicep)
```bash
az bicep decompile --file azuredeploy.json
```

---

## 🔑 Key Concepts
- **Resource**: Defined using `resource <symbolic-name> '<type>@<api-version>'`.
- **String Interpolation**: Use `${variableName}` instead of `concat()`.
- **IntelliSense**: The VS Code extension automatically suggests resource types and properties.
