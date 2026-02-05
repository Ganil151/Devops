# 🚀 Root REFERENCE: The DevOps Master Logic
*Last Updated: 2026-02-05 00:20 - Automated Sync*

This file serves as the core entry point for the high-level logic across all tiers. Use this to quickly navigate frequent commands, architecture patterns, and the "Trinity" orchestration suite.

---

## 🛠️ The "Trinity" Orchestration Suite
These master scripts are designed for cross-platform system management.

| Goal | Language | Location | Primary Command |
| :--- | :--- | :--- | :--- |
| **Health Audit** | Python | [./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/](./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/) | `python resource_monitor.py` |
| **Hybrid Check** | PowerShell | [./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/](./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/) | `.\Invoke-HybridHealthCheck.ps1` |
| **Node Harden** | Bash | [./2-Intermediate/01-Phase-1/02-Linux/scripts/](./2-Intermediate/01-Phase-1/02-Linux/scripts/) | `sudo ./harden-linux-node.sh` |
| **K8s Audit** | PowerShell | [./3-Advanced/01-Phase-1/04-Container-Orchestration/scripts/](./3-Advanced/01-Phase-1/04-Container-Orchestration/scripts/) | `.\Invoke-K8sClusterAudit.ps1` |
| **Cloud Artifact** | PowerShell | [./2-Intermediate/02-Phase-2/01-Infrastructure-Automation/scripts/](./2-Intermediate/02-Phase-2/01-Infrastructure-Automation/scripts/) | `.\Sync-S3CloudBackup.ps1` |

---

## 🗺️ Navigation Index

- 🌱 **[Beginner Fundamentals](./1-Beginner/REFERENCE.md)**: Linux Basics & Linux SSH, Windows Basics, Networking Foundations.
- ⚙️ **[Intermediate Automation](./2-Intermediate/REFERENCE.md)**: Foundations (Weeks 1-4), Core Skills (Weeks 5-10), Advanced (Weeks 11-16).
- 🏛️ **[Advanced Enterprise](./3-Advanced/REFERENCE.md)**: General Reference.
- 👔 **[Professional Career](./4-Professional-Development/REFERENCE.md)**: General Reference.
- 📦 **[Boilerplates](./5-Boilerplates/REFERENCE.md)**: General Reference.
- 📝 **[Quizzes](./6-Quizzes/REFERENCE.md)**: General Reference.


---

## 📊 Core Command Matrix (Essential DevOps)

### 📦 Infrastructure as Code (Terraform)
```bash
terraform init          # Initialize workspace
terraform plan          # Preview infrastructure changes
terraform apply         # Deploy to provider (AWS/Azure/GCP)
```

### 🐋 Containers & Orchestration
```bash
docker build -t app:1.0 .  # Build local image
docker-compose up -d        # Deploy local stack
kubectl get pods -A         # View all running pods
```

### 🐍 Automation Logic (Python)
```bash
python -m venv .venv        # Create isolation
pip install -r reqs.txt     # Install dependencies
python script.py            # Execute automation
```

---

## 🔍 Universal Search Index

<details>
<summary>Click to expand full file index (501 files)</summary>

