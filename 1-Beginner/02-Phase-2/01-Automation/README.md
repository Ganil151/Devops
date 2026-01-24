# 🤖 Automation - Shell Scripting Mastery

> **"Automation is the foundation of modern DevOps. Master shell scripting, and you master the infrastructure."**
![Automation Roadmap](./assets/automation_roadmap.png)

## 📚 Overview

Welcome to the comprehensive **Automation curriculum**! This module is designed to transform you from a beginner to an expert capable of building robust, scalable automation across Shell, Python, and Ansible.

## 📋 Professional Pattern: "Configuration separation"

Don't bake your environment values into your HCL logic. Keep your Terraform code strictly for **Architectural Logic** and use **YAML/JSON files** for your **Environment Configuration**. Your module should read the YAML file, parse it into a map, and use `for_each` to create the infrastructure. This allows you to add new environments or services just by editing a simple data file—zero HCL changes required.

## 🎯 Learning Objectives

By completing this curriculum, you will:

- ✅ Master Bash shell scripting from fundamentals to advanced techniques
- ✅ Automate complex DevOps workflows confidently
- ✅ Write production-ready, maintainable automation scripts
- ✅ Understand Unix philosophy and best practices
- ✅ Debug and troubleshoot shell scripts effectively
- ✅ Build CI/CD pipeline components (GitHub Actions, etc.)

## 🗺️ Curriculum Structure

### Three-Tier Learning System

```mermaid
graph TD
    A[🟢 BEGINNER<br/>24 Mastered Topics] --> B[🟡 INTERMEDIATE<br/>Functional Modules]
    B --> C[🔴 ADVANCED<br/>Strategic Domains]
    
    A --> A1[Terminal & Files]
    A --> A2[Basic Scripting]
    A --> A3[Control Flow]
    
    B --> B1[Advanced Shell]
    B --> B2[Python for DevOps]
    B --> B3[Ansible]
    
    C --> C3[Service Mesh]
    C --> C4[Secured CI/CD]
    C --> C5[Platform Eng]
    C --> C6[DBRE]
    
    style A fill:#00b894,stroke:#333,stroke-width:3px,color:#fff
    style B fill:#fdcb6e,stroke:#333,stroke-width:3px,color:#000
    style C fill:#d63031,stroke:#333,stroke-width:3px,color:#fff
```

---

## 📖 Module Listings

### 🟢 Level 1: Beginner (Foundation Building)

Master the fundamentals of shell scripting and terminal navigation.

| # | Topic | Description | Status |
| --- | --- | --- | --- |
| 01 | [**Introduction**](./01-Shell-Scripting/01-Introduction/) | Shell types, first script | ✅ |
| 02 | [**Terminal and Finder**](./01-Shell-Scripting/02-Terminal-and-Finder/) | Navigation, paths | ✅ |
| 03 | [**Basic File Manipulation**](./01-Shell-Scripting/03-Basic-File-Manipulation/) | cp, mv, rm | ✅ |
| ... | [**View Full Beginner Index**](./AUTOMATION_MASTER_INDEX.md) | Topics 04-24 (Mastered) | ✅ |

---

### 🟡 Level 2: Intermediate & Advanced Automation

Functional modules for building real-world tools.

| # | Module | Description | Path |
| :---: | :--- | :--- | :---: |
| 01 | **Intermediate Shell** | Functions, Loops, Strict Mode | [Explore Module](../../../2-Intermediate/02-Phase-2/01-Automation/01-Intermediate-Shell-Scripting) |
| 02 | **Advanced Bash** | jq, sed, awk, xargs, traps | [Explore Module](../../../2-Intermediate/02-Phase-2/01-Automation/02-Advanced-Bash-Automation) |
| 03 | **Python for DevOps** | Boto3, APIs, Web Scraping | [Explore Module](../../../2-Intermediate/02-Phase-2/01-Automation/03-Python-for-DevOps) |
| 04 | **Job Scheduling & Cron** | Crontab, Overlap, K8s Jobs | [Explore Module](./04-Job-Scheduling-and-Cron/) |
| 05 | **Event-Driven Webhooks** | HTTP POST, Security, Async | [Explore Module](./05-Event-Driven-Webhooks/) |
| 06 | **Ansible Dynamic Inventory** | Plugins, Keyed Groups, Caching | [Explore Module](./06-Ansible-Dynamic-Inventory/) |
| 07 | **Terraform Patterns** | Modules, State Locking, DRY | [Explore Module](./07-Terraform-Patterns/) |
| 08 | **Best Practices** | Idempotency, Secrets | [Explore Module](../../../2-Intermediate/02-Phase-2/01-Automation/04-Automation-Best-Practices) |
| 09 | **Ansible Fundamentals** | Playbooks, Roles | [Explore Module](../../../2-Intermediate/02-Phase-2/01-Automation/05-Ansible) |
| 10 | **Real Life Scenarios** | Troubleshooting War Stories | [Explore Module](../../2-Intermediate/02-Phase-2/01-Automation/07-Real-Life-Scenarios/) |
| 11 | **FinOps (Cost as Code)** | Infracost, Kubecost | [Explore Module](../../../2-Intermediate/02-Phase-2/06-FinOps-Cost-as-Code/) |

