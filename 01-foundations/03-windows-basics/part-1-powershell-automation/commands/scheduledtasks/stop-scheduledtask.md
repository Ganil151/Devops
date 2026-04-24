# Stop-ScheduledTask

## Purpose
Stops a currently running instance of a scheduled task.

## Examples

### Stop a specific task by name
```powershell
Stop-ScheduledTask -TaskName "LongRunningBackup"
```

### Stop a task retrieved via pipeline
```powershell
Get-ScheduledTask -TaskName "DailyUsageReport" | Stop-ScheduledTask
```
