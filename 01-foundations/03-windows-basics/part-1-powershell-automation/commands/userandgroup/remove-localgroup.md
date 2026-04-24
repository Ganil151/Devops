# Remove-LocalGroup

## Purpose
Deletes a local security group.

## Examples

### Remove a specific group
```powershell
Remove-LocalGroup -Name "DockerAccess"
```

### Remove a group without confirmation
```powershell
Remove-LocalGroup -Name "TempAdmins" -Confirm:$false
```
