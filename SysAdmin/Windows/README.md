# Windows System Administration

Complete guide to Windows system administration for DevOps environments.

## Windows Server Management

### Server Roles and Features
```powershell
# Install IIS Web Server
Install-WindowsFeature -Name IIS-WebServerRole -IncludeManagementTools

# Install Active Directory Domain Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Install DNS Server
Install-WindowsFeature -Name DNS -IncludeManagementTools

# Install Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

### PowerShell Administration
```powershell
# System Information
Get-ComputerInfo
Get-WmiObject -Class Win32_OperatingSystem
Get-Service | Where-Object {$_.Status -eq "Running"}

# User Management
New-LocalUser -Name "devops" -Password (ConvertTo-SecureString "Password123!" -AsPlainText -Force)
Add-LocalGroupMember -Group "Administrators" -Member "devops"

# Service Management
Get-Service -Name "IIS"
Start-Service -Name "W3SVC"
Set-Service -Name "W3SVC" -StartupType Automatic
```

## Active Directory Management

### Domain Controller Setup
```powershell
# Install AD Forest
Install-ADDSForest -DomainName "company.local" -SafeModeAdministratorPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force)

# User Management
New-ADUser -Name "John Doe" -SamAccountName "jdoe" -UserPrincipalName "jdoe@company.local"
Add-ADGroupMember -Identity "Domain Admins" -Members "jdoe"

# Group Policy Management
New-GPO -Name "Security Policy"
Set-GPRegistryValue -Name "Security Policy" -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Type DWord -Value 1
```

## Windows Container Management

### Docker on Windows
```powershell
# Install Docker Desktop
winget install Docker.DockerDesktop

# Windows Container Commands
docker run -it mcr.microsoft.com/windows/servercore:ltsc2022 cmd
docker run -d -p 80:80 mcr.microsoft.com/windows/servercore/iis

# Container Management
docker ps
docker stop container_id
docker rm container_id
```

## Performance Monitoring

### System Performance
```powershell
# Performance Counters
Get-Counter "\Processor(_Total)\% Processor Time"
Get-Counter "\Memory\Available MBytes"
Get-Counter "\PhysicalDisk(_Total)\Disk Reads/sec"

# Event Log Monitoring
Get-EventLog -LogName System -Newest 10
Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2}
```

## Security Hardening

### Windows Security
```powershell
# Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Update-MpSignature
Start-MpScan -ScanType QuickScan

# Firewall Configuration
New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80
New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443
```