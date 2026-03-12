# Remove-Service

## Purpose
Removes a Windows service from the registry and Service Control Manager.

## Examples

### Remove a specific service by name
```powershell
Remove-Service -Name "TestService"
```

### Remove a service without confirmation
```powershell
Remove-Service -Name "MyOldApp" -Confirm:$false
```
