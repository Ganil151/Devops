# Ansible Automation Series

Welcome to the **Intermediate Level Ansible Course**.
This series takes you from "Hello World" to complex, enterprise-grade automation.

## 🏗️ Architecture

Ansible is **Agentless**. It uses SSH to push configuration to your infrastructure.

```mermaid
graph LR
    User[DevOps Engineer] -->|Writes YAML| Control[Control Node (Laptop/Jenkins)]
    Control -->|SSH (Port 22)| Web1[Web Server 1]
    Control -->|SSH (Port 22)| Web2[Web Server 2]
    Control -->|WinRM (Port 5986)| Win1[Windows DB]
    
    subgraph Managed Nodes
    Web1
    Web2
    Win1
    end
    
    style Control fill:#ee0000,color:#fff
```

## 📚 Module Index

This course is structured logically. It is recommended to follow the modules in order.

| # | Module | Description | Key Concepts |
| :--- | :--- | :--- | :--- |
| **01** | [**Fundamentals**](./01-Fundamentals) | Getting Started | Control Node, Inventory, Transport, Modules |
| **02** | [**Inventory Management**](./02-Inventory-Management) | The "Source of Truth" | Static, Patterns, Variables, Dynamic Plugins |
| **03** | [**Basic Playbooks**](./03-Basic-Playbooks) | Your First Automation | YAML Syntax, Idempotency, Tasks |
| **04** | [**Core Modules**](./04-Core-Modules) | The Toolkit | `apt`, `copy`, `service`, `systemd`, `git` |
| **05** | [**Variables & Facts**](./05-Variables-and-Facts) | Handling Data | Hierarchy, Facts, Magic Vars, Dynamic Data |
| **06** | [**Templates & Files**](./06-Templates-and-Files) | Dynamic Configs | Jinja2 Basics, Advanced Logic, Deploy Strategies, Safe Validation |
| **07** | [**Ansible Roles**](./07-Ansible-Roles) | Reusable Code | Structure, Dependencies, Galaxy, Molecule Testing |
| **08** | [**Conditionals & Loops**](./08-Conditionals-and-Loops) | Advanced Logic | when, loops, blocks/rescue, custom failures |
| **09** | [**Error Handling**](./09-Error-Handling) | Bulletproof Automation | Failure Strategies, Debugging, Handlers, Validation/Abortion |
| **10** | [**Ansible Vault**](./10-Ansible-Vault) | Secret Management | CLI Operations, Automation Workflow, CI/CD Secrets, Security Best Practices |
| **11** | [**Custom Modules**](./11-Custom-Modules) | Extending Ansible | Python, `AnsibleModule`, APIs |

## 🚀 How to Use
1.  **Read the README** in each folder. It contains Concepts, Diagrams, and Real-Life Scenarios.
2.  **Run the Examples**: Try writing the playbooks on your local machine or a cloud VM.
3.  **Test Yourself**: Each module ends with **10 Interview Questions** and a **20-Question Quiz**.

---
*Generated for the DevOps Course Series*