| Resource | Category | Path |
| :--- | :--- | :--- |
| 10 Base T | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/10 Base-T.md` |
| 1000Base T | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/1000Base-T.md` |
| 100Base T | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/100Base-T.md` |
| Types | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/Types.md` |
| Wiring | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/Wiring.md` |
| Computer Network Components | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Computer network components.md` |
| Hub | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/HUB.md` |
| Nic | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/NIC.md` |
| 1841 Cisco Router | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Components/1841 Cisco Router.md` |
| Modem | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Components/Modem.md` |
| Router Devices And Wic Modules | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Components/Router devices and WIC modules.md` |
| Loop Back Interface | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/LOOP-BACK INTERFACE.md` |
| Ospf | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/OSPF.md` |
| Route Aggregation | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Route Aggregation.md` |
| Routing Alogrithms | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Routing Alogrithms.md` |
| Routing Concepts | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Routing Concepts.md` |
| Routing Loops | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Routing Loops.md` |
| Routing Protocol Metrics | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Routing Protocol Metrics.md` |
| Router Main | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Router Main.md` |
| Computer Network Models | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/Computer Network Models.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/Quiz.md` |
| Real Life Scenarios | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/Real-Life-Scenarios.md` |
| Challenges | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/03-IP-Addressing/CHALLENGES.md` |
| Lab 01 Telnet Test | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/07-Network-Troubleshooting-Labs/lab_01_telnet_test.py` |
| Lab 02 Dns Resolver | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/07-Network-Troubleshooting-Labs/lab_02_dns_resolver.py` |
| Ip Addressing Subnetting Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/IP-Addressing-Subnetting-Ref.md` |
| Network Devices Hardware Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Network-Devices-Hardware-Ref.md` |
| Network Models Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Network-Models-Ref.md` |
| Network Protocols Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Network-Protocols-Ref.md` |
| Network Troubleshooting Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Network-Troubleshooting-Ref.md` |
| Networking Best Practices Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Networking-Best-Practices-Ref.md` |
| Get Networkinventory | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Get-NetworkInventory.ps1` |
| Measure Networklatency | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Measure-NetworkLatency.ps1` |
| Resolve Dnsissues | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Resolve-DNSIssues.ps1` |
| Test Networkdiagnostics | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Test-NetworkDiagnostics.ps1` |
| Test Portconnectivity | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Test-PortConnectivity.ps1` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/01-Introduction/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/01-Introduction/Quiz.md` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/02-Filesystem/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/02-Filesystem/Quiz.md` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/03-Commands/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/03-Commands/Quiz.md` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/04-Permissions/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/04-Permissions/Quiz.md` |
| Fedora Systemaudit | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Fedora-SystemAudit.sh` |
| Fedora Toolbox | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Fedora-Toolbox.sh` |
| Optimize Fedorafull | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Optimize-FedoraFull.sh` |
| Optimize Intelgpu | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Optimize-IntelGPU.sh` |
| Preset Generator | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Preset-Generator.sh` |
| Rollback Fedorafull | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Rollback-FedoraFull.sh` |
| Fedora Network | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/fedora-network.sh` |
| Fedora Security | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/fedora-security.sh` |
| Input Enhancer Preset | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/python/Input-Enhancer-Preset.py` |
| Preseteqgenarator | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/python/PresetEqGenarator.py` |
| Dnf Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/dnf-cheat-sheet.md` |
| Apt Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/02-Debian-Family/apt-cheat-sheet.md` |
| Zypper Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/03-SUSE-Family/zypper-cheat-sheet.md` |
| Apk Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/04-Lightweight-and-Cloud-Native/apk-cheat-sheet.md` |
| Pacman Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/04-Lightweight-and-Cloud-Native/pacman-cheat-sheet.md` |
| Distro Comparison Matrix | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/Distro-Comparison-Matrix.md` |
| Interview Questions And Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/Interview_Questions_and_Quiz.md` |
| Linux Best Practices Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-Best-Practices-Ref.md` |
| Linux Essential Commands Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-Essential-Commands-Ref.md` |
| Linux Filesystem Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-Filesystem-Ref.md` |
| Linux Permissions Ownership Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-Permissions-Ownership-Ref.md` |
| Linux Ssh Security Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-SSH-Security-Ref.md` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/SSH/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/SSH/Quiz.md` |
| Disk Usage Analyzer | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/disk-usage-analyzer.sh` |
| Linux System Audit | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/linux-system-audit.sh` |
| Permission Analyzer | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/permission-analyzer.sh` |
| Process Monitor | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/process-monitor.sh` |
| Ssh Hardening | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/ssh-hardening.sh` |
| Input Enhancer Generator | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/python/Input_Enhancer_Generator.py` |
| Preset Eq Generator | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/python/Preset_Eq_Generator.py` |
| Linkks | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Linkks.md` |
| Login Screen | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Login Screen.md` |
| Format Volume | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Format-Volume.md` |
| Get Disk | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Get-Disk.md` |
| Get Partition | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Get-Partition.md` |
| Get Volume | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Get-Volume.md` |
| Initialize Disk | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Initialize-Disk.md` |
| New Partition | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/New-Partition.md` |
| Remove Partition | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Remove-Partition.md` |
| Resize Partition | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Resize-Partition.md` |
| Set Volume | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Set-Volume.md` |
| Get Eventlog | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/EventLogs/Get-EventLog.md` |
| Get Winevent | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/EventLogs/Get-WinEvent.md` |
| Get Acl | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/FileAndACL/Get-Acl.md` |
| Set Acl | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/FileAndACL/Set-Acl.md` |
| Add Hostsentry | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Add-HostsEntry.md` |
| Audit Firewallprofiles | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Audit-FirewallProfiles.md` |
| Audit Firewallrules | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Audit-FirewallRules.md` |
| Get Processconnections | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Get-ProcessConnections.md` |
| Get Systemuptime | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Get-SystemUptime.md` |
| Get Wifipasswords | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Get-WiFiPasswords.md` |
| Reset Dnscache | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Reset-DnsCache.md` |
| Reset Networkstack | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Reset-NetworkStack.md` |
| Resolve Multidns | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Resolve-MultiDns.md` |
| Test Tcpport | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Test-TcpPort.md` |
| Toggle Firewallprofile | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Toggle-FirewallProfile.md` |
| Trace Blockedtraffic | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Trace-BlockedTraffic.md` |
| Verify Portstatus | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Verify-PortStatus.md` |
| Disable Netadapter | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Disable-NetAdapter.md` |
| Enable Netadapter | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Enable-NetAdapter.md` |
| Get Dnsclientserveraddress | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-DnsClientServerAddress.md` |
| Get Netadapter | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetAdapter.md` |
| Get Netfirewallrule | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetFirewallRule.md` |
| Get Netipaddress | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetIPAddress.md` |
| Get Netipconfiguration | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetIPConfiguration.md` |
| Get Netnat | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetNat.md` |
| Get Netneighbor | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetNeighbor.md` |
| Get Netroute | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetRoute.md` |
| Get Nettcpconnection | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetTCPConnection.md` |
| Get Netudpendpoint | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Get-NetUDPEndpoint.md` |
| New Netfirewallrule | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/New-NetFirewallRule.md` |
| Resolve Dnsname | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Resolve-DnsName.md` |
| Restart Netadapter | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Restart-NetAdapter.md` |
| Set Dnsclientserveraddress | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Set-DnsClientServerAddress.md` |
| Set Netfirewallrule | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Set-NetFirewallRule.md` |
| Test Netconnection | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Network/Test-NetConnection.md` |
| Ps Commands | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/PS Commands.md` |
| Get Item | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Registry/Get-Item.md` |
| Get Itemproperty | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Registry/Get-ItemProperty.md` |
| New Item | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Registry/New-Item.md` |
| Remove Item | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Registry/Remove-Item.md` |
| Remove Itemproperty | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Registry/Remove-ItemProperty.md` |
| Set Itemproperty | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Registry/Set-ItemProperty.md` |
| Enter Pssession | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Remoting/Enter-PSSession.md` |
| Exit Pssession | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Remoting/Exit-PSSession.md` |
| Get Pssession | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Remoting/Get-PSSession.md` |
| Invoke Command | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Remoting/Invoke-Command.md` |
| New Pssession | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Remoting/New-PSSession.md` |
| Remove Pssession | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/Remoting/Remove-PSSession.md` |
| Disable Scheduledtask | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Disable-ScheduledTask.md` |
| Enable Scheduledtask | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Enable-ScheduledTask.md` |
| Get Scheduledtask | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Get-ScheduledTask.md` |
| Get Scheduledtaskinfo | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Get-ScheduledTaskInfo.md` |
| Register Scheduledtask | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Register-ScheduledTask.md` |
| Set Scheduledtask | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Set-ScheduledTask.md` |
| Start Scheduledtask | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Start-ScheduledTask.md` |
| Stop Scheduledtask | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Stop-ScheduledTask.md` |
| Unregister Scheduledtask | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ScheduledTasks/Unregister-ScheduledTask.md` |
| Debug Process | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Debug-Process.md` |
| Get Process | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Get-Process.md` |
| Get Service | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Get-Service.md` |
| New Service | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/New-Service.md` |
| Remove Service | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Remove-Service.md` |
| Restart Service | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Restart-Service.md` |
| Set Service | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Set-Service.md` |
| Start Process | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Start-Process.md` |
| Start Service | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Start-Service.md` |
| Stop Process | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Stop-Process.md` |
| Stop Service | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Stop-Service.md` |
| Wait Process | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/ServiceAndProcess/Wait-Process.md` |
| Add Localgroupmember | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/Add-LocalGroupMember.md` |
| Get Localgroup | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/Get-LocalGroup.md` |
| Get Localgroupmember | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/Get-LocalGroupMember.md` |
| Get Localuser | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/Get-LocalUser.md` |
| New Localgroup | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/New-LocalGroup.md` |
| New Localuser | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/New-LocalUser.md` |
| Remove Localgroup | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/Remove-LocalGroup.md` |
| Remove Localgroupmember | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/Remove-LocalGroupMember.md` |
| Remove Localuser | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/Remove-LocalUser.md` |
| Set Localuser | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/UserAndGroup/Set-LocalUser.md` |
| Check Pendingupdates | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/WindowsUpdate/Check-PendingUpdates.md` |
| Get Hotfix | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/WindowsUpdate/Get-HotFix.md` |
| Get Windowsupdatelog | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/WindowsUpdate/Get-WindowsUpdateLog.md` |
| List Updatehistory | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/WindowsUpdate/List-UpdateHistory.md` |
| Devops Assessment | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/DevOps_Assessment.ps1` |
| Devops Assessment | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/DevOps_Assessment.py` |
| Active Directory Automation | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/Automation/Active Directory Automation.md` |
| Conditional Statements | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/Conditional_Statements.ps1` |
| Customobject | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/CustomObject.ps1` |
| Explain Powershell Pipeline | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/Explain-PowerShell-Pipeline.md` |
| Hashtable | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/HashTable.ps1` |
| Modules | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/Modules.ps1` |
| Pstest | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/PSTest.ps1` |
| Pipeline | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/Pipeline.ps1` |
| Powershell | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/PowerShell.md` |
| Syntax | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/Syntax.ps1` |
| System Admin | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Lessons/SystemAdmin/System Admin.md` |
| Purgemcafee | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/ProgramRemoval/purgeMcafee.ps1` |
| Purgeomen | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/ProgramRemoval/purgeOmen.ps1` |
| Windows11Debloat | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/ProgramRemoval/windows11Debloat.ps1` |
| Windowstracking | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/ProgramRemoval/windowsTracking.ps1` |
| Manage Localusers | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/scripts/Manage-LocalUsers.ps1` |
| Install Aws Cli | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-2-WSL-Linux-Integration/install-aws-cli.sh` |
| Setup Wsl Devops | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-2-WSL-Linux-Integration/setup-wsl-devops.sh` |
| Upgrade Wsl Version | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-2-WSL-Linux-Integration/upgrade-wsl-version.sh` |
| Install | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-3-Package-Management/Install.md` |
| Uninstall Applicationdeep | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-3-Package-Management/scripts/Uninstall-ApplicationDeep.ps1` |
| Product Key | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-4-Server-Administration/DataCenter/Product Key.md` |
| Product Key | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-4-Server-Administration/Standard/Product Key.md` |
| Get Diskusage | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-6-System-Auditing/Get-DiskUsage.ps1` |
| Get Systeminventory | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-6-System-Auditing/Get-SystemInventory.ps1` |
| Windows11 Debloat Risk Assessment | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-6-System-Auditing/Windows11-Debloat-Risk-Assessment.md` |
| Optimize Systemperformance | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/01-CPU-and-Process-Prioritization/Optimize-SystemPerformance.ps1` |
| Set Processorperformance | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/01-CPU-and-Process-Prioritization/Set-ProcessorPerformance.ps1` |
| Invoke Systemaudit | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/02-Memory-Management-and-Swap/Invoke-SystemAudit.ps1` |
| Invoke Systemmaintenance | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/03-Storage-I-O-Optimization/Invoke-SystemMaintenance.ps1` |
| Optimize Networkstack Server | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/04-Network-Stack-Tuning/Optimize-NetworkStack-Server.ps1` |
| Optimize Networkstack | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/04-Network-Stack-Tuning/Optimize-NetworkStack.ps1` |
| Optimize Powerplan | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/05-Power-and-Thermal-Profiles/Optimize-PowerPlan.ps1` |
| Lab Bottleneck Resolution | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/06-Labs-and-Challenges/Lab-Bottleneck-Resolution.md` |
| Set Wsl2Performance | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/07-WSL2-Optimization/Set-WSL2Performance.ps1` |
| Initialize Serverhardening | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/08-Server-Hardening/Initialize-ServerHardening.ps1` |
| Invoke Artifactcleanup | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/09-Maintenance-Automation/Invoke-ArtifactCleanup.ps1` |
| Get Systemhealthscore | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/10-Health-Monitoring/Get-SystemHealthScore.ps1` |
| Audit Report | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/AUDIT_REPORT.md` |
| Project Summary | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/PROJECT_SUMMARY.md` |
| Script Reference | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/SCRIPT_REFERENCE.md` |
| Updated Architecture | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-7-Performance-Tuning/UPDATED_ARCHITECTURE.md` |
| Product Key Windows 2019 | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Product Key Windows 2019.md` |
| Active Directory Identity Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/REFERENCE/Active-Directory-Identity-Ref.md` |
| Powershell Automation Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/REFERENCE/PowerShell-Automation-Ref.md` |
| Sre Windows Troubleshooting Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/REFERENCE/SRE-Windows-Troubleshooting-Ref.md` |
| Windows Best Practices Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/REFERENCE/Windows-Best-Practices-Ref.md` |
| Windows System Architecture Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/REFERENCE/Windows-System-Architecture-Ref.md` |
| Virtualbox Installations | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/VirtualBox Installations.md` |
| Jq Challenge | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/Json/challenges/jq_challenge.md` |
| Jq Query Solution | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/Json/solutions/jq_query_solution.sh` |
| Changelog Challenge | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/Markdown/challenges/changelog_challenge.md` |
| Changelog Goal | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/Markdown/solutions/CHANGELOG_GOAL.md` |
| Data Formats Best Practices Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/REFERENCE/Data-Formats-Best-Practices-Ref.md` |
| Json Api Standard Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/REFERENCE/JSON-API-Standard-Ref.md` |
| Markdown Documentation Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/REFERENCE/Markdown-Documentation-Ref.md` |
| Toml Configuration Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/REFERENCE/TOML-Configuration-Ref.md` |
| Xml Enterprise Legacy Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/REFERENCE/XML-Enterprise-Legacy-Ref.md` |
| Yaml Deep Dive Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/REFERENCE/YAML-Deep-Dive-Ref.md` |
| Refactor Challenge | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/Toml/challenges/refactor_challenge.md` |
| Extraction Challenge | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/Xml/challenges/extraction_challenge.md` |
| Pom Extractor | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/Xml/solutions/pom_extractor.py` |
| Dry Challenge | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/Yaml/challenges/dry_challenge.md` |
| Markdown Linter | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/scripts/markdown-linter.py` |
| Toml Config Manager | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/scripts/toml-config-manager.py` |
| Validate Json | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/scripts/validate-json.py` |
| Xml Parser | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/scripts/xml-parser.py` |
| Yaml To Json | 🌱 Beginner | `1-Beginner/01-Phase-1/04-Data-Formats/scripts/yaml-to-json.py` |
| Devops Directory Mindmap | 🌱 Beginner | `1-Beginner/01-Phase-1/05-Software-Stack/resources/DevOps-Directory-MindMap.md` |
| Backup Configurations | 🌱 Beginner | `1-Beginner/01-Phase-1/05-Software-Stack/scripts/backup-configurations.ps1` |
| Health Check Stack | 🌱 Beginner | `1-Beginner/01-Phase-1/05-Software-Stack/scripts/health-check-stack.sh` |
| Install Software Stack | 🌱 Beginner | `1-Beginner/01-Phase-1/05-Software-Stack/scripts/install-software-stack.sh` |
| Setup Dev Environment | 🌱 Beginner | `1-Beginner/01-Phase-1/05-Software-Stack/scripts/setup-dev-environment.ps1` |
| Verify Dependencies | 🌱 Beginner | `1-Beginner/01-Phase-1/05-Software-Stack/scripts/verify-dependencies.py` |
| Environment Setup | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/Environment-Setup.md` |
| Angular Enterprise Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/Angular-Enterprise-Ref.md` |
| Css Enterprise Tools Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/CSS-Enterprise-Tools-Ref.md` |
| Django Fullstack Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/Django-Fullstack-Ref.md` |
| Fastapi Modern Python Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/FastAPI-Modern-Python-Ref.md` |
| Flask Microservices Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/Flask-Microservices-Ref.md` |
| Mobile App Frameworks Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/Mobile-App-Frameworks-Ref.md` |
| Nextjs Fullstack React Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/NextJS-Fullstack-React-Ref.md` |
| Nodejs Express Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/NodeJS-Express-Ref.md` |
| React Frontend Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/React-Frontend-Ref.md` |
| Springboot Enterprise Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/SpringBoot-Enterprise-Ref.md` |
| Tailwindcss Architecture Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/TailwindCSS-Architecture-Ref.md` |
| Vuejs Progressive Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/VueJS-Progressive-Ref.md` |
| Web Design Best Practices Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/Web-Design-Best-Practices-Ref.md` |
| Web Fundamentals Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/REFERENCE/Web-Fundamentals-Ref.md` |
| Build React App | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/scripts/build-react-app.ps1` |
| Deploy Flask App | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/scripts/deploy-flask-app.sh` |
| Springboot Health Check | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/scripts/springboot-health-check.sh` |
| Test Django App | 🌱 Beginner | `1-Beginner/01-Phase-1/06-Web-Design/scripts/test-django-app.py` |
| Aws Networking Deep Dive | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/01-Basic-Networking/aws-networking-deep-dive.md` |
| Networking Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/01-Basic-Networking/networking-fundamentals.md` |
| Deployment Models Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/04-Cloud-Fundamentals/Deployment-Models/deployment-models-guide.md` |
| Service Models Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/04-Cloud-Fundamentals/Service-Models/service-models-guide.md` |
| Aws Cli Commands | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/01-Introduction/AWS CLI Commands.md` |
| Aws Fundamentals Devops | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/01-Introduction/aws-fundamentals-devops.md` |
| Aws Networking Vpc Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/02-Networking/aws-networking-vpc-guide.md` |
| Efs Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/03-Storage/EFS/efs-fundamentals.md` |
| S3 Cli Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/03-Storage/s3-bucket/s3-cli-guide.md` |
| S3 Storage Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/03-Storage/s3-storage-fundamentals.md` |
| Aws Lambda Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/04-Compute-Serverless/Lambda/aws-lambda-fundamentals.md` |
| Ec2 Compute Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/04-Compute-Serverless/ec2-compute-fundamentals.md` |
| Ecs Application Deployment Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/ECS/ecs-application-deployment-guide.md` |
| Ecs Cluster Setup Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/ECS/ecs-cluster-setup-guide.md` |
| Ecs Fundamentals Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/ECS/ecs-fundamentals-guide.md` |
| Ecs Monitoring Troubleshooting Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/ECS/ecs-monitoring-troubleshooting-guide.md` |
| Ecs Security Networking Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/ECS/ecs-security-networking-guide.md` |
| Aws Eks Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/EKS/aws-eks-fundamentals.md` |
| Eks Cluster Setup Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/EKS/eks-cluster-setup-guide.md` |
| Eks Fundamentals Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/EKS/eks-fundamentals-guide.md` |
| Eks Monitoring Troubleshooting Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/EKS/eks-monitoring-troubleshooting-guide.md` |
| Eks Security Networking Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/EKS/eks-security-networking-guide.md` |
| Eks Workload Deployment Guide | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/05-Containers/EKS/eks-workload-deployment-guide.md` |
| Active Directory  Configuration | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/06-Identity/Active Directory  Configuration.md` |
| Cognito Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/06-Identity/Cognito/cognito-fundamentals.md` |
| How To Join Windows Server 2019 To An Existing Active Directory Domain | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/06-Identity/How to Join Windows Server 2019 to an existing Active Directory Domain.md` |
| Iam Ad Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/06-Identity/iam-ad-fundamentals.md` |
| Sns Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/07-Messaging/SNS/sns-fundamentals.md` |
| Sqs Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/07-Messaging/SQS/sqs-fundamentals.md` |
| Route53 Fundamentals | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/08-Web-Hosting/Route53/route53-fundamentals.md` |
| Pwd | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/08-Web-Hosting/Wordpress/PWD.md` |
| Ubuntuwordpress | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/08-Web-Hosting/Wordpress/UbuntuWordPress.md` |
| Connect | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/99-Resources/AWS/Connect.md` |
| Meta Data | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/99-Resources/AWS/Meta-Data.md` |
| Microsoft Visual C++ Redistributable Packages | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/99-Resources/AWS/Microsoft Visual C++ Redistributable Packages.md` |
| Notes | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/99-Resources/AWS/Notes.md` |
| How To Install And Configure A Dns Server On Windows Server 2019 | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/99-Resources/AWS/Server Manager/DNS Server/How to install and configure a DNS server on Windows Server 2019.md` |
| Tools Tab | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/99-Resources/AWS/Server Manager/Tools Tab.md` |
| Aws Core Services Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/AWS-Core-Services-Ref.md` |
| Azure Core Services Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/Azure-Core-Services-Ref.md` |
| Cloud Computing Models Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/Cloud-Computing-Models-Ref.md` |
| Cloud Performance Optimization Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/Cloud-Performance-Optimization-Ref.md` |
| Cloud Security Compliance Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/Cloud-Security-Compliance-Ref.md` |
| Container Orchestration Cloud Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/Container-Orchestration-Cloud-Ref.md` |
| Finops Cloud Economics Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/FinOps-Cloud-Economics-Ref.md` |
| Gcp Core Services Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/GCP-Core-Services-Ref.md` |
| Multi Cloud Migration Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/Multi-Cloud-Migration-Ref.md` |
| Serverless Architecture Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/Serverless-Architecture-Ref.md` |
| Aws Resource Inventory | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/scripts/aws-resource-inventory.py` |
| Azure Cost Analyzer | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/scripts/azure-cost-analyzer.ps1` |
| Cloud Security Audit | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/scripts/cloud-security-audit.py` |
| Gcp Project Setup | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/scripts/gcp-project-setup.sh` |
| Multi Cloud Health Check | 🌱 Beginner | `1-Beginner/01-Phase-1/07-Cloud-Foundations/scripts/multi-cloud-health-check.py` |
| Challenges | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/01-Git-GitHub/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/02-GitLab/CHALLENGES.md` |
| Learning Path Summary | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/02-GitLab/LEARNING_PATH_SUMMARY.md` |
| Challenges | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/03-Bitbucket/CHALLENGES.md` |
| Consolidation Summary | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/CONSOLIDATION_SUMMARY.md` |
| Interview Questions And Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/Interview-Questions-and-Quiz.md` |
| Branching Strategies Comparison Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/REFERENCE/Branching-Strategies-Comparison-Ref.md` |
| Git Internal Architecture Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/REFERENCE/Git-Internal-Architecture-Ref.md` |
| Gitlab Vs Github Enterprise Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/REFERENCE/GitLab-vs-GitHub-Enterprise-Ref.md` |
| Legacy Vcs Migration Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/REFERENCE/Legacy-VCS-Migration-Ref.md` |
| Real Life Scenarios | 🌱 Beginner | `1-Beginner/01-Phase-1/08-Repository-Management/Real-Life-Scenarios.md` |
| 01 Maturity Model | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/00-Foundations/Part-01-Philosophy-and-Mindset/01-Maturity-Model.md` |
| 02 Automation Workflow | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/00-Foundations/Part-01-Philosophy-and-Mindset/02-Automation-Workflow.md` |
| 01 Tools Comparison | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/00-Foundations/Part-02-Tooling-Landscape/01-Tools-Comparison.md` |
| 02 How To Read Scripts | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/00-Foundations/Part-02-Tooling-Landscape/02-How-to-Read-Scripts.md` |
| 01 Shell Customization | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/00-Foundations/Part-03-Environment-Setup/01-Shell-Customization.md` |
| Audit Summary | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/AUDIT_SUMMARY.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/01-Introduction/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/02-Terminal-and-Navigation/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/03-File-Manipulation/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/03-File-Manipulation/Hidden-Files/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/03-File-Manipulation/Paging/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/03-File-Manipulation/Searching/CHALLENGES.md` |
| Calculate System Metrics | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/03-File-Manipulation/Searching/calculate-system-metrics.sh` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/04-Man-Pages-and-Help/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/05-Vim-Basics/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/06-Permissions/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/07-Basic-Variables/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-01-Shell-Foundations/08-Programs-and-Commands/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/01-Arithmetic-and-Metrics/CHALLENGES.md` |
| Readme Advanced | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/01-Arithmetic-and-Metrics/README_advanced.md` |
| Calculate Metrics | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/01-Arithmetic-and-Metrics/calculate_metrics.sh` |
| Operators | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/01-Arithmetic-and-Metrics/operators.sh` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/02-User-Input/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/03-Conditionals/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/04-Loops-and-Processing/CHALLENGES.md` |
| Readme Advanced | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/04-Loops-and-Processing/README_advanced.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/05-Functions-and-Scope/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-02-Shell-Architecture/06-Strict-Mode-Safety/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-03-System-Drafting/01-Scripting-Basics/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/Part-03-System-Drafting/02-Advanced-IO/CHALLENGES.md` |
| Bash Architecture Ref | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/REFERENCE/Bash-Architecture-Ref.md` |
| Posix Vs Bash Compatibility Ref | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/REFERENCE/POSIX-vs-Bash-Compatibility-Ref.md` |
| Regular Expressions Ref | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/REFERENCE/Regular-Expressions-Ref.md` |
| Script Hardening Best Practices Ref | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/REFERENCE/Script-Hardening-Best-Practices-Ref.md` |
| Shell Fundamentals Ref | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/REFERENCE/Shell-Fundamentals-Ref.md` |
| Stream Editing Filtering Ref | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/REFERENCE/Stream-Editing-Filtering-Ref.md` |
| Refcheatsheet | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/examples/Cheatsheets/refCheatSheet.md` |
| Os Test | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/examples/os_test.sh` |
| Pdf Scraper | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/resources/pdf_scraper.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/01-Fundamentals/CHALLENGES.md` |
| System Monitor Demo | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/01-Fundamentals/system_monitor_demo.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/02-Control-Flow/CHALLENGES.md` |
| Lab 01 Log Filter | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/02-Control-Flow/lab_01_log_filter.py` |
| Lab 02 Validator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/02-Control-Flow/lab_02_validator.py` |
| Lab 03 Port Checker | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/02-Control-Flow/lab_03_port_checker.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/03-Iterative-Logic-and-Loops/CHALLENGES.md` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/04-Data-Structures/CHALLENGES.md` |
| Challenge 01 Inventory Mgmt | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/04-Data-Structures/challenges/challenge_01_inventory_mgmt.py` |
| Challenge 02 Log Dedup | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/04-Data-Structures/challenges/challenge_02_log_dedup.py` |
| Challenge 03 Config Merger | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/04-Data-Structures/challenges/challenge_03_config_merger.py` |
| Solution 01 Inventory Mgmt | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/04-Data-Structures/challenges/solutions/solution_01_inventory_mgmt.py` |
| Solution 02 Log Dedup | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/04-Data-Structures/challenges/solutions/solution_02_log_dedup.py` |
| Solution 03 Config Merger | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/04-Data-Structures/challenges/solutions/solution_03_config_merger.py` |
| Drift Detector Demo | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/04-Data-Structures/drift_detector_demo.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/05-Error-Handling/CHALLENGES.md` |
| Challenge 01 Config Loader | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/05-Error-Handling/challenges/challenge_01_config_loader.py` |
| Challenge 02 Health Retry | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/05-Error-Handling/challenges/challenge_02_health_retry.py` |
| Challenge 03 Shutdown Handler | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/05-Error-Handling/challenges/challenge_03_shutdown_handler.py` |
| Solution 01 Config Loader | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/05-Error-Handling/challenges/solutions/solution_01_config_loader.py` |
| Solution 02 Health Retry | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/05-Error-Handling/challenges/solutions/solution_02_health_retry.py` |
| Solution 03 Shutdown Handler | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/05-Error-Handling/challenges/solutions/solution_03_shutdown_handler.py` |
| Resilient Deployer Demo | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/05-Error-Handling/resilient_deployer_demo.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/06-File-IO-DevOps/CHALLENGES.md` |
| Log Processor Demo | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/06-File-IO-DevOps/log_processor_demo.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/CHALLENGES.md` |
| Challenge 01 Health Checker | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/challenges/challenge_01_health_checker.py` |
| Challenge 02 Retry Decorator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/challenges/challenge_02_retry_decorator.py` |
| Challenge 03 Config Module | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/challenges/challenge_03_config_module.py` |
| Solution 01 Health Checker | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/challenges/solutions/solution_01_health_checker.py` |
| Solution 02 Retry Decorator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/challenges/solutions/solution_02_retry_decorator.py` |
|   Init   | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/challenges/solutions/solution_03_config_pkg/config/__init__.py` |
| Loader | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/challenges/solutions/solution_03_config_pkg/config/loader.py` |
| Settings | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/challenges/solutions/solution_03_config_pkg/config/settings.py` |
| Cloud Dispatcher Demo | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/07-Functions-and-Modules/cloud_dispatcher_demo.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/08-Cloud-Automation-Boto3/CHALLENGES.md` |
| Testing With Moto | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/08-Cloud-Automation-Boto3/TESTING_WITH_MOTO.md` |
| Conftest | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/08-Cloud-Automation-Boto3/conftest.py` |
| S3 Janitor | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/08-Cloud-Automation-Boto3/s3_janitor.py` |
| Test S3 Janitor | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/08-Cloud-Automation-Boto3/test_s3_janitor.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/CHALLENGES.md` |
| Challenge 01 Backup Check | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/challenges/challenge_01_backup_check.py` |
| Challenge 02 Log Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/challenges/challenge_02_log_parser.py` |
| Challenge 03 Sla Calculator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/challenges/challenge_03_sla_calculator.py` |
| Challenge 04 Scheduler | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/challenges/challenge_04_scheduler.py` |
| Solution 01 Backup Check | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/challenges/solutions/solution_01_backup_check.py` |
| Solution 02 Log Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/challenges/solutions/solution_02_log_parser.py` |
| Solution 03 Sla Calculator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/challenges/solutions/solution_03_sla_calculator.py` |
| Solution 04 Scheduler | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/challenges/solutions/solution_04_scheduler.py` |
| Log Retention Demo | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-01-Python-Foundations/09-Time-and-Date/log_retention_demo.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/CHALLENGES.md` |
| Challenge 01 Log Cleanup | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/challenges/challenge_01_log_cleanup.py` |
| Challenge 02 Project Analyzer | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/challenges/challenge_02_project_analyzer.py` |
| Challenge 03 Safe Backup | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/challenges/challenge_03_safe_backup.py` |
| Challenge 04 Sync Dirs | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/challenges/challenge_04_sync_dirs.py` |
| Solution 01 Log Cleanup | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/challenges/solutions/solution_01_log_cleanup.py` |
| Solution 02 Project Analyzer | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/challenges/solutions/solution_02_project_analyzer.py` |
| Solution 03 Safe Backup | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/challenges/solutions/solution_03_safe_backup.py` |
| Solution 04 Sync Dirs | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/01-Pathlib-Modern-Files/challenges/solutions/solution_04_sync_dirs.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/02-JSON-Handling/CHALLENGES.md` |
| Challenge 01 Api Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/02-JSON-Handling/challenges/challenge_01_api_parser.py` |
| Challenge 02 Config Validator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/02-JSON-Handling/challenges/challenge_02_config_validator.py` |
| Challenge 03 Json Diff | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/02-JSON-Handling/challenges/challenge_03_json_diff.py` |
| Solution 01 Api Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/02-JSON-Handling/challenges/solutions/solution_01_api_parser.py` |
| Solution 02 Config Validator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/02-JSON-Handling/challenges/solutions/solution_02_config_validator.py` |
| Solution 03 Json Diff | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/02-JSON-Handling/challenges/solutions/solution_03_json_diff.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/CHALLENGES.md` |
| Challenge 01 Manifest Gen | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/challenges/challenge_01_manifest_gen.py` |
| Challenge 02 Inventory Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/challenges/challenge_02_inventory_parser.py` |
| Challenge 03 Config Merger | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/challenges/challenge_03_config_merger.py` |
| Challenge 04 Ansible Inventory | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/challenges/challenge_04_ansible_inventory.py` |
| Solution 01 Manifest Gen | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/challenges/solutions/solution_01_manifest_gen.py` |
| Solution 02 Inventory Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/challenges/solutions/solution_02_inventory_parser.py` |
| Solution 03 Config Merger | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/challenges/solutions/solution_03_config_merger.py` |
| Solution 04 Ansible Inventory | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/03-YAML-Handling/challenges/solutions/solution_04_ansible_inventory.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/04-Testing-and-QA/CHALLENGES.md` |
| Challenge 01 Config Loader | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/04-Testing-and-QA/challenges/challenge_01_config_loader.py` |
| Challenge 02 Health Retry | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/04-Testing-and-QA/challenges/challenge_02_health_retry.py` |
| Challenge 03 Shutdown Handler | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/04-Testing-and-QA/challenges/challenge_03_shutdown_handler.py` |
| Solution 01 Config Loader | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/04-Testing-and-QA/challenges/solutions/solution_01_config_loader.py` |
| Solution 02 Health Retry | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/04-Testing-and-QA/challenges/solutions/solution_02_health_retry.py` |
| Solution 03 Shutdown Handler | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/04-Testing-and-QA/challenges/solutions/solution_03_shutdown_handler.py` |
| Resilient Deployer Demo | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/04-Testing-and-QA/resilient_deployer_demo.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/CHALLENGES.md` |
| Challenge 01 Venv Creator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/challenges/challenge_01_venv_creator.py` |
| Challenge 02 Req Checker | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/challenges/challenge_02_req_checker.py` |
| Challenge 03 Portable Setup | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/challenges/challenge_03_portable_setup.py` |
| Challenge 04 Isolated Task | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/challenges/challenge_04_isolated_task.py` |
| Solution 01 Venv Creator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/challenges/solutions/solution_01_venv_creator.py` |
| Solution 02 Req Checker | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/challenges/solutions/solution_02_req_checker.py` |
| Solution 03 Portable Setup | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/challenges/solutions/solution_03_portable_setup.py` |
| Solution 04 Isolated Task | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/05-Virtual-Environments/challenges/solutions/solution_04_isolated_task.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/CHALLENGES.md` |
| Challenge 01 Dependency Analyzer | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/challenges/challenge_01_dependency_analyzer.py` |
| Challenge 02 Pip Wrapper | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/challenges/challenge_02_pip_wrapper.py` |
| Challenge 03 Version Bumper | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/challenges/challenge_03_version_bumper.py` |
| Challenge 04 Conflict Finder | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/challenges/challenge_04_conflict_finder.py` |
| Solution 01 Dependency Analyzer | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/challenges/solutions/solution_01_dependency_analyzer.py` |
| Solution 02 Pip Wrapper | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/challenges/solutions/solution_02_pip_wrapper.py` |
| Solution 03 Version Bumper | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/challenges/solutions/solution_03_version_bumper.py` |
| Solution 04 Conflict Finder | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/06-Package-Management/challenges/solutions/solution_04_conflict_finder.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/CHALLENGES.md` |
| Challenge 01 Nginx Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/challenges/challenge_01_nginx_parser.py` |
| Challenge 02 Data Masker | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/challenges/challenge_02_data_masker.py` |
| Challenge 03 Error Aggregator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/challenges/challenge_03_error_aggregator.py` |
| Challenge 04 Config Extractor | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/challenges/challenge_04_config_extractor.py` |
| Solution 01 Nginx Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/challenges/solutions/solution_01_nginx_parser.py` |
| Solution 02 Data Masker | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/challenges/solutions/solution_02_data_masker.py` |
| Solution 03 Error Aggregator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/challenges/solutions/solution_03_error_aggregator.py` |
| Solution 04 Config Extractor | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-02-Python-Architecture/07-Regular-Expressions/challenges/solutions/solution_04_config_extractor.py` |
| Challenge 01 Port Scanner | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/challenge_01_port_scanner.py` |
| Challenge 02 File Args | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/challenge_02_file_args.py` |
| Challenge 03 Safety Flags | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/challenge_03_safety_flags.py` |
| Challenge 04 Subcommands | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/challenge_04_subcommands.py` |
| Challenge 05 Env Override | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/challenge_05_env_override.py` |
| Challenge 06 Cli Wrapper | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/challenge_06_cli_wrapper.py` |
| Solution 01 Port Scanner | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/solutions/solution_01_port_scanner.py` |
| Solution 02 File Args | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/solutions/solution_02_file_args.py` |
| Solution 03 Safety Flags | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/solutions/solution_03_safety_flags.py` |
| Solution 04 Subcommands | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/solutions/solution_04_subcommands.py` |
| Solution 05 Env Override | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/solutions/solution_05_env_override.py` |
| Solution 06 Cli Wrapper | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/challenges/solutions/solution_06_cli_wrapper.py` |
| Deployer Demo | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/01-Command-Line-Arguments/deployer_demo.py` |
| Challenges | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/CHALLENGES.md` |
| Challenge 01 Validator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/challenge_01_validator.py` |
| Challenge 02 Masking Logger | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/challenge_02_masking_logger.py` |
| Challenge 03 Bool Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/challenge_03_bool_parser.py` |
| Challenge 04 Dynamic Loader | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/challenge_04_dynamic_loader.py` |
| Challenge 05 Prefix Loader | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/challenge_05_prefix_loader.py` |
| Solution 01 Validator | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/solutions/solution_01_validator.py` |
| Solution 02 Masking Logger | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/solutions/solution_02_masking_logger.py` |
| Solution 03 Bool Parser | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/solutions/solution_03_bool_parser.py` |
| Solution 04 Dynamic Loader | 🌱 Beginner | `1-Beginner/02-Phase-2/01-Automation/02-Python-Basics/Part-03-Python-Systems-Drafting/02-Environment-Variables/challenges/solutions/solution_04_dynamic_loader.py` |

