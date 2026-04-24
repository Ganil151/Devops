# New-LocalUser

## Purpose
Creates a new local user account.

## Examples

### Create a new user with a secure password
```powershell
$Password = Read-Host -AsSecureString
New-LocalUser -Name "DevOpsAdmin" -Password $Password -FullName "DevOps Administrator" -Description "Local admin account for DevOps tasks"
```

### Create a user account with no password
```powershell
New-LocalUser -Name "BuildAgent" -NoPassword
```
