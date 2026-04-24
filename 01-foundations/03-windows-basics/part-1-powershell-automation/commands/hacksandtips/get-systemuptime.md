# Get-SystemUptime

> Calculates the exact system uptime using structured DateTime logic.

```powershell
try {
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
    $Uptime = (Get-Date) - $OS.LastBootUpTime
    [PSCustomObject]@{
        BootTime = $OS.LastBootUpTime
        Days     = $Uptime.Days
        Hours    = $Uptime.Hours
        Minutes  = $Uptime.Minutes
    }
}
catch {
    Write-Error "Failed to retrieve uptime info."
}
```

## Permissions
*   **Required:** Standard User

## Rollback
N/A (Read-only operation)
