# 🤖 Automation - Shell Scripting Mastery

> **"Automation is the foundation of modern DevOps. Master shell scripting, and you master the infrastructure."**
![Automation Roadmap](./assets/automation-roadmap.png)

## 📚 Overview

Welcome to the comprehensive **Automation curriculum**! This module is designed to transform you from a beginner to an expert capable of building robust, scalable automation across Shell, Python, and Ansible.

## Core Concept: The Three Laws of Automation
**[REFERENCE: Automation Strategy](./reference/automation-strategy-ref.md)**

Infrastructure scalability begins with a rigorous automation mindset:
- **Fast Failure**: Using Bash Strict Mode (`set -euo pipefail`) to stop scripts instantly at the first error.
- **Idempotency**: Designing scripts that can be safely run multiple times without causing duplicate side effects.
- **Tool Selection**: Choosing the right tool for the job—Shell for fast OS tasks, Python for complex API logic.

## Enterprise Governance: Automation Standards
**[REFERENCE: Automation Strategy](./reference/automation-strategy-ref.md)**

Moving from "hacks" to production-grade engineering:
- **Secret Management**: Mandatory use of Vault or Secret Managers instead of hardcoded strings or `.env` files.
- **Wrapper Pattern**: Encapsulating pipeline logic in standalone scripts that can be tested locally by any developer.
- **Least Privilege**: Ensuring automation service accounts are restricted to specific namespaces or resources.
- **Script Linting**: Using `shellcheck` and `pylint` to enforce clean, readable, and secure code standards.

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
| 01 | [**Introduction**](readme.md) | Shell types, first script | ✅ |
| 02 | [**Terminal and Finder**](readme.md) | Navigation, paths | ✅ |
| 03 | [**Basic File Manipulation**](readme.md) | cp, mv, rm | ✅ |
| ... | [**View Full Beginner Index**](03-go-basics/go-automation-master-index.md) | Topics 04-24 (Mastered) | ✅ |

---

### 🟡 Level 2: Intermediate & Advanced Automation

Functional modules for building real-world tools.

| # | Module | Description | Path |
| :---: | :--- | :--- | :---: |
| 01 | **Intermediate Shell** | Functions, Loops, Strict Mode | [Explore Module](readme.md) |
| 02 | **Advanced Bash** | jq, sed, awk, xargs, traps | [Explore Module](readme.md) |
| 03 | **Python for DevOps** | Boto3, APIs, Web Scraping | [Explore Module](readme.md) |
| 04 | **Job Scheduling & Cron** | Crontab, Overlap, K8s Jobs | [Explore Module](./04-job-scheduling-and-cron/) |
| 05 | **Event-Driven Webhooks** | HTTP POST, Security, Async | [Explore Module](./05-event-driven-webhooks/) |
| 06 | **Ansible Dynamic Inventory** | Plugins, Keyed Groups, Caching | [Explore Module](./06-ansible-dynamic-inventory/) |
| 07 | **Terraform Patterns** | Modules, State Locking, DRY | [Explore Module](./07-terraform-patterns/) |
| 08 | **Best Practices** | Idempotency, Secrets | [Explore Module](readme.md) |
| 09 | **Ansible Fundamentals** | Playbooks, Roles | [Explore Module](readme.md) |
| 10 | **Real Life Scenarios** | Troubleshooting War Stories | [Explore Module](readme.md) |
| 11 | **FinOps (Cost as Code)** | Infracost, Kubecost | [Explore Module](readme.md) |

---

### 🔴 Level 3: Strategic Domains

High-level implementation strategies.

- **[GitOps](readme.md)**
- **[Service Mesh](readme.md)**
- **[Multi-Cluster K8s](readme.md)**
- **[AIOps & Incident Response](readme.md)**
- **[Platform Engineering](readme.md)**
- **[Supply Chain Security](readme.md)**
- **[Bare Metal Automation](readme.md)**
- **[Serverless Incident Mgmt](readme.md)**
- **[FinOps K8s Optimization](readme.md)**
- **[Chaos Engineering](readme.md)**
- **[Advanced Identity Federation](readme.md)**
- **[Service Mesh Security](readme.md)**
- **[Automated Compliance Auditing](readme.md)**
- **[Secret Management (Vault)](readme.md)**
- **[Fleet Mgmt (ApplicationSets)](readme.md)**
- **[Admission Controllers (OPA)](readme.md)**
- **[Advanced CI/CD Patterns](readme.md)**
- **[Service Mesh Observability](readme.md)**
- **[Cloud-Native Backup (Velero)](readme.md)**
- **[Automated Security Scanning](readme.md)**
- **[Advanced Terraform Workflows](readme.md)**
- **[Automated Performance Testing](readme.md)**
- **[Cloud-Native Logging (Loki)](readme.md)**
- **[Cost Governance (Infracost)](readme.md)**
- **[Advanced K8s Networking (eBPF)](readme.md)**
- **[DBRE (Database Reliability)](readme.md)**
- **[Observability](readme.md)**

---

## 📊 Progress Tracker

- [x] **Beginner Level** (24/24 completed)
- [x] **Intermediate/Advanced Level** (26/26 completed)
- [ ] **Specialization/Planned** (0/12 planned)

**Total Completion**: 81% ⬜⬜⬜⬜⬜⬜⬜⬜⬛⬛

---

## 📂 Practical Code & Scripts

Build your first tools with these guided examples:

- **[Shell Scripting Examples](./01-shell-scripting/examples/)**: Hello World, variable tests, and basic OS diagnostics.
- **[Python Basics](./02-python-basics/examples/)**: Essential syntax and automation logic for DevOps.

**Happy Automating!** 🤖


---
## 🧭 Additional Modules
- [00 Foundations](00-foundations/readme.md)
- [03 Go Basics](03-go-basics/readme.md)
- [03 Idempotency](03-idempotency/readme.md)
- [resources](resources/readme.md)
