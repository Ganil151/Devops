# New-LocalGroup

## Purpose
Creates a new local security group.

## Examples

### Create a new group for Docker users
```powershell
New-LocalGroup -Name "DockerAccess" -Description "Members of this group can manage Docker containers"
```

### Create a group without a description
```powershell
New-LocalGroup -Name "TempAdmins"
```
