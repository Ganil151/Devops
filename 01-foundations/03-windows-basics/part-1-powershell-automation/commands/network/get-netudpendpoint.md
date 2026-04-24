# Get-NetUDPEndpoint

## Purpose
Gets current UDP endpoints (listeners) on the computer.

## Examples

### List all UDP endpoints
```powershell
Get-NetUDPEndpoint
```

### Find UDP listeners on a specific port
```powershell
Get-NetUDPEndpoint -LocalPort 53
```
