# 🏛️ Windows System Architecture: The SRE Reference
*Version 1.0 | Understanding the Core OS Engine*

---

## 📖 Overview
Windows architecture is built on a hybrid kernel design. For DevOps practitioners, understanding how the Registry, Services, and Event logs interact is critical for managing Windows Server fleets, automating application deployments, and performing deep-level troubleshooting.

---

## ⚙️ Core System Components

### Windows Registry
**Definition**: A hierarchical database that stores configuration settings and options on Microsoft Windows operating systems. It contains settings for low-level OS components and applications running on the platform.
**Example**:
- **HKEY_LOCAL_MACHINE (HKLM)**: System-wide settings (e.g., `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion`).
- **HKEY_CURRENT_USER (HKCU)**: User-specific settings.

### Windows Services (SCM)
**Definition**: Long-running executable applications that operate in their own Windows session. They can be automatically started when the computer boots, can be paused and restarted, and do not show any user interface. Managed by the Service Control Manager (SCM).
**Example**:
- **Service Name**: `W3SVC` (World Wide Web Publishing Service for IIS).
- **Control**: `Get-Service | Start-Service`.

### Windows Management Instrumentation (WMI / CIM)
**Definition**: The infrastructure for management data and operations on Windows-based operating systems. It allows for querying system state (CPU, Disk, Processes) via a standardized SQL-like interface.
**Example**:
- **Usage**: `Get-CimInstance -ClassName Win32_OperatingSystem` to get OS details.

### Windows Event Logs
**Definition**: A centralized database where the OS and applications record significant occurrences (Errors, Warnings, Information).
**Channels**:
- **System**: OS-level issues (Driver failures, hardware).
- **Application**: Software-specific errors (SQL Server, IIS).
- **Security**: Login attempts, privilege changes.

---

## 🏗️ Execution & User Modes

### User Mode vs. Kernel Mode
**Definition**: **User Mode** is where applications run, isolated from each other via virtual memory. **Kernel Mode** is where the OS core and drivers execute with unrestricted access to hardware.
**SRE Impact**: A crash in User Mode kills one app; a crash in Kernel Mode causes a BSOD (Blue Screen of Death).

### Session 0 Isolation
**Definition**: A security feature where services run in Session 0, separate from the user sessions.
**DevOps Impact**: Automation scripts running as services cannot interact with the UI of a user's desktop.

### Dynamic Link Libraries (DLLs)
**Definition**: Microsoft's implementation of the shared library concept. Code that can be used by multiple programs at the same time.
**Risk**: "DLL Hell" (Version conflicts) is largely solved by the Global Assembly Cache (GAC) or Side-by-Side (SxS) assemblies.

---

## 💡 SRE Pro-Tips
- **Registry Saftey**: Never edit the registry directly if an API or PowerShell command exists (`Set-ItemProperty`).
- **Service Accounts**: Always run automation services under a "Managed Service Account" (MSA) to avoid password rotation headaches.
- **Log Forwarding**: In production, use "Windows Event Forwarding" (WEF) to send logs to a central Linux-based SIEM or ELK stack.

---
**Next Step**: [PowerShell Automation Fundamentals →](./PowerShell-Automation-Ref.md)
