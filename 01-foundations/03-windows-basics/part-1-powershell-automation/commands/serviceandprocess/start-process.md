# Start-Process

## Purpose
Starts one or more processes on the local computer.

## Examples

### Start Notepad and open a specific file
```powershell
Start-Process -FilePath "notepad.exe" -ArgumentList "C:\Logs\Error.txt"
```

### Start a process as an Administrator
```powershell
Start-Process -FilePath "powershell.exe" -Verb RunAs
```

### Start an installer and wait for it to complete
```powershell
Start-Process -FilePath "setup.exe" -Wait
```
