# Enable-ScheduledTask

## Purpose
Enables a previously disabled scheduled task, allowing it to run again.

## Examples

### Enable a specific task
```powershell
Enable-ScheduledTask -TaskName "NightlyReboot"
```

### Enable multiple tasks using the pipeline
```powershell
Get-ScheduledTask -TaskName "Startup*" | Enable-ScheduledTask
```
