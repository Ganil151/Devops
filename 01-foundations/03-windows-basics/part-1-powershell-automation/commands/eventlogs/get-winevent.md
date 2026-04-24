# Get-WinEvent

## Purpose
Gets events from event logs and event tracing log files on local and remote computers, supporting advanced filtering via XPath and hash tables.

## Examples

### Get the last 10 Error events from the System log
```powershell
Get-WinEvent -LogName System -MaxEvents 10 | Where-Object LevelDisplayName -eq "Error"
```

### Filter the Security log for logon successes (4624) and failures (4625)
```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4624, 4625
}
```

### Get Application events that occurred in the last 24 hours
```powershell
$StartTime = (Get-Date).AddHours(-24)
Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    StartTime = $StartTime
}
```
