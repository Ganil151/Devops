# 🐚 PowerShell Automation: The DevOps Logic Guide
*Version 1.0 | Object-Oriented Command Line Engineering*

---

## 📖 Overview
PowerShell is more than a shell; it is an automation engine and scripting language built on the .NET framework. Unlike Bash (which passes text), PowerShell passes **Objects**, making it exceptionally powerful for complex systems orchestration.

---

## 🏗️ Core PowerShell Concepts

### Cmdlets (Command-lets)
**Definition**: Specialized commands built into the shell. They follow a strict `Verb-Noun` syntax.
**Example**: `Get-Process`, `Stop-Service`, `New-Item`.

### The Pipeline (`|`)
**Definition**: The mechanism that allows the output of one cmdlet to be the input of another. In PowerShell, the pipeline passes **complete objects**, not just text strings.
**Example**: `Get-Service | Where-Object Status -eq "Stopped" | Start-Service`.

### Objects & Properties
**Definition**: An object is a data structure representing a system entity (a file, a process). **Properties** are charactersistics of that object.
**Example**: `(Get-Process -Name "chrome").Id` returns only the process identifier.

### Variables & Data Types
**Definition**: Storage for data, prefixed with `$`.
**Example**: `$count = 5` (Integer), `$server = "PROD-01"` (String).

---

## ⚙️ Advanced Logic & Scripting

### Modules
**Definition**: A package that contains PowerShell members (cmdlets, providers, functions).
**Example**: `Import-Module ActiveDirectory` or `Get-Module -ListAvailable`.

### Execution Policies
**Definition**: A safety feature that controls the conditions under which Windows loads configuration files and runs scripts.
**Standard**: `RemoteSigned` (Local scripts run, downloaded scripts must be signed).
**Override**: `Set-ExecutionPolicy Bypass -Scope Process` (Use for CI/CD runners).

### Error Action Preference
**Definition**: Determines how PowerShell responds to a non-terminating error.
**Example**: `$ErrorActionPreference = "Stop"` (Forces script to stop on any failure—ideal for CI/CD).

### Try/Catch Resilience
**Definition**: Logic blocks for handling exceptions.
**Example**:
```powershell
try {
    Invoke-WebRequest "http://bad-url" -ErrorAction Stop
} catch {
    Write-Warning "Website unreachable: $_"
}
```

---

## 💡 DevOps "Power Moves"
- **Filtering Left**: Filter as early in the pipeline as possible to save performance. `Get-Service -Name "w3svc"` is better than `Get-Service | Where Name -eq "w3svc"`.
- **PSRemoting (Enter-PSSession)**: The Windows equivalent of SSH. Use `Invoke-Command` to run logic across 100 servers simultaneously.
- **Splatting**: Passing a collection of parameter values to a command using a hashtable for readability.
  ```powershell
  $params = @{
      Path = "C:\Logs"
      Filter = "*.log"
      Recurse = $true
  }
  Get-ChildItem @params
  ```

---
**Next Step**: [Active Directory & Identity →](./active-directory-identity-ref.md)
