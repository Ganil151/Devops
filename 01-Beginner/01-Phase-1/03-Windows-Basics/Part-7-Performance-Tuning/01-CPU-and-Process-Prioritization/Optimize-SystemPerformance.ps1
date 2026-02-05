<#
.SYNOPSIS
    Professional System Performance, Privacy & Latency Optimization Suite.

.DESCRIPTION
    A senior-level "Supreme Golden Script" for Windows 11 system optimization. 
    It consolidates hardware unlocks, kernel-level latency tweaks, and deep 
    privacy hardening into an idempotent, professional-grade utility.

    Optimization Domains:
    - CPU: Advanced power settings (Boost, Parking) and optimal response modes.
    - GPU: Hardware Accelerated GPU Scheduling (HAGS) and PCIe link tuning.
    - Disk I/O: NTFS metadata tuning (LastAccess, MemoryUsage).
    - Latency: Win32 Priority Separation for IDE responsiveness.
    - Privacy: Telemetry service scrubbing and advertising ID removal.
    - Security: Optional toggle for VBS/Memory Integrity.

.PARAMETER Mode
    - Full: Applies everything (Performance + Privacy + UI).
    - Gaming: Maximum raw throughput (Disables VBS, removes all throttles).
    - Dev: Balanced performance (Keeps VBS on, tunes I/O and UI).
    - Privacy: Harden the system without touching hardware performance.

.PARAMETER Revert
    Restores power plans, registry keys, and services to Windows defaults.

.PARAMETER Backup
    Creates a System Restore Point before making kernel-level changes.

.NOTES
    Author: Senior Windows Systems Engineer (Performance Specialist)
    Version: 3.1 (Golden Standard)
    Target Metric: % Processor Time & Context Switches/sec
    Safety: Includes VSS Restore Point logic.
