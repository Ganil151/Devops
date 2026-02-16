# Start-Service

## Purpose
Starts one or more stopped services.

## Examples

### Start a specific service by name
```powershell
Start-Service -Name "Spooler"
```

### Start a service and pass start arguments
```powershell
Start-Service -Name "MyCustomService" -ArgumentList "SafeMode"
```
