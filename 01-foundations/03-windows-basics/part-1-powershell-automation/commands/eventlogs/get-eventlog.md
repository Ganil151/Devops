# Get-EventLog

## Purpose
Gets events from the classic event logs (System, Application, Security) on local or remote computers.

> **Note**: This cmdlet is legacy and does not support the newer "Applications and Services Logs". Use `Get-WinEvent` for modern logging requirements.

## Examples

### Get the latest 50 events from the System log
```powershell
Get-EventLog -LogName System -Newest 50
```

### List all Error events from the Application log
```powershell
Get-EventLog -LogName Application -EntryType Error
```

### View the configuration of all classic event logs
```powershell
Get-EventLog -List
```
