# Set-ScheduledTask

## Purpose
Modifies the properties or settings of an existing registered scheduled task.

## Examples

### Update the user account for an existing task
```powershell
Set-ScheduledTask -TaskName "DailyNotepad" -User "Administrator" -Password "SecurePass123"
```

### Change the trigger for a task
```powershell
$newTrigger = New-ScheduledTaskTrigger -Weekly -At 3am
Set-ScheduledTask -TaskName "SystemMaintenance" -Trigger $newTrigger
```
