# Trace-BlockedTraffic

> Queries the Windows Security Event Log to identify the last 20 outbound connections blocked by the Windows Filtering Platform (WFP).

```powershell
# Event ID 5157: The Windows Filtering Platform has blocked a connection.
# Note: Auditing for 'Filtering Platform Connection' must be enabled via auditpol for these events to appear.

try {
    Write-Host "Scanning Security Log for blocked connections..." -ForegroundColor Yellow
    
    $Filter = @{
        LogName = 'Security'
        Id      = 5157 
    }
    
    $Events = Get-WinEvent -FilterHashtable $Filter -MaxEvents 20 -ErrorAction Stop
    
    $Events | ForEach-Object {
        # Check definitions of Event 5157 XML structure for correct indexes
        # Properties: [0]ProcessID, [1]AppPath, [2]Direction, [3]SourceAddr, [4]SourcePort, [5]DestAddr, [6]DestPort...
        [PSCustomObject]@{
            Time        = $_.TimeCreated
            Application = $_.Properties[1].Value
            DestIP      = $_.Properties[5].Value
            DestPort    = $_.Properties[6].Value
            Protocol    = $_.Properties[7].Value
        }
    } | Format-Table -AutoSize
}
catch {
    Write-Warning "No recent blocked blocking events found (or auditing is disabled)."
    Write-Host "To enable auditing: auditpol /set /subcategory:`"Filtering Platform Connection`" /failure:enable"
}
```

## Permissions
*   **Required:** Administrator Privileges

## Rollback
N/A (Read-only operation)
