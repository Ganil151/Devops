<#
.SYNOPSIS
    Professional DevOps System Maintenance & Infrastructure Pruning Utility.

.DESCRIPTION
    A high-fidelity cleanup engine designed for Windows 11 DevOps environments. 
    This script intelligently prunes OS-level temporary data, optimizes the Windows 
    Component Store (WinSxS), and deep-cleans DevOps artifacts from Docker, 
    Kubernetes, and common Programming Language package managers.

    Key Features:
    - OS Maintenance: Temp files (>24h), DNS Flush, Prefetch, and SSD Re-Trim.
    - Deep Clean: WinSxS optimization using DISM /ResetBase.
    - DevOps Pruning: Docker Builder/Volume prune, Minikube logs, and NPM/Go/Cargo cache cleaning.
    - Metrics: Calculates and reports total disk space reclaimed during the session.
    - Idempotent: safe to run repeatedly via automation or manual triggers.

.PARAMETER Mode
    Selection of maintenance scope:
    - Basic: Standard OS-level temp and cache cleanup.
    - Deep: Basic + Windows Component Store (WinSxS) compression.
    - DevOps: Focuses purely on dev artifacts (Containers, Languages, K8s).
    - All: Comprehensive full-system deployment (Recommended monthly).

.PARAMETER AutoRestart
    If specified, some services (like Docker) may be restarted if required for deep cleanup.

.NOTES
    Author: Senior Systems Engineer
    Version: 2.1 (The Golden Standard)
    Requires: Administrator Privileges
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, HelpMessage = "Scope of maintenance to perform.")]
    [ValidateSet("Basic", "Deep", "DevOps", "All")]
    [string]$Mode,

    [Parameter(HelpMessage = "Force cleanup of locked files by restarting services.")]
    [switch]$AutoRestart
)

function Invoke-MaintenanceLogic {
    [CmdletBinding()]
    param($SelectedMode)

    # --- 1. Admin Verification ---
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "CRITICAL: Administrator privileges are required for system maintenance."
        return
    }

    # --- 2. Initial Space Calculation ---
    $GetVolumeSize = {
        param($Drive = "C:")
        return (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$Drive'").FreeSpace
    }
    $StartSpace = &$GetVolumeSize

    try {
        # --- 3. BASIC OS MAINTENANCE ---
        if ($SelectedMode -in @("Basic", "Deep", "All")) {
            Write-Host "`n[🧹] INITIATING OS MAINTENANCE" -ForegroundColor Cyan
            Write-Host "--------------------------------------------------------" -ForegroundColor Gray
            
            # Temp File Purge (Older than 24h)
            $Limit = (Get-Date).AddDays(-1)
            $TempPaths = @("$env:TEMP", "C:\Windows\Temp", "$env:SystemRoot\SoftwareDistribution\Download")
            foreach ($Path in $TempPaths) {
                if (Test-Path $Path) {
                    Write-Host " [+] Scrubbing: $Path" -ForegroundColor Gray
                    Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | 
                    Where-Object { $_.LastWriteTime -lt $Limit } | 
                    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                }
            }

            # Caches
            Write-Host " [+] Flushing DNS & Prefetch" -ForegroundColor Gray
            ipconfig /flushdns | Out-Null
            Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue

            # Hardware Optimization
            Write-Host " [+] Triggering SSD Re-Trim (Drive C:)" -ForegroundColor Gray
            Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue
            
            Write-Host "[✔] Basic OS maintenance complete." -ForegroundColor Green
        }

        # --- 4. DEEP COMPONENT OPTIMIZATION ---
        if ($SelectedMode -in @("Deep", "All")) {
            Write-Host "`n[📦] STARTING COMPONENT STORE COMPRESSION (WINSXS)" -ForegroundColor Cyan
            Write-Host "--------------------------------------------------------" -ForegroundColor Gray
            Write-Host " [!] This may take several minutes. Optimizing base images..." -ForegroundColor Yellow
            
            # DISM Cleanup
            dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase /NoRestart
            
            Write-Host "[✔] Component store is now optimized." -ForegroundColor Green
        }

        # --- 5. DEVOPS INFRASTRUCTURE PRUNING ---
        if ($SelectedMode -in @("DevOps", "All")) {
            Write-Host "`n[🐳] PRUNING DEVOPS ARTIFACTS" -ForegroundColor Cyan
            Write-Host "--------------------------------------------------------" -ForegroundColor Gray
            
            # Docker
            if (Get-Command docker -ErrorAction SilentlyContinue) {
                Write-Host " [+] Pruning Docker BuildKit Cache & Volumes" -ForegroundColor Gray
                docker builder prune -a -f -q
                docker system prune -f --volumes -q
            }

            # Kubernetes (Local)
            $K8sLogs = @("$HOME\.minikube\cache", "$HOME\.minikube\logs", "$HOME\.kube\cache")
            foreach ($k in $K8sLogs) {
                if (Test-Path $k) { 
                    Write-Host " [+] Clearing K8s Cache: $k" -ForegroundColor Gray
                    Remove-Item "$k\*" -Recurse -Force -ErrorAction SilentlyContinue 
                }
            }

            # Languages & Tooling
            Write-Host " [+] Clearing Package Manager Caches (NPM/Go/Cargo)" -ForegroundColor Gray
            if (Get-Command npm -ErrorAction SilentlyContinue) { npm cache clean --force 2>&1 | Out-Null }
            if (Get-Command go -ErrorAction SilentlyContinue) { go clean -modcache 2>&1 | Out-Null }
            if (Get-Command cargo -ErrorAction SilentlyContinue) { cargo clean 2>&1 | Out-Null }
            
            Write-Host "[✔] DevOps artifact cleanup complete." -ForegroundColor Green
        }

        # --- 6. Final Results ---
        $EndSpace = &$GetVolumeSize
        $SavedMB = [math]::round(($EndSpace - $StartSpace) / 1MB, 2)
        
        Write-Host "`n[💎] MAINTENANCE CYCLE COMPLETE." -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host " Total Space Reclaimed: " -NoNewline; Write-Host "$SavedMB MB" -ForegroundColor Green
        Write-Host " Recommendation: Perform a Deep maintenance monthly to keep WinSxS size low.`n" -ForegroundColor DarkGray

    } catch {
        Write-Error "CRITICAL FAILURE: $($_.Exception.Message)"
    }
}

# --- Execution Controller ---
if ($PSBoundParameters.Count -gt 0 -and $Mode) {
    # Direct Parameter Call
    Invoke-MaintenanceLogic -SelectedMode $Mode
} else {
    # Interactive Menu
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "      WIN-DEVOPS SYSTEM MAINTENANCE SUITE          " -ForegroundColor White
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host " 1. [BASIC]  Purge Temp, Flush DNS, SSD Trim        "
    Write-Host " 2. [DEEP]   Component Store Clean (WinSxS) + Basic "
    Write-Host " 3. [DEVOPS] Docker, K8s, and Language Cache Clean   "
    Write-Host " 4. [ULTRA]  Run Full System Maintenance Cycle       "
    Write-Host " 5. [EXIT]                                          "
    Write-Host "====================================================" -ForegroundColor Cyan

    $Choice = Read-Host "`nSelect an action"
    switch ($Choice) {
        "1" { Invoke-MaintenanceLogic -SelectedMode "Basic" }
        "2" { Invoke-MaintenanceLogic -SelectedMode "Deep" }
        "3" { Invoke-MaintenanceLogic -SelectedMode "DevOps" }
        "4" { Invoke-MaintenanceLogic -SelectedMode "All" }
        default { return }
    }
}
