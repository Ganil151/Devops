# Get-ScheduledTaskInfo

## Purpose
Retrieves runtime information (state, last run time, next run time, last result) for a scheduled task.

## Examples

### Get detailed runtime info for a specific task
```powershell
Get-ScheduledTaskInfo -TaskName "Windows Defender Scheduled Scan"
```

### Find tasks that have failed recently (LastTaskResult is not 0)
```powershell
Get-ScheduledTask | Get-ScheduledTaskInfo | Where-Object { $_.LastTaskResult -ne 0 }
```
