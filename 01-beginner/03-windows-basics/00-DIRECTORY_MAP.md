# 🗺️ Windows Basics: Directory Map & Navigation Guide

> **Purpose**: This document serves as the **administrative index** for Windows fundamentals within the DevOps curriculum. It provides context, navigation links, and explains the DevOps relevance of Windows PowerShell automation.

---

## 📋 Table of Contents

1. [The DevOps Use Case](#-the-devops-use-case)
2. [Directory Structure Overview](#-directory-structure-overview)
3. [Quick Navigation](#-quick-navigation)
4. [Asset Locations](#-asset-locations)
5. [Administrative Resources](#-administrative-resources)

---

## 🎯 The DevOps Use Case

### Why Windows PowerShell Fundamentals Matter for DevOps

Windows PowerShell is **not optional** for modern DevOps practitioners. Here's why:

#### **1. Hybrid-Cloud Infrastructure Management**

Modern enterprises run **hybrid environments** that span:
- **AWS EC2 Windows Instances** - Requires PowerShell for remote management, configuration drift detection, and automation
- **Azure Virtual Machines** - Native PowerShell integration for Azure Resource Manager (ARM) operations
- **On-Premises Windows Servers** - Active Directory, DNS, DHCP, and file servers require PowerShell for automation
- **WSL2 Integration** - Bridging Windows and Linux workflows on developer workstations

**Real-World Scenario**: You're managing a Spring Boot microservices deployment where:
- Jenkins CI/CD runs on Windows Server 2019
- SonarQube performs code quality scans on a Windows VM
- Developers use Windows 10/11 with WSL2 for local testing
- Production runs on Linux, but build agents are Windows-based

**Without PowerShell proficiency**, you cannot:
- Automate Jenkins agent provisioning
- Configure Windows Firewall rules for SonarQube
- Troubleshoot network connectivity issues between build servers
- Manage local user accounts for service principals
- Schedule automated cleanup tasks for disk space management

#### **2. Infrastructure as Code (IaC) Prerequisites**

Before you can write **Terraform** or **Ansible** playbooks for Windows infrastructure, you must understand:
- How Windows networking works (`Get-NetIPConfiguration`, `Test-NetConnection`)
- Disk and storage management (`Get-Disk`, `Initialize-Disk`, `Format-Volume`)
- Service and process lifecycle (`Get-Service`, `Start-Service`, `Stop-Process`)
- Registry manipulation for configuration management (`Get-ItemProperty`, `Set-ItemProperty`)

**Example**: An Ansible playbook that configures a Windows Server requires you to know:
```yaml
# You need to understand the PowerShell equivalent first:
# Get-NetFirewallRule -DisplayName "Allow HTTPS"
# New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443
```

#### **3. Automation & Scripting for SRE Tasks**

Site Reliability Engineers (SREs) use PowerShell for:
- **Incident Response**: Quickly gathering system state during outages
- **Performance Tuning**: CPU prioritization, memory management, network stack optimization
- **Security Hardening**: Auditing firewall rules, managing ACLs, enforcing least-privilege access
- **Monitoring & Alerting**: Parsing event logs, tracking system uptime, detecting anomalies

#### **4. Local Developer Environment Setup**

DevOps engineers frequently need to:
- Install and configure WSL2 for Linux tooling
- Set up package managers (Chocolatey, Winget)
- Configure network adapters for Docker Desktop
- Manage scheduled tasks for automated backups
- Troubleshoot DNS resolution issues

**Bottom Line**: If you skip Windows fundamentals, you'll be **blocked** when tasked with:
- Provisioning Windows-based CI/CD infrastructure
- Debugging hybrid-cloud networking issues
- Automating Windows Server configuration
- Managing developer workstations at scale

---

## 📂 Directory Structure Overview

This directory follows a **depth-first, atomic file organization** to enable:
- **CLI-based navigation** (easy to `cd` and `ls`)
- **Searchability** (each command is a standalone file)
- **Modularity** (no merged content; each file is independent)

```
03-windows-basics/
├── 00-DIRECTORY_MAP.md          ← You are here (administrative index)
├── MASTER_README.md              ← Complete file listing with links
├── readme.md                     ← Introductory overview
├── linkks.md                     ← External resource links
├── login-screen.md               ← Windows login troubleshooting
├── product-key-windows-2019.md   ← Licensing reference
├── virtualbox-installations.md   ← VM setup guide
│
├── assets/                       ← Centralized images and icons
│   ├── powershell-icon.svg
│   └── windows-automation-banner.png
│
├── part-1-powershell-automation/ ← Core PowerShell commands & scripts
│   ├── commands/                 ← Atomic command reference files
│   │   ├── diskandstorage/       ← Disk management cmdlets
│   │   ├── eventlogs/            ← Event log querying
│   │   ├── fileandacl/           ← File permissions & ACLs
│   │   ├── hacksandtips/         ← Advanced networking & troubleshooting
│   │   ├── network/              ← Network adapter & firewall management
│   │   ├── registry/             ← Windows Registry operations
│   │   ├── remoting/             ← PowerShell remote sessions
│   │   ├── scheduledtasks/       ← Task Scheduler automation
│   │   ├── serviceandprocess/    ← Service & process lifecycle
│   │   ├── userandgroup/         ← Local user & group management
│   │   └── windowsupdate/        ← Patch management
│   ├── lessons/                  ← Learning modules & tutorials
│   ├── programremoval/           ← Debloat scripts (McAfee, bloatware)
│   └── scripts/                  ← Reusable automation scripts
│
├── part-2-wsl-linux-integration/ ← WSL2 setup & configuration
├── part-3-package-management/    ← Chocolatey, Winget, app removal
├── part-4-server-administration/ ← Windows Server licensing & config
├── part-5-windows-containers/    ← Docker on Windows resources
├── part-6-system-auditing/       ← Inventory & compliance scripts
├── part-7-performance-tuning/    ← CPU, memory, network, disk optimization
│
├── reference/                    ← Deep-dive technical references
│   ├── active-directory-identity-ref.md
│   ├── powershell-automation-ref.md
│   ├── sre-windows-troubleshooting-ref.md
│   ├── windows-best-practices-ref.md
│   └── windows-system-architecture-ref.md
│
└── resources/                    ← PDF documentation
    ├── powershell.pdf
    └── putty-user-manual.pdf
```

---

## 🧭 Quick Navigation

### **Start Here**
- **New to Windows?** → [`readme.md`](./readme.md)
- **Need a specific command?** → [`MASTER_README.md`](./MASTER_README.md) (full index with links)
- **Want to learn PowerShell?** → [`part-1-powershell-automation/lessons/powershell.md`](./part-1-powershell-automation/lessons/powershell.md)

### **By Use Case**

| **Task** | **Navigate To** |
|:---------|:----------------|
| **Troubleshoot network connectivity** | [`part-1-powershell-automation/commands/network/`](./part-1-powershell-automation/commands/network/) |
| **Manage disk partitions** | [`part-1-powershell-automation/commands/diskandstorage/`](./part-1-powershell-automation/commands/diskandstorage/) |
| **Configure firewall rules** | [`part-1-powershell-automation/commands/hacksandtips/`](./part-1-powershell-automation/commands/hacksandtips/) |
| **Manage Windows services** | [`part-1-powershell-automation/commands/serviceandprocess/`](./part-1-powershell-automation/commands/serviceandprocess/) |
| **Set up WSL2 for DevOps** | [`part-2-wsl-linux-integration/`](./part-2-wsl-linux-integration/) |
| **Optimize Windows performance** | [`part-7-performance-tuning/`](./part-7-performance-tuning/) |
| **Audit system configuration** | [`part-6-system-auditing/`](./part-6-system-auditing/) |
| **Remove bloatware** | [`part-1-powershell-automation/programremoval/`](./part-1-powershell-automation/programremoval/) |

### **By Command Category**

All PowerShell commands are organized into **atomic files** under:
```
part-1-powershell-automation/commands/<category>/<cmdlet-name>.md
```

**Categories:**
- [`diskandstorage/`](./part-1-powershell-automation/commands/diskandstorage/) - Disk, partition, and volume management
- [`eventlogs/`](./part-1-powershell-automation/commands/eventlogs/) - Event log querying and analysis
- [`fileandacl/`](./part-1-powershell-automation/commands/fileandacl/) - File permissions and ACLs
- [`hacksandtips/`](./part-1-powershell-automation/commands/hacksandtips/) - Advanced troubleshooting techniques
- [`network/`](./part-1-powershell-automation/commands/network/) - Network adapters, firewall, DNS, routing
- [`registry/`](./part-1-powershell-automation/commands/registry/) - Windows Registry CRUD operations
- [`remoting/`](./part-1-powershell-automation/commands/remoting/) - PowerShell remote sessions
- [`scheduledtasks/`](./part-1-powershell-automation/commands/scheduledtasks/) - Task Scheduler automation
- [`serviceandprocess/`](./part-1-powershell-automation/commands/serviceandprocess/) - Service and process management
- [`userandgroup/`](./part-1-powershell-automation/commands/userandgroup/) - Local user and group administration
- [`windowsupdate/`](./part-1-powershell-automation/commands/windowsupdate/) - Patch management

---

## 🖼️ Asset Locations

All visual assets are centralized in the `/assets` folder:

| **Asset** | **Path** | **Usage** |
|:----------|:---------|:----------|
| PowerShell Icon | [`assets/powershell-icon.svg`](./assets/powershell-icon.svg) | Documentation headers, diagrams |
| Windows Automation Banner | [`assets/windows-automation-banner.png`](./assets/windows-automation-banner.png) | README headers, presentations |

**Note**: All Markdown files reference these assets using relative paths:
```markdown
![Windows Automation](./assets/windows-automation-banner.png)
```

---

## 📚 Administrative Resources

### **External Links**
- **Windows Admin Center**: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-admin-center
  - Modern web-based GUI for managing Windows Servers
  - Useful for visualizing what PowerShell commands do under the hood

### **Reference Documentation**
- [`reference/powershell-automation-ref.md`](./reference/powershell-automation-ref.md) - Comprehensive PowerShell guide
- [`reference/sre-windows-troubleshooting-ref.md`](./reference/sre-windows-troubleshooting-ref.md) - SRE-focused troubleshooting
- [`reference/windows-system-architecture-ref.md`](./reference/windows-system-architecture-ref.md) - OS internals

### **Learning Resources**
- [`resources/powershell.pdf`](./resources/powershell.pdf) - Official PowerShell documentation
- [`resources/putty-user-manual.pdf`](./resources/putty-user-manual.pdf) - SSH client for Windows

### **Complete File Index**
- [`MASTER_README.md`](./MASTER_README.md) - Every file with direct links (no merged content)

---

## 🔍 File Naming Conventions

All command files follow this pattern:
```
<cmdlet-name>.md
```

Examples:
- `get-volume.md` → Documents the `Get-Volume` cmdlet
- `initialize-disk.md` → Documents the `Initialize-Disk` cmdlet
- `test-netconnection.md` → Documents the `Test-NetConnection` cmdlet

**Why atomic files?**
- **Searchability**: `grep -r "Get-Volume" .` finds the exact file
- **Version control**: Git diffs are granular (one command per commit)
- **Modularity**: Easy to link to specific commands in documentation
- **CLI-friendly**: `cat part-1-powershell-automation/commands/network/get-netadapter.md`

---

## 🚀 Getting Started

1. **Read the overview**: [`readme.md`](./readme.md)
2. **Explore the command index**: [`MASTER_README.md`](./MASTER_README.md)
3. **Pick a category** based on your current task (network, disk, service, etc.)
4. **Open the specific command file** you need
5. **Practice in a safe environment** (VM, WSL2, or test server)

---

## 📝 Maintenance Notes

- **Last Audit**: 2026-02-16
- **Status**: ✅ All files verified against `tree.txt` - No missing files
- **Structure**: ✅ Atomic file organization maintained (no merged content)
- **Assets**: ✅ Centralized in `/assets` folder with correct relative paths

---

*This directory map was generated to provide administrative context and navigation guidance. For the complete file listing with direct links, see [`MASTER_README.md`](./MASTER_README.md).*
