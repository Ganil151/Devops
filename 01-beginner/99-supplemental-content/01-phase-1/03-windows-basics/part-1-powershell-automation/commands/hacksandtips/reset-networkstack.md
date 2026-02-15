# Reset-NetworkStack

> Performs a complete reset of the TCP/IP stack and Winsock catalog, often required to fix deep connectivity issues.

```powershell
Write-Host "Resetting Network Stack..." -ForegroundColor Yellow

try {
    # Reset IPv4 TCP/IP trace logs
    netsh int ip reset | Out-Null
    
    # Reset IPv6 TCP/IP trace logs
    netsh int ipv6 reset | Out-Null
    
    # Reset Winsock Catalog
    netsh winsock reset | Out-Null
    
    Write-Host "Network stack reset. A REBOOT IS REQUIRED." -ForegroundColor Red
}
catch {
    Write-Error "Failed to reset network components: $_"
}
```

## Permissions
*   **Required:** Administrator (Elevated)

## Rollback
Use System Restore or:
```powershell
# No direct command rollback. Requires manual re-configuration if static IPs were mapped.
# Ensure you documented IP settings (Get-NetIPAddress) before running.
```
