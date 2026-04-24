# Remove-LocalUser

## Purpose
Deletes a local user account.

## Examples

### Remove a specific user
```powershell
Remove-LocalUser -Name "OldUserAccount"
```

### Remove a user without confirmation prompt
```powershell
Remove-LocalUser -Name "TempUser" -Confirm:$false
```
