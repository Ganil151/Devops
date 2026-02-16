# 🪟 Windows PowerShell for DevOps: Restored Command Library

> **"In a hybrid cloud world, ignoring Windows is like being a mechanic who only works on Fords."**

## 🎯 Why This Content Was Restored

This extensive PowerShell command library was originally located in `99-supplemental-content` but represents **core competency** for any DevOps engineer working in enterprise environments. It has been restored in full to ensure you have the complete toolkit.

---

## 📚 Command Categories (Fully Restored)

### 🔥 Network Stack Management
- **[Get-NetAdapter](./commands/network/get-netadapter.md)**: List all network interfaces
- **[Get-NetFirewallRule](./commands/network/get-netfirewallrule.md)**: Audit firewall rules
- **[Test-NetConnection](./commands/network/test-netconnection.md)**: The PowerShell equivalent of `telnet`
- **[Reset-NetworkStack](./commands/hacksandtips/reset-networkstack.md)**: Nuclear option for network issues

### 💾 Disk & Storage Operations
- **[Get-Disk](./commands/diskandstorage/get-disk.md)**: List physical disks
- **[Initialize-Disk](./commands/diskandstorage/initialize-disk.md)**: Prepare new disks
- **[Resize-Partition](./commands/diskandstorage/resize-partition.md)**: Expand volumes without downtime

### 📊 Event Log Analysis
- **[Get-WinEvent](./commands/eventlogs/get-winevent.md)**: Modern event log querying
- **[Get-EventLog](./commands/eventlogs/get-eventlog.md)**: Legacy event log access

### 🔐 File ACLs & Permissions
- **[Get-Acl](./commands/fileandacl/get-acl.md)**: Read NTFS permissions
- **[Set-Acl](./commands/fileandacl/set-acl.md)**: Modify file security

### 🛠️ SRE Hacks & Tips
- **[Get-WiFiPasswords](./commands/hacksandtips/get-wifipasswords.md)**: Extract saved WiFi credentials
- **[Test-TcpPort](./commands/hacksandtips/test-tcpport.md)**: Quick port connectivity check
- **[Trace-BlockedTraffic](./commands/hacksandtips/trace-blockedtraffic.md)**: Firewall forensics

---

## 🆘 Senior DevOps Perspective

**Why PowerShell Matters**:
- **Azure Cloud**: Native automation language
- **Windows Server**: The only shell that matters
- **Active Directory**: PowerShell is the API

**Real-World Use Case**: Automating IIS log rotation across 500 Windows servers. Bash can't help you here.

---

## 📂 Full Directory Structure

This restoration includes:
- **10 Command Categories**: Network, Disk, Registry, Remoting, Services, Users, Scheduled Tasks, Event Logs, ACLs, Windows Update
- **100+ Individual Command Guides**: Each with syntax, examples, and SRE tips
- **7 Performance Tuning Modules**: CPU, Memory, Storage, Network, Power, WSL2, Server Hardening
- **Reference Documentation**: Active Directory, System Architecture, Troubleshooting

---

*This content was restored from the 2026 Data Recovery Audit. Original location: `99-supplemental-content/01-phase-1/03-windows-basics/`*
