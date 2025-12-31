# Ansible Fundamentals

Ansible is an open-source automation tool that focuses on "Radical Simplicity". Unlike other tools that require complex agents and PKI infrastructure, Ansible uses the tools you already have: **SSH** and **Python**.

This module breaks down the 4 Pillars of Ansible Architecture.

## 📚 Learning Path

| # | Topic | Description |
| :--- | :--- | :--- |
| **01** | [**Control Node**](./01-Control-Node/README.md) | The brain. Requirements, Configuration (`ansible.cfg`), and Scalability (`forks`). |
| **02** | [**Inventory**](./02-Inventory-Architecture/README.md) | The source of truth. Static files vs Dynamic Cloud Plugins. |
| **03** | [**Transport**](./03-Transport-Protocols/README.md) | How Ansible talks. SSH Pipelining, WinRM, and Agentless design. |
| **04** | [**Modules**](./04-Module-Architecture/README.md) | The tools. The Lifecycle of a module (Push -> Exec -> Delete). |

---

## 🏗️ High-Level Architecture

```mermaid
graph TD
    User((System Admin)) -->|Run Playbook| Control[Control Node]
    
    Control -->|Read| Inv[Inventory]
    Control -->|Connect (SSH)| Target1[Target Node]
    
    subgraph Execution
    Target1 -->|Receive| Mod[Module File]
    Mod -->|Run| Py[Python]
    Py -->|Return| JSON[JSON Output]
    end
```

---

## 🛠️ Lab Environment Setup

To follow this course, you need a local or cloud-based lab environment.

### Option 1: Local Virtual Machines (Vagrant)
Ideal for testing network configurations and kernel-level changes.
```bash
# Start a 3-node lab (Control + 2 Nodes)
mkdir ansible-lab && cd ansible-lab
# ... create Vagrantfile ...
vagrant up
```

### Option 2: Docker Containers (Fastest)
Ideal for testing application deployments and playbook logic.
```bash
# Start containers with SSH enabled
docker-compose up -d
```

### Option 3: Cloud (AWS EC2)
Ideal for enterprise-scale testing and dynamic inventory practice.
```bash
# Deploy using Terraform
terraform apply
```

---

## Quick Start (Ad-Hoc)

Once you understand the architecture, you can run simple commands:

```bash
# Ping all servers in inventory
ansible all -m ping

# Check uptime
ansible webservers -m command -a "uptime"
```

Please proceed to **[01-Control-Node](./01-Control-Node/README.md)** to begin the deep dive.