---

### 🔴 Level 3: Strategic Domains

High-level implementation strategies.

- **[GitOps](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/05-GitOps)**
- **[Service Mesh](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/05-Service-Mesh-Istio)**
- **[Multi-Cluster K8s](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/07-Multi-Cluster-Kubernetes)**
- **[AIOps & Incident Response](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/10-AI-Driven-Operations-AIOps)**
- **[Platform Engineering](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/13-Platform-Engineering-Backstage)**
- **[Supply Chain Security](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/15-Supply-Chain-Security)**
- **[Bare Metal Automation](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/16-Bare-Metal-Automation)**
- **[Serverless Incident Mgmt](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/17-Serverless-Incident-Management)**
- **[FinOps K8s Optimization](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/18-FinOps-K8s-Optimization)**
- **[Chaos Engineering](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/19-Chaos-Engineering-Chaos-Mesh)**
- **[Advanced Identity Federation](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/20-Advanced-Identity-Federation)**
- **[Service Mesh Security](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/21-Service-Mesh-Security-mTLS-SPIFFE)**
- **[Automated Compliance Auditing](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/22-Automated-Compliance-Auditing-Cloud-Custodian)**
- **[Secret Management (Vault)](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/23-Advanced-Secret-Management-Vault)**
- **[Fleet Mgmt (ApplicationSets)](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/24-Fleet-Management-ArgoCD-ApplicationSets)**
- **[Admission Controllers (OPA)](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/25-K8s-Admission-Controllers-OPA)**
- **[Advanced CI/CD Patterns](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/26-Advanced-CICD-Patterns-GH-Actions)**
- **[Service Mesh Observability](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/27-Service-Mesh-Observability-Kiali-Jaeger)**
- **[Cloud-Native Backup (Velero)](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/28-Cloud-Native-Backup-Velero)**
- **[Automated Security Scanning](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/29-Automated-Security-Scanning)**
- **[Advanced Terraform Workflows](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/30-Advanced-Terraform-Workflows)**
- **[Automated Performance Testing](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/31-Automated-Performance-Testing-Locust-k6)**
- **[Cloud-Native Logging (Loki)](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/32-Cloud-Native-Logging-Loki-FluentBit)**
- **[Cost Governance (Infracost)](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/33-Infrastructure-Cost-Governance-Infracost)**
- **[Advanced K8s Networking (eBPF)](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/34-Advanced-K8s-Networking-Cilium)**
- **[DBRE (Database Reliability)](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/14-Database-Reliability-DBRE)**
- **[Observability](../../../3-Advanced/02-Phase-2-BACKUP-20260119_022016/06-Observability)**

---

## 📊 Progress Tracker

- [x] **Beginner Level** (24/24 completed)
- [x] **Intermediate/Advanced Level** (26/26 completed)
- [ ] **Specialization/Planned** (0/12 planned)

**Total Completion**: 81% ⬜⬜⬜⬜⬜⬜⬜⬜⬛⬛

---

## 📂 Practical Code & Scripts

Build your first tools with these guided examples:

- **[Shell Scripting Examples](./01-Shell-Scripting/examples/)**: Hello World, variable tests, and basic OS diagnostics.
- **[Python Basics](./02-Python-Basics/examples/)**: Essential syntax and automation logic for DevOps.

**Happy Automating!** 🤖
