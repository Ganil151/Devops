# Get-Service

## Purpose
Gets the status of services on a local or remote computer.

## Examples

### List all services on the computer
```powershell
Get-Service
```

### Find services starting with a specific name
```powershell
Get-Service -Name "wuauserv", "bits"
```

### Get all running services with dependent services
```powershell
Get-Service | Where-Object Status -eq 'Running' | Where-Object {$_.DependentServices}
```
