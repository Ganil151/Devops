# 📐 Azure Bicep

![Azure Bicep](https://img.shields.io/badge/Azure-Bicep-green?style=for-the-badge&logo=microsoftazure)

## 📋 Overview
**Bicep** is a domain-specific language (DSL) that uses declarative syntax to deploy Azure resources. In a Bicep file, you define the infrastructure you want to deploy to Azure, and then use that file throughout the development lifecycle to repeatedly deploy your infrastructure.

### Why Bicep over ARM JSON?
- **Simpler Syntax**: No more JSON boilerplate.
- **Modularity**: First-class support for modules.
- **Type Safety**: Rich validation and IntelliSense.
- **Automatic Dependency Management**: Bicep automatically detects dependencies between resources.
- **Day-0 Support**: Any resource available in ARM is immediately available in Bicep.

---

## 🏗️ Architecture

```mermaid
graph LR
    Bicep[Bicep Source Code] -->|bicep build| ARM[ARM Template JSON]
    ARM -->|az deployment| Azure[Azure]
```

---

## 📂 Module Structure

### 🔰 [Beginner Level](./Beginner/README.md)
- Bicep syntax and file structure
- Resource, Parameter, and Variable declarations
- Deploying Bicep files with CLI and PowerShell

### 🚀 [Intermediate Level](./Intermediate/README.md)
- Modules and code reuse
- Scopes (Resource Group, Subscription, Management Group)
- Conditional logic and loops
- Existing resources

### 🏆 [Advanced Level](./Advanced/README.md)
- Bicep Registry for private modules
- Advanced patterns (Linter customization)
- Deploying across multiple scopes
- CI/CD with Bicep

---

## ❓ Interview Questions & Quiz
- [Bicep Interview Questions & 20+ Quiz Questions](./Interview-Questions/README.md)
