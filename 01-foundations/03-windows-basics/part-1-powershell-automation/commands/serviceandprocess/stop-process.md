# Stop-Process

## Purpose
Stops one or more running processes.

## Examples

### Stop a specific process by name
```powershell
Stop-Process -Name "notepad"
```

### Stop a process by its ID (PID)
```powershell
Stop-Process -Id 1234
```

### Forcefully terminate a hung process
```powershell
Stop-Process -Name "LegacyApp" -Force
```
