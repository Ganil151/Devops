# Remove-LocalGroupMember

## Purpose
Removes a member (user or group) from a local security group.

## Examples

### Remove a user from the Administrators group
```powershell
Remove-LocalGroupMember -Group "Administrators" -Member "Guest"
```

### Remove a user from a specific group
```powershell
Remove-LocalGroupMember -Group "Remote Desktop Users" -Member "FormerEmployee"
```
