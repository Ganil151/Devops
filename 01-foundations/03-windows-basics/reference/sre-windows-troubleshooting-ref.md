# 🩺 Windows Troubleshooting: The SRE Playbook
*Version 1.0 | Systematic Resolution of Windows Performance & App Failures*

---

## 📖 Overview
Systematic troubleshooting on Windows requires moving beyond "Task Manager." SREs use PowerShell, Event Viewer, and command-line diagnostics to identify bottlenecks in CPU, memory, Disk I/O, and networking.

---

## 🛠️ The Windows SRE Toolset

### Event Viewer (`eventvwr.msc`)
**Definition**: The primary interface for reading OS and App logs.
**SRE Command**: `Get-EventLog -LogName System -Newest 10` or the modern `Get-WinEvent`.

### Resource Monitor (`resmon.exe`)
**Definition**: A detailed tool for monitoring real-time usage of CPU, Memory, Disk, and Network per-process.
**SRE Advantage**: Essential for Identifying "Disk Thrashing" or network latency.

### Performance Monitor (`perfmon.exe`)
**Definition**: A tool to capture long-term performance data via "Performance Counters."
**Usage**: Capturing IIS Request Queues or SQL Server memory pressure.

### `netstat` / `Get-NetTCPConnection`
**Definition**: Tools to view all active network connections and listening ports.
**Example**: `Get-NetTCPConnection -State Listen | Select-Object LocalPort` (Find all open ports).

---

## 🔍 Systematic Troubleshooting (Bottom-Up)

### 1. Resource Availability (Hardware/OS)
**Check**: Is the CPU pegged? Is RAM exhausted?
**Command**: `Get-CimInstance Win32_Processor | Select-Object LoadPercentage`.

### 2. Service Status (Control Plane)
**Check**: Is the application service running?
**Command**: `Get-Service -Name "MyService"`.

### 3. Identity & Permissions (Access Plane)
**Check**: Is the service account locked? Does it have NTFS permissions?
**Action**: Check `Security` event log or `Get-Acl "C:\App"`.

### 4. Network Connectivity (Transit Plane)
**Check**: Is the port open? Is Windows Firewall blocking it?
**Command**: `Test-NetConnection -ComputerName "db-server" -Port 1433`.

---

## 🚨 Common Incident Patterns

### "The server is slow"
**Analysis**: Check for High CPU or Low Memory.
**Command**: `Get-Process | Sort-Object CPU -Descending | Select-Object -First 5`.

### "Blue Screen of Death (BSOD)"
**Analysis**: Analyze Memory Dumps located in `C:\Windows\Minidump`.
**Tool**: `WinDbg` (Windows Debugger).

### "Service fails to start"
**Analysis**: Check the "System" event log for error code 1069 (Logon failure) or 1053 (Timeout).
**Action**: Verify service account credentials and `netsh` port reservations.

---

## 💡 Expert Recovery Commands
- **SFC (System File Checker)**: `sfc /scannow` (Repair corrupted Windows system files).
- **DISM (Deployment Image Servicing)**: `DISM /Online /Cleanup-Image /RestoreHealth` (Fixes deeper OS integrity issues).
- **Restart SCM**: `Restart-Service` automatically kills and restarts dependent services if configured properly.

---
**Next Step**: [Windows Best Practices →](./windows-best-practices-ref.md)
