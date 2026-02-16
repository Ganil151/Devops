# Restart-Service

## Purpose
Stops and then starts one or more services.

## Examples

### Restart a service to apply configuration changes
```powershell
Restart-Service -Name "wuauserv"
```

### Restart a service and wait for it to complete
```powershell
Restart-Service -Name "Spooler" -Force
```
