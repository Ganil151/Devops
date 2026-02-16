# Start-ScheduledTask

## Purpose
Immediately starts a registered scheduled task via the Task Scheduler engine.

## Examples

### Start a specific task
```powershell
Start-ScheduledTask -TaskName "Windows Defender Scheduled Scan"
```

### Start all tasks in a specific folder
```powershell
Get-ScheduledTask -TaskPath "\MyCompany\Maintenance\" | Start-ScheduledTask
```
