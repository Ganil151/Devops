# Enter-PSSession

## Purpose
Starts an interactive session with a single remote computer.

## Examples

### Connect to a remote server by name
```powershell
Enter-PSSession -ComputerName "Server01"
```

### Connect using specific credentials
```powershell
Enter-PSSession -ComputerName "Server01" -Credential (Get-Credential)
```

### Enter an existing persistent session
```powershell
$s = New-PSSession -ComputerName "Server01"
Enter-PSSession -Session $s
```
