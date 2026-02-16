# Audit-FirewallRules

> Exports a snapshot of all currently ENABLED firewall rules to a CSV file. Use this for security auditing or before making bulk changes.

```powershell
$ReportPath = "$env:USERPROFILE\Desktop\FirewallAudit.csv"

try {
    Write-Host "Auditing Active Firewall Rules..." -ForegroundColor Cyan
    
    $Rules = Get-NetFirewallRule -Enabled True -ErrorAction Stop
    
    $Report = foreach ($r in $Rules) {
        Write-Progress -Activity "Processing Rules" -Status $r.DisplayName
        $PortFilter = $r | Get-NetFirewallPortFilter
        $AppFilter = $r | Get-NetFirewallApplicationFilter
        
        [PSCustomObject]@{
            Name        = $r.DisplayName
            Direction   = $r.Direction
            Action      = $r.Action
            Profile     = $r.Profile
            Protocol    = $PortFilter.Protocol
            LocalPort   = $PortFilter.LocalPort
            RemotePort  = $PortFilter.RemotePort
            Program     = $AppFilter.Program
        }
    }
    
    $Report | Export-Csv -Path $ReportPath -NoTypeInformation
    Write-Host "Audit Complete. Report saved to: $ReportPath" -ForegroundColor Green
}
catch {
    Write-Error "Audit failed: $_"
}
```

## Permissions
*   **Required:** Administrator Privileges

## Rollback
```powershell
# To delete the generated report:
Remove-Item "$env:USERPROFILE\Desktop\FirewallAudit.csv" -ErrorAction SilentlyContinue
```
