# Get-ScheduledTask

## Purpose
Retrieves a list of scheduled tasks registered on the local or remote computer.

## Examples

### List all scheduled tasks
```powershell
Get-ScheduledTask
```

### Get a specific task by name
```powershell
Get-ScheduledTask -TaskName "Windows Defender Scheduled Scan"
```

### List tasks located in a specific folder path
```powershell
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\"
```
