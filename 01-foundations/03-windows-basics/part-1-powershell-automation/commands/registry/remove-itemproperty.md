# Remove-ItemProperty

## Purpose
Deletes a specific value (property) from a registry key.

## Examples

### Remove a specific registry value
```powershell
Remove-ItemProperty -Path "HKCU:\Software\MyApplication" -Name "LastRunTime"
```

### Remove multiple values at once
```powershell
Remove-ItemProperty -Path "HKCU:\Software\MyApplication" -Name "Setting1", "Setting2"
```
