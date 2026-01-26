# 🌟 Windows Best Practices: The DevOps Standard
*Version 1.0 | Ensuring Security, Stability, and Automated Fleet Management*

---

## 📖 Overview
Windows automation at scale requires shifting from a "GUI-first" mindset to a "Code-first" mindset. These standards ensure that your Windows servers remain secure, predictable, and compliant with enterprise industry standards.

---

## 🛡️ Security & Identity Standards

### Principle of Least Privilege (JEA)
**Definition**: Just Enough Administration (JEA) is a security technology that enables role-based administration through PowerShell remoting.
**Action**: Restrict admins to only the cmdlets they need (e.g., "SQL-Admins" can only run `Restart-Service mssqlserver`).

### PowerShell Remoting (WinRM)
**Definition**: The primary management protocol for remote Windows administration (Port 5985/5986).
**Standard**: **Always use HTTPS (5986)** for WinRM to ensure traffic is encrypted and authenticated.

### CIS Benchmarking
**Definition**: The Center for Internet Security (CIS) provides a global standard for hardening the Windows OS.
**Action**: Implement GPO templates that disable legacy protocols (SMBv1, LLMNR) and enforce password complexity.

---

## 🏗️ Configuration & Automation Hygiene

### Desired State Configuration (DSC)
**Definition**: A management platform in PowerShell that allows you to manage IT and development infrastructure with configuration as code.
**Action**: Use DSC to ensure every IIS server in the fleet has the exact same feature set and file structure.

### Idempotent Scripting
**Definition**: Ensuring a script can be run 10 times without changing the final state or causing errors.
**Example**: Use `if (-not (Test-Path $dir)) { New-Item $dir }` instead of just `New-Item $dir`.

### Patch Management (WSUS / Intune)
**Definition**: Automating the delivery of Windows Security updates.
**Action**: Stagger patches (Dev → Staging → Prod) to identify breaking changes before they hit critical workloads.

---

## ⚡ Performance & Stability Standards

### Managed Service Accounts (gMSA)
**Definition**: Domain-level accounts that manage their own password rotation automatically.
**Action**: Never use "Domain Admin" for an application service account; use a gMSA.

### Disk Tiering & Mount Points
**Definition**: Separating OS code from Application data and Logs.
**Standard**: OS on `C:`, Application on `D:`, Logs on `L:`, and Pagefile on a high-speed SSD.

### Logging as Code
**Definition**: Centralizing Windows logs using agents like "WinLogBeat" or "CloudWatch Agent."
**Action**: Ensure Event IDs like 4624 (Logon success) and 4625 (Logon failure) are being alerted on.

---

## ✅ SRE Windows Checklist
- [ ] Is RDP restricted with Network Level Authentication (NLA)?
- [ ] Is PowerShell Execution Policy set to `RemoteSigned`?
- [ ] Are old user profiles being cleaned up to preserve disk space?
- [ ] Is Windows Defender (or EDR) updated and reporting to a central dashboard?
- [ ] Is the "Administrator" account renamed and heavily restricted?

---
**Next Step**: [Back to System Architecture →](./Windows-System-Architecture-Ref.md)
