# PowerShell for System Administration

Complete guide to PowerShell scripting and system administration on Windows.

## PowerShell Fundamentals

### Basic Commands
```powershell
# System Information
Get-ComputerInfo
Get-WmiObject -Class Win32_OperatingSystem
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# File Operations
Get-ChildItem -Path C:\ -Recurse -Filter "*.log"
Copy-Item -Path "source.txt" -Destination "destination.txt"
Remove-Item -Path "file.txt" -Force

# Service Management
Get-Service | Where-Object {$_.Status -eq "Running"}
Start-Service -Name "Spooler"
Stop-Service -Name "Spooler"
Set-Service -Name "Spooler" -StartupType Automatic
```

### Variables and Data Types
```powershell
# Variables
$computerName = $env:COMPUTERNAME
$services = Get-Service
$date = Get-Date

# Arrays
$servers = @("Server1", "Server2", "Server3")
$processes = Get-Process

# Hash Tables
$userInfo = @{
    Name = "John Doe"
    Department = "IT"
    Email = "john.doe@company.com"
}

# Custom Objects
$server = [PSCustomObject]@{
    Name = "WebServer01"
    IP = "192.168.1.100"
    OS = "Windows Server 2022"
    Status = "Online"
}
```

## System Administration Tasks

### User Management
```powershell
# Local Users
New-LocalUser -Name "devops" -Password (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) -Description "DevOps User"
Set-LocalUser -Name "devops" -PasswordNeverExpires $true
Add-LocalGroupMember -Group "Administrators" -Member "devops"
Remove-LocalUser -Name "devops"

# Active Directory Users (requires AD module)
Import-Module ActiveDirectory
New-ADUser -Name "Jane Smith" -SamAccountName "jsmith" -UserPrincipalName "jsmith@company.com" -Path "OU=Users,DC=company,DC=com"
Set-ADUser -Identity "jsmith" -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "jsmith"
```

### Registry Management
```powershell
# Read registry values
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
Get-ChildItem -Path "HKCU:\Software"

# Set registry values
Set-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Version" -Value "1.0.0"
New-Item -Path "HKLM:\SOFTWARE\MyApp" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "InstallDate" -Value (Get-Date) -PropertyType String

# Remove registry items
Remove-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Version"
Remove-Item -Path "HKLM:\SOFTWARE\MyApp" -Recurse
```

### Event Log Management
```powershell
# Read event logs
Get-EventLog -LogName System -Newest 10
Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2; StartTime=(Get-Date).AddDays(-1)}

# Write to event log
Write-EventLog -LogName Application -Source "MyApp" -EventId 1001 -EntryType Information -Message "Application started successfully"

# Create custom event log
New-EventLog -LogName "MyAppLog" -Source "MyApp"
```

## Advanced PowerShell Scripting

### Functions and Modules
```powershell
# Function definition
function Get-SystemInfo {
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )
    
    $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName
    $cpu = Get-WmiObject -Class Win32_Processor -ComputerName $ComputerName
    $memory = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $ComputerName
    
    [PSCustomObject]@{
        ComputerName = $ComputerName
        OS = $os.Caption
        Version = $os.Version
        CPU = $cpu.Name
        TotalMemoryGB = [math]::Round(($memory | Measure-Object Capacity -Sum).Sum / 1GB, 2)
        LastBootTime = $os.ConvertToDateTime($os.LastBootUpTime)
    }
}

# Module creation
# Save as SystemInfo.psm1
Export-ModuleMember -Function Get-SystemInfo
```

### Error Handling
```powershell
# Try-Catch-Finally
try {
    $service = Get-Service -Name "NonExistentService" -ErrorAction Stop
    Write-Host "Service found: $($service.Name)"
}
catch {
    Write-Error "Service not found: $($_.Exception.Message)"
    Write-EventLog -LogName Application -Source "MyScript" -EventId 2001 -EntryType Error -Message $_.Exception.Message
}
finally {
    Write-Host "Cleanup operations completed"
}

# Error handling with validation
function Test-ServiceExists {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )
    
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        return $true
    } else {
        return $false
    }
}
```

## Automation Scripts

### System Monitoring Script
```powershell
# System Health Check Script
param(
    [string]$LogPath = "C:\Logs\HealthCheck.log",
    [int]$CPUThreshold = 80,
    [int]$MemoryThreshold = 85,
    [int]$DiskThreshold = 90
)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogPath -Append
}

# CPU Check
$cpuUsage = (Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
if ($cpuUsage -gt $CPUThreshold) {
    Write-Log "WARNING: CPU usage is $([math]::Round($cpuUsage, 2))%"
}

# Memory Check
$memory = Get-WmiObject -Class Win32_OperatingSystem
$memoryUsage = [math]::Round((($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize) * 100, 2)
if ($memoryUsage -gt $MemoryThreshold) {
    Write-Log "WARNING: Memory usage is $memoryUsage%"
}

# Disk Check
Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
    $diskUsage = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 2)
    if ($diskUsage -gt $DiskThreshold) {
        Write-Log "WARNING: Disk $($_.DeviceID) usage is $diskUsage%"
    }
}

Write-Log "Health check completed"
```

### Automated Backup Script
```powershell
# Backup Script
param(
    [string]$SourcePath = "C:\Data",
    [string]$BackupPath = "D:\Backups",
    [int]$RetentionDays = 30
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFolder = Join-Path $BackupPath "Backup_$timestamp"

try {
    # Create backup directory
    New-Item -Path $backupFolder -ItemType Directory -Force
    
    # Copy files
    Copy-Item -Path $SourcePath -Destination $backupFolder -Recurse -Force
    
    # Compress backup
    $zipPath = "$backupFolder.zip"
    Compress-Archive -Path $backupFolder -DestinationPath $zipPath
    Remove-Item -Path $backupFolder -Recurse -Force
    
    # Clean old backups
    Get-ChildItem -Path $BackupPath -Filter "Backup_*.zip" | 
        Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-$RetentionDays)} | 
        Remove-Item -Force
    
    Write-Host "Backup completed successfully: $zipPath"
}
catch {
    Write-Error "Backup failed: $($_.Exception.Message)"
}
```

## Remote Management

### PowerShell Remoting
```powershell
# Enable PowerShell Remoting
Enable-PSRemoting -Force
Set-WSManQuickConfig

# Remote session
$session = New-PSSession -ComputerName "Server01" -Credential (Get-Credential)
Invoke-Command -Session $session -ScriptBlock {Get-Service}
Enter-PSSession -Session $session
Exit-PSSession
Remove-PSSession -Session $session

# Remote execution
Invoke-Command -ComputerName "Server01", "Server02" -ScriptBlock {
    Get-Service | Where-Object {$_.Status -eq "Stopped"}
} -Credential (Get-Credential)
```

### WMI and CIM
```powershell
# WMI queries
Get-WmiObject -Class Win32_Service -ComputerName "Server01"
Get-WmiObject -Query "SELECT * FROM Win32_Process WHERE Name='notepad.exe'"

# CIM (preferred over WMI)
Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName "Server01"
Get-CimInstance -Query "SELECT * FROM Win32_LogicalDisk WHERE DriveType=3"

# Remote CIM session
$cimSession = New-CimSession -ComputerName "Server01"
Get-CimInstance -CimSession $cimSession -ClassName Win32_Service
Remove-CimSession -CimSession $cimSession
```