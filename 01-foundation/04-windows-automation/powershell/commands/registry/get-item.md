# Get-Item

## Purpose
Gets the registry key object itself (not its values/properties) at the specified path.

## Examples

### Check if a registry key exists
```powershell
Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
```

### Get the subkeys of a registry key
```powershell
Get-Item -Path "HKLM:\SOFTWARE" | Select-Object -ExpandProperty Property
```
