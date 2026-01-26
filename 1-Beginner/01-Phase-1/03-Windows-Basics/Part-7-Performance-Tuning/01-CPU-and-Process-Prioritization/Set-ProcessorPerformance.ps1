<#
.SYNOPSIS
    Professional Processor Performance & Power Architecture Manager.

.DESCRIPTION
    A high-fidelity utility for managing advanced CPU performance states, thermal throttling
    behaviors, and core management. This script goes beyond standard Windows UI by 
    unlocking hidden "God Mode" power settings and providing programmatic access to
    Performance Boost Modes, Core Parking, and Frequency Scaling.

.PARAMETER BoostMode
    Sets the CPU Boost behavior (0-6). 2 is Aggressive (Max performance).
.PARAMETER UnlockAll
    Unlocks all hidden Windows power settings (God Mode).
.PARAMETER CoreParking
    Sets Core Parking to 100% to prevent core sleep.
.PARAMETER Revert
    Restores stock visibility for processor settings.

.NOTES
    Author: Senior Systems Automation Engineer
    Version: 2.2 (Auto-Execute Fix)
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(HelpMessage = "CPU Boost Mode (0-6)")]
    [ValidateRange(0, 6)]
    [int]$BoostMode,

    [Parameter(HelpMessage = "Sets Core Parking to 100% to prevent core sleep.")]
    [switch]$CoreParking,

    [Parameter(HelpMessage = "Unlocks all hidden Windows power settings (God Mode).")]
    [switch]$UnlockAll,

    [Parameter(HelpMessage = "Restores stock visibility for processor settings.")]
    [switch]$Revert
)

function Invoke-ProcessorTuning {
    [CmdletBinding()]
    param($Boost, $Parking, $Unlock, $Rev)

    # --- 1. Admin Verification ---
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "CRITICAL: Administrator privileges required to modify Processor Architecture."
        return
    }

    $SubProcessor = "SUB_PROCESSOR"
    $BoostGuid    = "be337238-0d82-4146-a960-4f3749d470c7"
    $ParkingMin   = "0cc5b647-c1df-4637-891a-dec35c318583" # Min Cores
    $ParkingMax   = "ea062307-7e22-4425-99d9-1da5f462a2bb" # Max Cores
    
    $activeScheme = (powercfg -getactivescheme).Split(' ')[3]

    try {
        if ($Rev) {
            Write-Host "[!] Reverting Processor Visibility to Defaults..." -ForegroundColor Red
            powercfg -attributes $SubProcessor +ATTRIB_HIDE
            Write-Host "[✔] Visibility restored." -ForegroundColor Green
            return
        }

        if ($Unlock) {
            Write-Host "[🔥] INITIATING FULL POWER SETTINGS UNLOCK (GOD MODE)" -ForegroundColor Cyan
            $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings"
            $Settings = Get-ChildItem -Path $registryPath -Recurse | Where-Object { $_.Property -contains "Attributes" }
            foreach ($S in $Settings) {
                Set-ItemProperty -Path $S.PSPath -Name "Attributes" -Value 2
                $Friendly = (Get-ItemProperty $S.PSPath).FriendlyName
                if ($Friendly) { Write-Host " [+] Unlocked: $Friendly" -ForegroundColor Gray }
            }
            Write-Host "[✔] All Power Settings are now visible." -ForegroundColor Green
        } else {
            powercfg -attributes $SubProcessor -ATTRIB_HIDE
            powercfg -attributes $SubProcessor $BoostGuid -ATTRIB_HIDE
        }

        if ($PSBoundParameters.ContainsKey('BoostMode') -or $Boost -ne 0) {
            $ModeDesc = switch($Boost) {
                0 { "Disabled" }
                1 { "Enabled" }
                2 { "Aggressive" }
                3 { "Efficient Enabled" }
                4 { "Efficient Aggressive" }
                5 { "Aggressive at Guaranteed" }
                6 { "Efficient Aggressive at Guaranteed" }
            }
            Write-Host "`n[🚀] Setting Boost Mode to: $ModeDesc" -ForegroundColor Yellow
            powercfg -setacvalueindex $activeScheme $SubProcessor $BoostGuid $Boost
            powercfg -setdcvalueindex $activeScheme $SubProcessor $BoostGuid $Boost
            powercfg -setactive $activeScheme
        }

        if ($Parking) {
            Write-Host "`n[🧠] OPTIMIZING CORE PARKING (NO-SLEEP MODE)" -ForegroundColor Cyan
            powercfg -attributes $SubProcessor $ParkingMin -ATTRIB_HIDE
            powercfg -attributes $SubProcessor $ParkingMax -ATTRIB_HIDE
            powercfg -setacvalueindex $activeScheme $SubProcessor $ParkingMin 100
            powercfg -setacvalueindex $activeScheme $SubProcessor $ParkingMax 100
            powercfg -setactive $activeScheme
            Write-Host "[✔] Core Parking disabled." -ForegroundColor Green
        }

        Write-Host "`n[💎] PROCESSOR CONFIGURATION DEPLOYED." -ForegroundColor White -BackgroundColor DarkGreen
    } catch {
        Write-Error "CRITICAL ARCHITECTURE FAILURE: $($_.Exception.Message)"
    }
}

# --- Execution Controller ---
if ($PSBoundParameters.Count -gt 0) {
    # Run with passed parameters
    Invoke-ProcessorTuning -Boost $BoostMode -Parking $CoreParking -Unlock $UnlockAll -Rev $Revert
} else {
    # Interactive Menu
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "      WIN-DEVOPS PROCESSOR ARCHITECT V2.2           " -ForegroundColor White
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host " 1. [UNLOCK] Full God-Mode Power Settings Unlock     "
    Write-Host " 2. [PERF]   Set Boost: Aggressive (Max Speed)       "
    Write-Host " 3. [STABLE] Set Boost: Disabled (Thermal Control)   "
    Write-Host " 4. [BRAIN]  Disable Core Parking (All Cores Active) "
    Write-Host " 5. [RESET]  Hide Advanced Settings                  "
    Write-Host " 6. [EXIT]                                           "
    Write-Host "====================================================" -ForegroundColor Cyan

    $Choice = Read-Host "`nSelection"
    switch ($Choice) {
        "1" { Invoke-ProcessorTuning -Unlock }
        "2" { Invoke-ProcessorTuning -Boost 2 }
        "3" { Invoke-ProcessorTuning -Boost 0 }
        "4" { Invoke-ProcessorTuning -Parking }
        "5" { Invoke-ProcessorTuning -Rev }
        default { return }
    }
}
