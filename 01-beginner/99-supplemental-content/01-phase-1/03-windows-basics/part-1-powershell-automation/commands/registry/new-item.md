# New-Item

## Purpose
Creates a new registry key at the specified path.

## Examples

### Create a new key under Software
```powershell
New-Item -Path "HKCU:\Software\MyApplication"
```

### Create a nested key structure and force creation if parents don't exist
```powershell
New-Item -Path "HKCU:\Software\MyCompany\MyApp\Settings" -Force
```
