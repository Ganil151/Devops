# Set-Service

## Purpose
Changes the properties of a local or remote service, such as its startup type or description.

## Examples

### Change a service startup type to Automatic
```powershell
Set-Service -Name "LanmanWorkstation" -StartupType Automatic
```

### Update the description of a service
```powershell
Set-Service -Name "MyService" -Description "This text was updated via PowerShell."
```
