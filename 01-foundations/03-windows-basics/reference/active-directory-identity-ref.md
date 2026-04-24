# 🌐 Active Directory & Identity: The SRE Manual
*Version 1.0 | Identity, Authentication, and Governance*

---

## 📖 Overview
Active Directory (AD) is the primary directory service for Windows Domain networks. For SREs, it is the "Source of Truth" for identity. Automated user provisioning, group-based permissions, and Group Policy Objects (GPO) are the foundation of centralized Windows fleet management.

---

## 🏗️ Core AD Objects

### Domain Controller (DC)
**Definition**: A server that responds to security authentication requests (logging in, checking permissions) within a Windows domain.
**Service**: Runs the Active Directory Domain Services (AD DS).

### Organizational Unit (OU)
**Definition**: A container within an Active Directory domain that can hold users, groups, computers, and other OUs.
**Standard**: Used to delegate administrative tasks and apply Group Policy Objects.

### Groups (Security vs Distribution)
**Definition**: Collections of users. **Security Groups** are used to assign permissions to resources; **Distribution Groups** are used for email lists.
**Rule**: Always use Security Groups for IAM (Identity and Access Management).

### Groups (Global vs Universal)
**Definition**: Scopes of groups. **Global** groups hold users from the same domain; **Universal** groups can hold objects from any domain in the forest.

---

## ⚙️ Authentication & Policy

### Kerberos
**Definition**: The primary authentication protocol for Windows domains. It uses "Tickets" to prove identity without passing passwords over the wire.
**TCP Port**: 88.

### Group Policy Object (GPO)
**Definition**: A collection of settings that define what a system will look like and how it will behave for a defined group of users or computers.
**Example**: Enforcing a specific background image, disabling USB drives, or installing software automatically.

### RSOP (Resultant Set of Policy)
**Definition**: A report that shows what GPOs are actually being applied to a specific user or computer.
**Command**: `gpresult /r`.

---

## 🔧 AD PowerShell Automation

### `Get-ADUser`
**Definition**: Retrieves one or more Active Directory users.
**Example**: `Get-ADUser -Filter "Enabled -eq '$false'" | Select-Object Name` (Find all disabled users).

### `New-ADGroup`
**Definition**: Creates a new Active Directory group.
**Example**: `New-ADGroup -Name "DevOps-Admins" -GroupScope Global`.

### `Set-ADComputer`
**Definition**: Modifies an Active Directory computer object.
**Example**: `Set-ADComputer -Identity "PROD-SQL-01" -Location "DataCenter-1"`.

---

## 💡 SRE Pro-Tips
- **DNS Dependency**: Active Directory *is* DNS. If AD is broken, 99.9% of the time, check your DNS records first.
- **The "AdminSDHolder" Trap**: Protected groups (like Domain Admins) have their permissions reset every 60 minutes to prevent unauthorized changes.
- **AD Recycle Bin**: Always enable the "Active Directory Recycle Bin" to recover deleted objects without full tape restores.

---
**Next Step**: [Windows Troubleshooting & Performance →](./sre-windows-troubleshooting-ref.md)
