# Add-LocalGroupMember

## Purpose
Adds a member (user or group) to a local security group.

## Examples

### Add a user to the Administrators group
```powershell
Add-LocalGroupMember -Group "Administrators" -Member "DevOpsAdmin"
```

### Add multiple users to a custom group
```powershell
Add-LocalGroupMember -Group "DockerAccess" -Member "UserA","UserB"
```
