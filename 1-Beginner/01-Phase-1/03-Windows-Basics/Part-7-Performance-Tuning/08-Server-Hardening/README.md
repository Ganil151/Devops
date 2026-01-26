# Server Hardening Automation

![Security](https://img.shields.io/badge/Security-Hardened-DC143C?style=for-the-badge&logo=security&logoColor=white)
![Windows Server](https://img.shields.io/badge/Windows_Server-2019|2022-0078D4?style=for-the-badge&logo=windows&logoColor=white)

## 🎯 Overview

This module implements a **security-first baseline** for Windows Server 2019/2022 CI/CD nodes. It systematically reduces the attack surface by disabling non-essential services, configuring secure automation policies, and establishing enterprise-grade security controls.

## 🔒 Security Philosophy

**Principle**: "Secure by Default, Enable by Exception"

In DevOps infrastructure, servers should run **only the services required** for CI/CD operations. Every unnecessary service is a potential attack vector.

## ⚠️ Attack Surface Reduction

### [Initialize-ServerHardening.ps1](./Initialize-ServerHardening.ps1)

**Purpose**: Enterprise-grade Windows Server hardening automation for CI/CD infrastructure.

**Services Disabled**:

| Service | Reason | CVE Reference |
|---------|--------|---------------|
| **Print Spooler** | PrintNightmare vulnerability | CVE-2021-34527 |
| **Xbox Services** | Gaming services on server | N/A (Resource waste) |
| **Telemetry Services** | Privacy and bandwidth | N/A |
| **Remote Registry** | Remote attack vector | CIS Benchmark |
| **Windows Search** | High disk I/O overhead | N/A |
| **Bluetooth** | Hardware not present | N/A |

**Total Services Disabled**: 13 non-essential services

## ✅ Security Controls Implemented

### 1. Service Attack Surface Reduction
- Disables Print Spooler (PrintNightmare mitigation)
- Removes Xbox and gaming services
- Stops telemetry collection services

### 2. PowerShell Execution Policy
- Sets `RemoteSigned` for secure automation
- Allows local scripts while blocking unsigned remote scripts

### 3. Windows Defender Optimization
- Excludes build directories from real-time scanning
- Schedules scans for off-peak hours (2:00 AM)

### 4. Remote Desktop Security
- Enables Network Level Authentication (NLA)
- Configures firewall rules
- Optional: Enable with `-EnableRDP` flag

### 5. Audit Logging
- Enables process creation auditing
- Enables logon/logoff auditing
- Provides forensic capabilities

### 6. Firewall Enforcement
- Enables all firewall profiles (Domain, Public, Private)
- Ensures baseline network protection

## 🚀 Usage

### Basic Hardening (Recommended)

```powershell
.\Initialize-ServerHardening.ps1
```

Applies full hardening with System Restore Point.

### Enable Remote Desktop

```powershell
.\Initialize-ServerHardening.ps1 -EnableRDP
```

Harden server and enable secure RDP access.

### Preview Changes (WhatIf)

```powershell
.\Initialize-ServerHardening.ps1 -WhatIf
```

Preview all changes without modifying the system.

### Skip Restore Point (Not Recommended)

```powershell
.\Initialize-ServerHardening.ps1 -SkipRestorePoint
```

Skip System Restore Point creation (faster but less safe).

## 📊 Hardening Results

**Expected Output**:
```
Services Disabled:    13
Execution Policy:     RemoteSigned
Audit Logging:        Enabled
Firewall:             Enforced
Remote Desktop:       Enabled (NLA)
Duration:             ~15 seconds
```

## 🛡️ Safety Features

### System Restore Point
- Created before any modifications
- Allows full rollback if needed
- Recommended for production servers

### Service State Backup
- JSON backup of all service states
- Stored in `C:\ProgramData\DevOps_Logs\Hardening\`
- Enables manual restoration if needed

### Idempotent Execution
- Safe to run multiple times
- Skips already-disabled services
- No duplicate changes

## 🎓 Compliance Alignment

This script aligns with:
- **CIS Benchmarks** for Windows Server
- **DISA STIG** security requirements
- **Microsoft Security Baselines**

## 🔧 Rollback Procedure

### Option 1: System Restore (Recommended)

```powershell
# List restore points
Get-ComputerRestorePoint

# Restore to pre-hardening state
Restore-Computer -RestorePoint <RestorePointNumber>
```

### Option 2: Manual Service Re-enablement

```powershell
# Re-enable a specific service
Set-Service -Name "Spooler" -StartupType Automatic
Start-Service -Name "Spooler"
```

## 📖 Post-Hardening Checklist

- [ ] Reboot the server
- [ ] Verify CI/CD agent functionality
- [ ] Test build pipeline execution
- [ ] Review hardening log file
- [ ] Document any service re-enablement needs

## 🚨 Important Notes

### Services You May Need to Re-enable

**Print Spooler**: Only if server requires printing functionality (rare for CI/CD nodes)

```powershell
Set-Service -Name "Spooler" -StartupType Automatic
Start-Service -Name "Spooler"
```

**Windows Search**: Only if full-text search is required

```powershell
Set-Service -Name "WSearch" -StartupType Automatic
Start-Service -Name "WSearch"
```

## 📚 Related Resources

- [CIS Windows Server 2022 Benchmark](https://www.cisecurity.org/benchmark/microsoft_windows_server)
- [Microsoft Security Baselines](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-security-baselines)
- [PrintNightmare Mitigation](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-34527)

---

**Next Steps**: Run the script, reboot, and verify your CI/CD pipeline functionality!

---

*Enterprise Security for DevOps Infrastructure*
