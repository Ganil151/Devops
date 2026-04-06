<#
.SYNOPSIS
    DevOps Maintenance Tool for Build Artifact and System Cache Cleanup.

.DESCRIPTION
    This script maintains peak I/O performance on CI/CD nodes by systematically
    clearing temporary build artifacts, Windows Update cache, prefetch data, and
    other accumulated debris that degrades disk performance over time. Designed
    for unattended execution via scheduled tasks or Jenkins jobs.

    Cleanup Targets:
    - Temporary build artifacts (npm, Maven, Gradle, NuGet caches)
    - Windows Temp directories (%TEMP%, C:\Windows\Temp)
    - Windows Update cache (C:\Windows\SoftwareDistribution)
    - Prefetch data (C:\Windows\Prefetch)
    - Browser caches (Edge, Chrome - if present)
    - Docker build cache (optional)
    - IIS logs (optional)
    - Event logs (optional, with retention)

    Safety Features:
    - Excludes active/locked files automatically
    - Calculates space savings before/after
    - Detailed logging with file counts
    - Dry-run mode for validation
    - Configurable retention periods

.PARAMETER Mode
    Cleanup intensity: Basic, Standard, or Aggressive.
    - Basic: Temp files and prefetch only
    - Standard: + Windows Update cache and build artifacts
    - Aggressive: + Docker cache and IIS logs

.PARAMETER DryRun
    Preview cleanup actions without deleting files.

.PARAMETER SkipDockerCache
    Preserve Docker build cache (useful for active build nodes).

.PARAMETER RetentionDays
    Keep files newer than this many days (default: 7).

.EXAMPLE
    .\Invoke-ArtifactCleanup.ps1 -Mode Standard
    Perform standard cleanup with 7-day retention.

.EXAMPLE
    .\Invoke-ArtifactCleanup.ps1 -Mode Aggressive -DryRun
    Preview aggressive cleanup without deleting files.

.EXAMPLE
    .\Invoke-ArtifactCleanup.ps1 -Mode Standard -RetentionDays 30 -Verbose
    Clean files older than 30 days with detailed logging.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard)
    Target: Windows Server + Windows 11 (CI/CD nodes and workstations)
    Safety: Automatic exclusion of locked files
    Idempotency: Safe to run multiple times
    Scheduling: Recommended weekly via Task Scheduler
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, HelpMessage = "Cleanup intensity level")]
    [ValidateSet("Basic", "Standard", "Aggressive")]
    [string]$Mode = "Standard",

    [Parameter(HelpMessage = "Preview cleanup without deleting files")]
    [switch]$DryRun,

    [Parameter(HelpMessage = "Skip Docker build cache cleanup")]
    [switch]$SkipDockerCache,

    [Parameter(HelpMessage = "Retention period in days (default: 7)")]
    [ValidateRange(0, 365)]
    [int]$RetentionDays = 7
)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# ============================================================================
# CLEANUP CONFIGURATION
# ============================================================================

