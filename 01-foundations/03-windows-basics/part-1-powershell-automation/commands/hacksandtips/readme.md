# PowerShell Hacks & Tips using Native Modules

This directory contains professional-grade snippet files for common DevOps and SysAdmin tasks on Windows 11. All scripts are designed to be idempotent and safe to run on clean installs.

```mermaid
graph TD
    Root[Hacks & Tips] --> Diagnostic
    Root --> Configuration
    Root --> Security

    Diagnostic --> D1[Reset-DnsCache]
    Diagnostic --> D2[Reset-NetworkStack]
    Diagnostic --> D3[Test-TcpPort]
    Diagnostic --> D4[Resolve-MultiDns]
    Diagnostic --> D5[Get-SystemUptime]

    Configuration --> C1[Add-HostsEntry]
    Configuration --> C2[Toggle-FirewallProfile]

    Security --> S1[Audit-FirewallProfiles]
    Security --> S2[Get-ProcessConnections]
    Security --> S3[Get-WiFiPasswords]
```

## Usage
*   Open the specific `.md` file.
*   Copy the code block within.
*   Run in your PowerShell terminal (pay attention to "Permissions").

## Standards
*   **No Registry Hacks**: All settings use `Set-` or `New-` cmdlets.
*   **Native Only**: No reliance on Chocolatey, Scoop, or PSGallery modules.
*   **Idempotency**: Configuration scripts check state before exploring.
