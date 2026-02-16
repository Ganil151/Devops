# Maintenance Automation

![Maintenance](https://img.shields.io/badge/Maintenance-Automated-28A745?style=for-the-badge&logo=windows&logoColor=white)
![Cross Platform](https://img.shields.io/badge/Platform-Server_+_Workstation-0078D4?style=for-the-badge)

## 🎯 Overview

This module provides automated cleanup of build artifacts, temporary files, and system caches that accumulate over time and degrade disk I/O performance on CI/CD nodes and development workstations.

## 🚨 The Problem

**Symptom**: Disk performance degrades over time, builds become slower, disk space runs low.

**Root Cause**: Accumulated debris from:
- NPM, Maven, Gradle, NuGet caches
- Windows Update downloads
- Temporary build artifacts
- Browser caches
- Docker build layers
- IIS logs (on servers)

**Impact**: 
- Slower disk I/O (increased queue lengths)
- Wasted disk space (10-50 GB typical)
- Longer build times
- Potential disk full errors

## ✅ The Solution

### [Invoke-ArtifactCleanup.ps1](./invoke-artifactcleanup.ps1)

**Purpose**: DevOps maintenance tool for automated artifact and cache cleanup.

**Cleanup Modes**:

| Mode | Targets | Use Case |
|------|---------|----------|
| **Basic** | Temp files, Prefetch | Quick cleanup, minimal risk |
| **Standard** | + Build caches, Windows Update | Regular maintenance (recommended) |
| **Aggressive** | + Docker cache, IIS logs, Event logs | Deep cleanup, maximum space recovery |

## 📊 Cleanup Targets by Mode

### Basic Mode
- `%TEMP%` (User temp files)
- `C:\Windows\Temp` (System temp files)
- `C:\Windows\Prefetch` (Prefetch data)

### Standard Mode (Basic +)
- `C:\Windows\SoftwareDistribution\Download` (Windows Update cache)
- `%LOCALAPPDATA%\npm-cache` (NPM cache)
- `%USERPROFILE%\.gradle\caches` (Gradle cache)
- `%USERPROFILE%\.m2\repository` (Maven repository)
- `%LOCALAPPDATA%\NuGet\Cache` (NuGet cache)

### Aggressive Mode (Standard +)
- Docker build cache (`docker system prune -af`)
- `C:\inetpub\logs` (IIS logs)
- Browser caches (Edge, Chrome)
- Windows Event Logs

## 🚀 Usage

### Standard Cleanup (Recommended)

```powershell
.\Invoke-ArtifactCleanup.ps1 -Mode Standard
```

Cleans build artifacts and caches with 7-day retention.

### Preview Mode (Dry Run)

```powershell
.\Invoke-ArtifactCleanup.ps1 -Mode Aggressive -DryRun
```

Preview cleanup without deleting files.

### Custom Retention Period

```powershell
.\Invoke-ArtifactCleanup.ps1 -Mode Standard -RetentionDays 30
```

Keep files newer than 30 days.

### Skip Docker Cache

```powershell
.\Invoke-ArtifactCleanup.ps1 -Mode Aggressive -SkipDockerCache
```

Preserve Docker build cache on active build nodes.

## 📈 Expected Results

**Typical Space Recovery**:

| Environment | Mode | Space Recovered |
|-------------|------|-----------------|
| **Developer Workstation** | Standard | 5-15 GB |
| **CI/CD Build Node** | Aggressive | 20-50 GB |
| **Long-Running Server** | Aggressive | 30-100 GB |

**Performance Improvement**:
- Disk queue length: Reduced by 30-50%
- Build times: 10-20% faster
- Disk I/O: Improved responsiveness

## 🔄 Automated Scheduling

### Weekly Maintenance (Recommended)

Create a scheduled task to run cleanup weekly:

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Invoke-ArtifactCleanup.ps1 -Mode Standard"

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2:00AM

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "DevOps Artifact Cleanup" `
    -Action $action -Trigger $trigger -Principal $principal `
    -Description "Weekly cleanup of build artifacts and caches"
```

### Jenkins Integration

Add to Jenkins pipeline:

```groovy
stage('Maintenance') {
    steps {
        powershell '''
            C:\\Scripts\\Invoke-ArtifactCleanup.ps1 -Mode Standard -Verbose
        '''
    }
}
```

## 🛡️ Safety Features

### Automatic Exclusions
- **Locked Files**: Automatically skipped (no errors)
- **Active Processes**: Files in use are preserved
- **System Files**: Protected by Windows

### Retention Policy
- Default: 7 days
- Configurable: 0-365 days
- Files newer than retention period are preserved

### Logging
- Detailed logs: `C:\ProgramData\DevOps_Logs\Maintenance\`
- Includes: File counts, space recovered, errors
- Timestamped for audit trail

## 📊 Monitoring Output

**Console Output Example**:

```
[🧹] ARTIFACT CLEANUP INITIATED
========================================
Mode:           Standard
Retention:      7 days
Preview Mode:   NO (files will be deleted)

[🗑️] CLEANING ARTIFACTS
========================================
[1/8] User Temp Files
  Files: 1,247 | Size: 2.34 GB | Errors: 0

[2/8] Windows Update Cache
  Files: 89 | Size: 5.67 GB | Errors: 0

[✅] CLEANUP COMPLETE
========================================
Files Processed:  3,456
Data Removed:     12.45 GB
Space Recovered:  12.50 GB
Duration:         23.45 seconds
```

## 🔧 Troubleshooting

### "Access Denied" Errors

**Solution**: Run PowerShell as Administrator

```powershell
# Check if running as admin
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

### Windows Update Service Won't Restart

**Solution**: Manually restart the service

```powershell
Start-Service -Name wuauserv
```

### Docker Cleanup Fails

**Solution**: Ensure Docker Desktop is running

```powershell
# Check Docker status
docker info
```

## 📖 Best Practices

1. **Start with Preview**: Use `-DryRun` first to see what will be deleted
2. **Regular Schedule**: Run weekly for optimal performance
3. **Monitor Logs**: Review cleanup logs for errors
4. **Adjust Retention**: Increase retention for active projects

## 📚 Related Resources

- [Windows Disk Cleanup](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)
- [Docker System Prune](https://docs.docker.com/engine/reference/commandline/system_prune/)
- [NPM Cache Clean](https://docs.npmjs.com/cli/v8/commands/npm-cache)

---

**Next Steps**: Run the script in preview mode, then schedule weekly automated cleanup!

---

*Automated Maintenance for Peak Performance*
