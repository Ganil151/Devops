# Get-ProcessConnections

> Maps active TCP connections to the specific Process Names owning them, improving upon `netstat -ano`.

```powershell
try {
    Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess, `
    @{Name="ProcessName"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} | 
    Sort-Object ProcessName
}
catch {
    Write-Error "Failed to map processes. Run as Admin for full visibility."
}
```

## Permissions
*   **Required:** Administrator (for full visibility of system processes)

## Rollback
N/A (Read-only operation)
