# Remove-Item

## Purpose
Deletes a registry key and all of its subkeys and values.

## Examples

### Delete a specific registry key
```powershell
Remove-Item -Path "HKCU:\Software\MyApplication"
```

### Recursively delete a key without asking for confirmation
```powershell
Remove-Item -Path "HKCU:\Software\MyCompany" -Recurse -Force
```
