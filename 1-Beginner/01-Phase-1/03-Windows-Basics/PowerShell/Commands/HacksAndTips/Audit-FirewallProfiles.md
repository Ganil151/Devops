# Audit-FirewallProfiles

> Retrieves the current status (Up/Down) and blockage settings for all firewall profiles (Domain, Private, Public).

```powershell
try {
    Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction | Format-Table -AutoSize
}
catch {
    Write-Error "Detailed firewall audit failed. Ensure you have permissions."
}
```

## Permissions
*   **Required:** Standard User (Read-Only), Administrator (For deep diagnostics)

## Rollback
N/A (Read-only operation)
