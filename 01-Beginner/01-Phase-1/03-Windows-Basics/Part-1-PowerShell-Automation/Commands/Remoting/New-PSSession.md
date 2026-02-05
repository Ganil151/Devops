# New-PSSession

## Purpose
Creates a persistent connection (session) to a local or remote computer that can be reused for multiple commands.

## Examples

### Create a persistent session to a remote server
```powershell
$Session = New-PSSession -ComputerName "Server01"
```

### Create a session with alternate credentials
```powershell
$Session = New-PSSession -ComputerName "Server01" -Credential "Domain\User"
```

### Use the session in a command
```powershell
Invoke-Command -Session $Session -ScriptBlock { Get-Culture }
```
