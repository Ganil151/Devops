# Get-ItemProperty

## Purpose
Gets the properties (values) of a specified registry key.

## Examples

### Get all values in a specific registry key
```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
```

### Get a specific value (e.g., ProgramFilesDir)
```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir"
```
