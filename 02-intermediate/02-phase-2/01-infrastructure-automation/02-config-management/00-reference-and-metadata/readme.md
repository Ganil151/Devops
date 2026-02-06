# 📔 Config Management: The Keyword Encyclopedia

Welcome to the central reference hub for **Infrastructure-as-Code (IaC) and Configuration Management**. This guide provides the technical foundation for building scalable, drift-resistant environments.

---

## 🏗️ Technical Reference Manuals

### 1. [🛠️ Architecture Patterns](./iac-architecture-patterns-ref.md)
Provisioning vs. Configuration, State management, and the "Module" pattern.

### 2. [🛡️ Immutable Governance](./immutable-infrastructure-governance-ref.md)
The "Bake vs. Fry" philosophy, Golden Images, and standardizing the Image Lifecycle.

### 3. [🔐 Provisioning & IaC Keywords](./provisioning-iac-keywords.md)
Deep dive into Lifecycle Management: HCL, Providers, Resources, and Backends.

### 4. [📟 Config Management Keywords](./config-management-keywords.md)
Understanding the "Inside" code: Inventories, Handlers, Roles, and Facts.

---

## 🛠️ The "Staff Level" IaC Bar

In a production environment, infrastructure code is judged by its **DRYness**, **Explicitness**, and **Safety**.

| Junior Level | Staff Engineer Level |
| :--- | :--- |
| Hardcodes IP addresses and VPC IDs. | Uses **Dynamic Lookups** (Data segments) for resource discovery. |
| Manually manages state files locally. | Uses **Remote Backend** with versioned state and DynamoDB locks. |
| Writes one giant `main.tf` file. | Builds **Modular Libraries** reusable across multiple environments. |
| Runs `apply` manually on their laptop. | Enforces **GitOps** pipelines with PR-based plan reviews. |
| Allows "SSH into Prod" for quick fixes. | Enforces **Immutable Infrastructure**; replaces nodes for all updates. |

---

## 🏗️ The Execution Flow

```mermaid
graph TD
    A[Code Commit] --> B{CI Pipeline}
    B -- Linting --> C[tflint / ansible-lint]
    B -- Security --> D[tfsec / Checkov]
    B -- Execution --> E{Target Layer}
    
    E -- Provisioning --> F[Terraform: State Audit]
    E -- Configuration --> G[Ansible: Idempotency Check]
    
    F --> H[Cloud Resource]
    G --> H
    
    style B fill:#5c4ee5,color:#fff
    style E fill:#fef3c7,stroke:#d97706
```

---

[⬅️ Back to Config Management Index](../readme.md)


---
## 🧭 Additional Modules
- [samples](samples/readme.md)
