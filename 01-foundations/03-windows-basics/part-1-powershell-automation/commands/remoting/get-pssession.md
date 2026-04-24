# Get-PSSession

## Purpose
Gets the persistent PowerShell sessions (PSSessions) that have been created in the current session.

## Examples

### List all open sessions
```powershell
Get-PSSession
```

### Get sessions connected to a specific computer
```powershell
Get-PSSession -ComputerName "Server01"
```
