# Remove-PSSession

## Purpose
Closes and deletes one or more PowerShell sessions (PSSessions), freeing up resources.

## Examples

### Close a specific session stored in a variable
```powershell
Remove-PSSession -Session $Session
```

### Close all active sessions
```powershell
Get-PSSession | Remove-PSSession
```

### Close a session by its ID
```powershell
Remove-PSSession -Id 3
```
