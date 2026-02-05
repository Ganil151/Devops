# Unregister-ScheduledTask

## Purpose
Unregisters (deletes) a scheduled task from the Task Scheduler.

## Examples

### Delete a specific task
```powershell
Unregister-ScheduledTask -TaskName "DailyNotepad"
```

### Delete a task without asking for confirmation
```powershell
Unregister-ScheduledTask -TaskName "SystemMaintenance" -Confirm:$false
```
