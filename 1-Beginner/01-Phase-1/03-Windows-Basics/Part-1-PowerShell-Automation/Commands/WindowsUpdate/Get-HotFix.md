# Get-HotFix

## Purpose
Gets the hotfixes (installed updates) that have been applied to the local or remote computer (primarily tracks CBS maintenance updates).

## Examples

### List all installed hotfixes
```powershell
Get-HotFix
```

### Find a specific update by KB ID
```powershell
Get-HotFix -Id "KB5000802"
```

### Search for updates installed after a specific date
```powershell
Get-HotFix | Where-Object InstalledOn -GT (Get-Date).AddMonths(-1)
```
