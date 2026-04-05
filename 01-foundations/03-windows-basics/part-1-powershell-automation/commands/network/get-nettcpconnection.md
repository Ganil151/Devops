# Get-NetTCPConnection

## Purpose
Gets current TCP connections and listener ports on the computer, similar to `netstat`.

## Examples

### List all established TCP connections
```powershell
Get-NetTCPConnection -State Established
```

### Find which process is listening on a local port
```powershell
Get-NetTCPConnection -LocalPort 443
```
