# Set-Acl

## Purpose
Changes the security descriptor (permissions) of a specified item, such as a file or registry key.

## Examples

### Copy the ACL from one file to another
```powershell
$SourceAcl = Get-Acl -Path "C:\Template\Permissions.txt"
Set-Acl -Path "C:\Production\Config.txt" -AclObject $SourceAcl
```

### Add a new "Full Control" permission for a user
```powershell
$Path = "C:\Data\Private"
$Acl = Get-Acl -Path $Path
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain\UserA", "FullControl", "Allow")
$Acl.SetAccessRule($Rule)
Set-Acl -Path $Path -AclObject $Acl
```

### Disable inheritance and convert inherited rules to explicit rules
```powershell
$Path = "C:\Data\Protected"
$Acl = Get-Acl -Path $Path
# First $True protects (disables inheritance), second $True preserves inherited rules
$Acl.SetAccessRuleProtection($True, $True)
Set-Acl -Path $Path -AclObject $Acl
```
