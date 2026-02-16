# Get-NetRoute

## Purpose
Retrieves the routing table entries for the local computer.

## Examples

### View the full routing table
```powershell
Get-NetRoute
```

### Find the route used to reach a specific destination
```powershell
Get-NetRoute -DestinationPrefix "8.8.8.8/32"
```
