# Reset-DnsCache

> Clears the client DNS cache to resolve stale or incorrect name resolution issues.

```powershell
Write-Host "Clearing DNS Cache..." -ForegroundColor Cyan
try {
    Clear-DnsClientCache -ErrorAction Stop
    Write-Host "DNS Cache successfully flushed." -ForegroundColor Green
}
catch {
    Write-Error "Failed to flush DNS cache: $_"
}
```

## Permissions
*   **Required:** Administrator (Elevated)

## Rollback
There is no direct rollback for flushing a cache, but it repopulates automatically.
```powershell
# No action needed; cache rebuilds on usage.
```
