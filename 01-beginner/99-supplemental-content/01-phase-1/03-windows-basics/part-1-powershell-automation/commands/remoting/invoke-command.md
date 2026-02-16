# Invoke-Command

## Purpose
Runs commands on local or remote computers, capable of executing generic scripts or script blocks in parallel.

## Examples

### Run a script block on a remote computer
```powershell
Invoke-Command -ComputerName "Server01" -ScriptBlock { Get-Service Spooler }
```

### Run a local script file on multiple remote computers
```powershell
Invoke-Command -ComputerName "Server01", "Server02" -FilePath "C:\Scripts\Get-SystemInfo.ps1"
```

### Pass local variables to a remote command
```powershell
$ProcessName = "notepad"
Invoke-Command -ComputerName "Server01" -ScriptBlock { param($Name) Get-Process -Name $Name } -ArgumentList $ProcessName
```
