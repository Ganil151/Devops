# New-Service

## Purpose
Creates a new entry for a Windows service in the registry and the Service Control Manager.

## Examples

### Create a new service with a binary path
```powershell
New-Service -Name "TestService" -BinaryPathName "C:\Windows\System32\svchost.exe -k netsvcs"
```

### Create a service with a specific display name and startup type
```powershell
New-Service -Name "MyDevService" -BinaryPathName "C:\MyApps\Service.exe" -DisplayName "My Development Service" -StartupType Manual
```