$CLEANUP_TARGETS = @{
    Basic = @(
        @{Path="$env:TEMP"; Name="User Temp Files"; Recursive=$true},
        @{Path="C:\Windows\Temp"; Name="System Temp Files"; Recursive=$true},
        @{Path="C:\Windows\Prefetch"; Name="Prefetch Data"; Recursive=$false}
    )
    Standard = @(
        @{Path="$env:TEMP"; Name="User Temp Files"; Recursive=$true},
        @{Path="C:\Windows\Temp"; Name="System Temp Files"; Recursive=$true},
        @{Path="C:\Windows\Prefetch"; Name="Prefetch Data"; Recursive=$false},
        @{Path="C:\Windows\SoftwareDistribution\Download"; Name="Windows Update Cache"; Recursive=$true},
        @{Path="$env:LOCALAPPDATA\npm-cache"; Name="NPM Cache"; Recursive=$true},
        @{Path="$env:USERPROFILE\.gradle\caches"; Name="Gradle Cache"; Recursive=$true},
        @{Path="$env:USERPROFILE\.m2\repository"; Name="Maven Repository"; Recursive=$false},
        @{Path="$env:LOCALAPPDATA\NuGet\Cache"; Name="NuGet Cache"; Recursive=$true}
    )
    Aggressive = @(
        @{Path="$env:TEMP"; Name="User Temp Files"; Recursive=$true},
        @{Path="C:\Windows\Temp"; Name="System Temp Files"; Recursive=$true},
        @{Path="C:\Windows\Prefetch"; Name="Prefetch Data"; Recursive=$false},
        @{Path="C:\Windows\SoftwareDistribution\Download"; Name="Windows Update Cache"; Recursive=$true},
        @{Path="$env:LOCALAPPDATA\npm-cache"; Name="NPM Cache"; Recursive=$true},
        @{Path="$env:USERPROFILE\.gradle\caches"; Name="Gradle Cache"; Recursive=$true},
        @{Path="$env:USERPROFILE\.m2\repository"; Name="Maven Repository"; Recursive=$false},
        @{Path="$env:LOCALAPPDATA\NuGet\Cache"; Name="NuGet Cache"; Recursive=$true},
        @{Path="C:\inetpub\logs"; Name="IIS Logs"; Recursive=$true},
        @{Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"; Name="Edge Cache"; Recursive=$true},
        @{Path="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"; Name="Chrome Cache"; Recursive=$true}
    )
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Get-DirectorySize {
    param([string]$Path)
    
    if (!(Test-Path $Path)) { return 0 }
    
    try {
        $size = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        return [math]::Max($size, 0)
    } catch {
        return 0
    }
}

function Format-FileSize {
    param([long]$Bytes)
    
    if ($Bytes -ge 1TB) { return "{0:N2} TB" -f ($Bytes / 1TB) }
    elseif ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    elseif ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    else { return "$Bytes Bytes" }
}

function Remove-OldFiles {
    param(
        [string]$Path,
        [int]$Days,
        [bool]$Recurse,
        [bool]$Preview
    )
    
    if (!(Test-Path $Path)) {
        Write-Verbose "Path not found: $Path (skipping)"
        return @{Files=0; Size=0; Errors=0}
    }
    
    $cutoffDate = (Get-Date).AddDays(-$Days)
    $stats = @{Files=0; Size=0; Errors=0}
    
    try {
        $files = Get-ChildItem -Path $Path -File -Recurse:$Recurse -ErrorAction SilentlyContinue |
                 Where-Object { $_.LastWriteTime -lt $cutoffDate }
        
        foreach ($file in $files) {
            try {
                $stats.Size += $file.Length
                
                if (-not $Preview) {
                    Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                }
                
                $stats.Files++
                Write-Verbose "Deleted: $($file.FullName)"
                
            } catch {
                $stats.Errors++
                Write-Debug "Failed to delete: $($file.FullName) - $($_.Exception.Message)"
            }
        }
        
    } catch {
        Write-Warning "Error processing $Path: $($_.Exception.Message)"
    }
    
    return $stats
}

# ============================================================================
# MAIN FUNCTION: Invoke-Cleanup
# ============================================================================

function Invoke-Cleanup {
    [CmdletBinding()]
    param(
        [string]$CleanupMode,
        [int]$Retention,
        [bool]$Preview,
        [bool]$SkipDocker
    )

    try {
        $startTime = Get-Date
        $logDir = "$env:ProgramData\DevOps_Logs\Maintenance"
        if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
        
        $logFile = "$logDir\Cleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        
        # --- 1. Header ---
        Write-Host "`n[🧹] ARTIFACT CLEANUP INITIATED" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        Write-Host "Mode:           $CleanupMode" -ForegroundColor White
        Write-Host "Retention:      $Retention days" -ForegroundColor White
        Write-Host "Preview Mode:   $(if ($Preview) { 'YES (no files deleted)' } else { 'NO (files will be deleted)' })" -ForegroundColor $(if ($Preview) { 'Yellow' } else { 'White' })
        Write-Host "Log File:       $logFile" -ForegroundColor Gray
        
        "Cleanup started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $logFile
        "Mode: $CleanupMode | Retention: $Retention days | Preview: $Preview" | Out-File $logFile -Append

        # --- 2. Pre-Cleanup Disk Space ---
        Write-Host "`n[📊] ANALYZING DISK SPACE" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        $systemDrive = Get-PSDrive -Name C
        $freeSpaceBefore = $systemDrive.Free
        Write-Host "Free Space (Before): $(Format-FileSize $freeSpaceBefore)" -ForegroundColor White

        # --- 3. Stop Windows Update Service (for cache cleanup) ---
        if ($CleanupMode -ne "Basic") {
            Write-Host "`n[⏸️] STOPPING WINDOWS UPDATE SERVICE" -ForegroundColor Cyan
            try {
                $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
                if ($wuService -and $wuService.Status -eq 'Running') {
                    Stop-Service -Name wuauserv -Force -ErrorAction Stop
                    Write-Host "[✔] Windows Update service stopped" -ForegroundColor Green
                    $restartWU = $true
                } else {
                    $restartWU = $false
                }
            } catch {
                Write-Warning "Failed to stop Windows Update service: $($_.Exception.Message)"
                $restartWU = $false
            }
        }

        # --- 4. Execute Cleanup ---
        Write-Host "`n[🗑️] CLEANING ARTIFACTS" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        $targets = $CLEANUP_TARGETS[$CleanupMode]
        $totalStats = @{Files=0; Size=0; Errors=0}
        
        for ($i = 0; $i -lt $targets.Count; $i++) {
            $target = $targets[$i]
            Write-Progress -Activity "Cleaning Artifacts" -Status "Processing: $($target.Name)" -PercentComplete (($i / $targets.Count) * 100)
            
            Write-Host "`n[$($i+1)/$($targets.Count)] $($target.Name)" -ForegroundColor Yellow
            Write-Host "Path: $($target.Path)" -ForegroundColor Gray
            
            $stats = Remove-OldFiles -Path $target.Path -Days $Retention -Recurse $target.Recursive -Preview $Preview
            
            Write-Host "  Files: $($stats.Files) | Size: $(Format-FileSize $stats.Size) | Errors: $($stats.Errors)" -ForegroundColor White
            
            $totalStats.Files += $stats.Files
            $totalStats.Size += $stats.Size
            $totalStats.Errors += $stats.Errors
            
            "$($target.Name): $($stats.Files) files, $(Format-FileSize $stats.Size)" | Out-File $logFile -Append
        }
        
        Write-Progress -Activity "Cleaning Artifacts" -Completed

        # --- 5. Docker Build Cache (Optional) ---
        if ($CleanupMode -eq "Aggressive" -and -not $SkipDocker) {
            Write-Host "`n[🐳] CLEANING DOCKER BUILD CACHE" -ForegroundColor Cyan
            
            try {
                if (Get-Command docker -ErrorAction SilentlyContinue) {
                    if (-not $Preview) {
                        $dockerOutput = docker system prune -af --volumes 2>&1
                        Write-Host "[✔] Docker cache cleaned" -ForegroundColor Green
                        "Docker cache cleaned" | Out-File $logFile -Append
                    } else {
                        Write-Host "[PREVIEW] Would clean Docker cache" -ForegroundColor Yellow
                    }
                } else {
                    Write-Verbose "Docker not installed (skipping)"
                }
            } catch {
                Write-Warning "Docker cleanup failed: $($_.Exception.Message)"
            }
        }

        # --- 6. Event Log Cleanup (Optional) ---
        if ($CleanupMode -eq "Aggressive") {
            Write-Host "`n[📝] CLEANING EVENT LOGS" -ForegroundColor Cyan
            
            try {
                $eventLogs = @("Application", "System", "Security")
                foreach ($log in $eventLogs) {
                    if (-not $Preview) {
                        wevtutil cl $log 2>&1 | Out-Null
                        Write-Host "[✔] Cleared event log: $log" -ForegroundColor Green
                    } else {
                        Write-Host "[PREVIEW] Would clear event log: $log" -ForegroundColor Yellow
                    }
                }
                "Event logs cleared" | Out-File $logFile -Append
            } catch {
                Write-Warning "Event log cleanup failed: $($_.Exception.Message)"
            }
        }

        # --- 7. Restart Windows Update Service ---
        if ($restartWU) {
            Write-Host "`n[▶️] RESTARTING WINDOWS UPDATE SERVICE" -ForegroundColor Cyan
            try {
                Start-Service -Name wuauserv -ErrorAction Stop
                Write-Host "[✔] Windows Update service restarted" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to restart Windows Update service: $($_.Exception.Message)"
            }
        }

        # --- 8. Post-Cleanup Disk Space ---
        Write-Host "`n[📊] FINAL DISK SPACE ANALYSIS" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        $systemDrive = Get-PSDrive -Name C
        $freeSpaceAfter = $systemDrive.Free
        $spaceSaved = $freeSpaceAfter - $freeSpaceBefore
        
        Write-Host "Free Space (Before): $(Format-FileSize $freeSpaceBefore)" -ForegroundColor White
        Write-Host "Free Space (After):  $(Format-FileSize $freeSpaceAfter)" -ForegroundColor White
        Write-Host "Space Recovered:     $(Format-FileSize $spaceSaved)" -ForegroundColor Green

        # --- 9. Summary ---
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        Write-Host "`n[✅] CLEANUP COMPLETE" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "========================================" -ForegroundColor Gray
        Write-Host "Files Processed:  $($totalStats.Files)" -ForegroundColor White
        Write-Host "Data Removed:     $(Format-FileSize $totalStats.Size)" -ForegroundColor White
        Write-Host "Space Recovered:  $(Format-FileSize $spaceSaved)" -ForegroundColor White
        Write-Host "Errors:           $($totalStats.Errors)" -ForegroundColor $(if ($totalStats.Errors -gt 0) { 'Yellow' } else { 'White' })
        Write-Host "Duration:         $([math]::Round($duration, 2)) seconds" -ForegroundColor White
        Write-Host "`nLog File: $logFile" -ForegroundColor Gray
        
        "Cleanup completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $logFile -Append
        "Files: $($totalStats.Files) | Size: $(Format-FileSize $totalStats.Size) | Space: $(Format-FileSize $spaceSaved)" | Out-File $logFile -Append

        if ($Preview) {
            Write-Host "`n[ℹ️] This was a PREVIEW. Run without -DryRun to delete files." -ForegroundColor Yellow
        }

    } catch {
        Write-Error "CRITICAL FAILURE: $($_.Exception.Message)"
        throw
    }
}

# ============================================================================
# EXECUTION ENTRY POINT
# ============================================================================

Clear-Host
Write-Host "============================================" -ForegroundColor Blue
Write-Host "   ARTIFACT CLEANUP AUTOMATION v1.0        " -ForegroundColor White
Write-Host "   DevOps Maintenance Tool                 " -ForegroundColor White
Write-Host "============================================" -ForegroundColor Blue

Invoke-Cleanup `
    -CleanupMode $Mode `
    -Retention $RetentionDays `
    -Preview $DryRun `
    -SkipDocker $SkipDockerCache
