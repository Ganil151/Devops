# Verify-PortStatus

> Audits all local ports currently in a 'Listen' state and attempts to correlate them with the owning process.

```powershell
try {
    Write-Host "Scanning Listening Ports..." -ForegroundColor Cyan
    $Listeners = Get-NetTCPConnection -State Listen -ErrorAction Stop
    
    $Results = foreach ($L in $Listeners) {
        $ProcessName = (Get-Process -Id $L.OwningProcess -ErrorAction SilentlyContinue).ProcessName
        if (-not $ProcessName) { $ProcessName = "System/Unknown" }
        
        [PSCustomObject]@{
            LocalPort     = $L.LocalPort
            LocalAddress  = $L.LocalAddress
            OwningPID     = $L.OwningProcess
            Process       = $ProcessName
        }
    }
    
    $Results | Sort-Object LocalPort | Format-Table -AutoSize
}
catch {
    Write-Error "Failed to scan ports: $_"
}
```

## Permissions
*   **Required:** Administrator Privileges (to resolve Process IDs to Names)

## Rollback
N/A (Read-only operation)
