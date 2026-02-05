# Get-LocalGroupMember

## Purpose
Gets the members of a local security group.

## Examples

### List members of the Administrators group
```powershell
Get-LocalGroupMember -Group "Administrators"
```

### List members of a custom group
```powershell
Get-LocalGroupMember -Group "DockerAccess"
```
