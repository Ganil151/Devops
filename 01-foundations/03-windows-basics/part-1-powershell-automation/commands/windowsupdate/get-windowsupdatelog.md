# Get-WindowsUpdateLog

## Purpose
Merges and converts Windows Update trace files (.etl) into a single readable text log file on the desktop.

## Examples

### Generate the Windows Update log
```powershell
Get-WindowsUpdateLog
```

### Generate the log and save it to a specific path
```powershell
Get-WindowsUpdateLog -LogPath "C:\Logs\WindowsUpdate.log"
```
