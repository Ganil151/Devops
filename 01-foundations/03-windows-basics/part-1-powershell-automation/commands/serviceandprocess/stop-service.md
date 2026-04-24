# Stop-Service

## Purpose
Stops one or more running services.

## Examples

### Stop a specific service
```powershell
Stop-Service -Name "Spooler"
```

### Stop a service and force dependent services to stop
```powershell
Stop-Service -Name "TermService" -Force
```