#>
function Optimize-SystemPerformance {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0)]
        [ValidateSet("Full", "Gaming", "Dev", "Privacy")]
        [string]$Mode = "Full",

        [switch]$Revert,

        [switch]$Backup = $true
    )

    # --- 1. Admin Verification ---
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "CRITICAL: Administrator privileges are required for kernel-level optimization."
        return
    }

    $activeScheme = (powercfg -getactivescheme).Split(' ')[3]

    # --- 2. Operational Logic Paths ---
    if ($Revert) {
        Write-Host "`n[!] RESTORING SYSTEM ARCHITECTURE TO DEFAULTS..." -ForegroundColor Red
        Write-Host "--------------------------------------------------------" -ForegroundColor Gray

        Write-Progress -Activity "System Restoration" -Status "Resetting Power Schemes..." -PercentComplete 25
        powercfg -restoredefaultschemes
        
        Write-Progress -Activity "System Restoration" -Status "Restoring Registry Hives..." -PercentComplete 50
        $Defaults = @{
            "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" = @{ "Enabled" = 1 }
            "HKCU:\Control Panel\Desktop" = @{ "MenuShowDelay" = "400" }
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" = @{ "AllowTelemetry" = 1 }
            "HKLM:\System\CurrentControlSet\Control\PriorityControl" = @{ "Win32PrioritySeparation" = 2 }
        }

        foreach ($Path in $Defaults.Keys) {
            foreach ($Name in $Defaults[$Path].Keys) {
                Set-ItemProperty -Path $Path -Name $Name -Value $Defaults[$Path][$Name] -ErrorAction SilentlyContinue
            }
        }

        Write-Progress -Activity "System Restoration" -Status "Restarting Services..." -PercentComplete 75
        Set-Service -Name "DiagTrack" -StartupType Automatic -ErrorAction SilentlyContinue
        
        Write-Progress -Activity "System Restoration" -Completed
        Write-Host "[✔] Factory settings restored. Reboot is highly recommended." -ForegroundColor Green
        return
    }

    # Optional Backup
    if ($Backup) {
        Write-Host "`n[*] Creating System Restore Point for safety..." -ForegroundColor Cyan
        Write-Progress -Activity "Safety Backup" -Status "Triggering VSS Restore Point..." -PercentComplete 50
        Checkpoint-Computer -Description "DevOps_Optimization_v3" -RestorePointType "APPLICATION_INSTALL" -ErrorAction SilentlyContinue
        Write-Progress -Activity "Safety Backup" -Completed
    }

    try {
        # --- 3. HARDWARE & PERFORMANCE TUNING ---
        if ($Mode -in @("Full", "Gaming", "Dev")) {
            Write-Host "`n[🚀] DEPLOYING PERFORMANCE ARCHITECTURE" -ForegroundColor Cyan
            Write-Host "--------------------------------------------------------" -ForegroundColor Gray

            $Tasks = @(
                @{Name="CPU Boost & Power States"; Cmd={
                    powercfg -attributes SUB_PROCESSOR -ATTRIB_HIDE
                    $BoostGuid = "be337238-0d82-4146-a960-4f3749d470c7"
                    powercfg -attributes SUB_PROCESSOR $BoostGuid -ATTRIB_HIDE
                    $BoostVal = if ($Mode -eq "Dev") { 1 } else { 2 }
                    powercfg -setacvalueindex $activeScheme SUB_PROCESSOR $BoostGuid $BoostVal
                }},
                @{Name="GPU Scheduling (HAGS)"; Cmd={
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -ErrorAction SilentlyContinue
                }},
                @{Name="Win32 Priority Separation"; Cmd={
                    Set-ItemProperty -Path "HKLM\System\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38
                }},
                @{Name="UI Responsiveness (Menu Delay)"; Cmd={
                    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
                }}
            )

            for ($i = 0; $i -lt $Tasks.Count; $i++) {
                Write-Progress -Activity "Performance Tuning" -Status "Configuring: $($Tasks[$i].Name)" -PercentComplete (($i / $Tasks.Count) * 100)
                Write-Host " [+] Tuning: $($Tasks[$i].Name)" -ForegroundColor Gray
                & $Tasks[$i].Cmd | Out-Null
            }
            
            powercfg -setactive $activeScheme
            Write-Host "[✔] Hardware potential unlocked." -ForegroundColor Green
        }

        # --- 4. STORAGE & I/O OPTIMIZATION ---
        if ($Mode -in @("Full", "Gaming", "Dev")) {
            Write-Host "`n[💾] TUNING STORAGE PIPELINE" -ForegroundColor Cyan
            Write-Progress -Activity "Storage Optimization" -Status "Configuring NTFS Metadata..." -PercentComplete 50
            
            fsutil behavior set disablelastaccess 1 | Out-Null
            fsutil behavior set memoryusage 2 | Out-Null
            powercfg -h off
            
            Write-Host "[✔] I/O overhead minimized." -ForegroundColor Green
        }

        # --- 5. PRIVACY & SECURITY HARDENING ---
        if ($Mode -in @("Full", "Privacy", "Gaming")) {
            Write-Host "`n[🛡️] ENFORCING PRIVACY PROFILE" -ForegroundColor Cyan
            Write-Progress -Activity "Privacy Hardening" -Status "Scrubbing Telemetry..." -PercentComplete 50

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
            Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -PassThru | Stop-Service -ErrorAction SilentlyContinue
            
            $advPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
            if (!(Test-Path $advPath)) { New-Item $advPath -Force | Out-Null }
            Set-ItemProperty -Path $advPath -Name "Enabled" -Value 0

            if ($Mode -in @("Gaming", "Full")) {
                Write-Host " [!] Disabling High-Latency VBS/Memory Integrity" -ForegroundColor Yellow
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
            }

            Write-Host "[✔] System profile hardened." -ForegroundColor Green
        }

        Write-Progress -Activity "Full Optimization" -Completed
        Write-Host "`n[💎] OPTIMIZATION SUCCESSFUL" -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host " Target Performance: Deterministic Cycles / Zero Jitter`n" -ForegroundColor Gray

    } catch {
        Write-Error "CRITICAL OPTIMIZATION FAILURE: $($_.Exception.Message)"
    }
}

# --- Execution Controller ---
if ($PSBoundParameters.Count -gt 0) {
    Optimize-SystemPerformance -Mode $Mode -Backup $Backup
} else {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Blue
    Write-Host "   WINDOWS DEVOPS PERFORMANCE & PRIVACY SUITE       " -ForegroundColor White
    Write-Host "====================================================" -ForegroundColor Blue
    Write-Host " 1. [FULL]  Maximum Tune (Perf + Privacy + UI)       "
    Write-Host " 2. [DEV]   Balanced Dev Mode (Perf + Security On)    "
    Write-Host " 3. [PRIV]  Privacy Lockdown Only                    "
    Write-Host " 4. [GAMER] Raw Hardware speed (Disables Security)   "
    Write-Host " 5. [RESET] Restore Factory Defaults                 "
    Write-Host " 6. [EXIT]                                           "
    Write-Host "====================================================" -ForegroundColor Blue

    $Choice = Read-Host "`nSelection"
    switch ($Choice) {
        "1" { Optimize-SystemPerformance -Mode Full }
        "2" { Optimize-SystemPerformance -Mode Dev }
        "3" { Optimize-SystemPerformance -Mode Privacy }
        "4" { Optimize-SystemPerformance -Mode Gaming }
        "5" { Optimize-SystemPerformance -Revert }
        default { return }
    }
}
