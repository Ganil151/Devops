# Set-LocalUser

## Purpose
Modifies the settings of an existing local user account.

## Examples

### Reset a user's password
```powershell
$NewPassword = Read-Host -AsSecureString
Set-LocalUser -Name "DevOpsAdmin" -Password $NewPassword
```

### Update the description of a user account
```powershell
Set-LocalUser -Name "DevOpsAdmin" -Description "Updated description for audit purposes"
```
