# Disable-ScheduledTask

## Purpose
Disables a scheduled task, preventing it from running automatically or manually.

## Examples

### Disable a task to perform maintenance
```powershell
Disable-ScheduledTask -TaskName "NightlyReboot"
```

### Disable all tasks in a specific folder path
```powershell
Get-ScheduledTask -TaskPath "\TempScripts\" | Disable-ScheduledTask
```
