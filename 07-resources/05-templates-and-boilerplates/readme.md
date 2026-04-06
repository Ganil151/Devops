# 🏗️ Templates & Boilerplates: Zero-to-One Accelerators

This directory is the "Starter Kit" for new projects. Instead of writing infrastructure code from scratch, start here with battle-tested patterns that follow 2026 security and performance standards.

---

## 📂 Current Boilerplates

### 📦 Containerization
- **[`Dockerfile.python`](./Dockerfile.python)**: Secure, multi-stage build for Python apps.
- **[`docker-compose.yml`](./docker-compose.yml)**: 3-tier local dev environment (App, DB, Cache).

### ⚙️ Automation & IaC
- **[`ansible-base.yml`](./ansible-base.yml)**: Standard server hardening playbook.
- **[`terraform-aws-base.tf`](./terraform-aws-base.tf)**: VPC and EC2 "Launch and Lock" configuration.

---

## 🚀 The DevOps Why: Standardization
Boilerplates are not about laziness; they are about **Governance**. Using these templates ensures:
1.  **Security by Default**: All boilerplates include non-root users and restricted ports.
2.  **Naming Conventions**: Standardized tags and resource names across all projects.
3.  **Speed**: Reduced time-to-first-deployment.

---

## 💡 Senior Tips: Customizing Templates
- **Parametrize Everything**: Use variables instead of hardcoded strings.
- **The 80/20 Rule**: A boilerplate should cover 80% of your needs. The remaining 20% should be project-specific customization.
- **Keep it Lean**: Avoid "Bloated Boilerplates." Only include what is strictly necessary for a base setup.

---
**Standard**: All templates are pre-commented with maintenance instructions. 
