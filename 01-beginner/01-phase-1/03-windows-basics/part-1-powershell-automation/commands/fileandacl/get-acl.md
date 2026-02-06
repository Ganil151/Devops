# Get-Acl

## Purpose
Gets the security descriptor (access control list) for a resource, such as a file, folder, or registry key.

## Examples

### Get the ACL for a specific folder
```powershell
Get-Acl -Path "C:\Windows"
```

### Audit permissions for a specific user on a file
```powershell
(Get-Acl -Path "C:\Data\Report.docx").Access | Where-Object IdentityReference -like "*UserA*"
```

### Get the ACL of a registry key
```powershell
Get-Acl -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
```