</details>


---

## 🕒 Recent Activity (Auto-Generated)

| File | Last Modified | Path |
| :--- | :--- | :--- |
| 01-Core-Automation-Keywords.md | 2026-02-05 00:09 | `2-Intermediate/02-Phase-2/01-Infrastructure-Automation/01-Scripting-Automation/02-Python-for-Infrastructure/01-Part-1-The-Blueprint/04-Reference/01-Core-Automation-Keywords.md` |
| README.md | 2026-02-04 23:32 | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/03-Storage/EFS/README.md` |
| efs-fundamentals.md | 2026-02-04 23:32 | `1-Beginner/01-Phase-1/07-Cloud-Foundations/05-AWS-Basics/03-Storage/EFS/efs-fundamentals.md` |
| README.md | 2026-02-04 23:32 | `1-Beginner/01-Phase-1/02-Linux/README.md` |
| README.md | 2026-02-04 23:32 | `1-Beginner/01-Phase-1/03-Windows-Basics/README.md` |


---

## 🛡️ Repository Standards
1.  **Atomicity**: Every functional module MUST have its own `REFERENCE.md`.
2.  **No Rot**: Use the [Link Scanner](./00-Resources/01-Scripts-Code/Maintenance/repository_audit.py) to verify internal links.
3.  **Hierarchy**: Follow the `Beginner -> Intermediate -> Advanced` flow for learning.

---
*"Infrastructure is code. Knowledge is scale."*
