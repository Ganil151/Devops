# Get-Process

## Purpose
Gets the processes that are running on a local or remote computer.

## Examples

### List all running processes
```powershell
Get-Process
```

### Get a process by its name
```powershell
Get-Process -Name "notepad"
```

### Get processes consuming the most CPU
```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
```
