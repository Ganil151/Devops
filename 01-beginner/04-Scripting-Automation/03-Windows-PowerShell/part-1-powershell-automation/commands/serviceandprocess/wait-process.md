# Wait-Process

## Purpose
Waits for the processes to be stopped before accepting more input.

## Examples

### Wait for a specific process ID to stop
```powershell
Wait-Process -Id 2048
```

### Start an app and wait for it to close before continuing script
```powershell
$proc = Start-Process notepad -PassThru
Wait-Process -Id $proc.Id
```

### Wait for a process with a timeout (in seconds)
```powershell
Wait-Process -Name "BackupJob" -Timeout 60
```
