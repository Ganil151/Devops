# 🔷 Azure Infrastructure as Code (IaC)

![Azure IaC](https://img.shields.io/badge/Azure-IaC-blue?style=for-the-badge&logo=microsoftazure)

## 📋 Overview
Microsoft Azure provides two native ways to define infrastructure as code: **Azure Resource Manager (ARM) Templates** and **Bicep**.

### 1. ARM Templates (JSON)
The foundational declarative IaC for Azure.
- **Format**: JSON.
- **Characteristics**: Verbose, stable, foundational.
- **Status**: Still supported, used under the hood by Bicep.

### 2. Bicep (DSL)
A modern, domain-specific language (DSL) that provides a better authoring experience than the JSON templates.
- **Format**: `.bicep`.
- **Characteristics**: Clean syntax, modular, compiles to ARM JSON.
- **Status**: Recommended for most new projects.

---

## 🏗️ Architecture

```mermaid
graph TD
    Bicep[Bicep File] -->|Compiles| ARM[ARM Template JSON]
    ARM -->|Deploy| Azure[Azure Resource Manager]
    Azure --> Resources[Actual Azure Resources]
```

---

## 📂 Module Structure

### 🔷 [Azure ARM Templates](./04-azure-arm/readme.md)
- [Beginner](./04-azure-arm/beginner/readme.md)
- [Intermediate](./04-azure-arm/intermediate/readme.md)
- [Advanced](./04-azure-arm/advanced/readme.md)
- [Interview & Quiz](./04-azure-arm/interview-questions/readme.md)

### 📐 [Azure Bicep](./05-azure-bicep/readme.md)
- [Beginner](./05-azure-bicep/beginner/readme.md)
- [Intermediate](./05-azure-bicep/intermediate/readme.md)
- [Advanced](./05-azure-bicep/advanced/readme.md)
- [Interview & Quiz](./05-azure-bicep/interview-questions/readme.md)
