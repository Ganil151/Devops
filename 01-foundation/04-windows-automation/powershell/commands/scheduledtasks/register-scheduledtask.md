# Register-ScheduledTask

## Purpose
Registers (creates) a new scheduled task or updates an existing task definition.

## Examples

### Create a simple task that opens Notepad at 9am daily
```powershell
$action = New-ScheduledTaskAction -Execute "Notepad.exe"
$trigger = New-ScheduledTaskTrigger -Daily -At 9am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DailyNotepad"
```

### Register a task running as the SYSTEM account
```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\Maintenance.ps1"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "SystemMaintenance" -User "SYSTEM"
```
