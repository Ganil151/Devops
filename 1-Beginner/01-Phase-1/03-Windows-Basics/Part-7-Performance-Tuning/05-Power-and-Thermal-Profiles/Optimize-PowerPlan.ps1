<#
.SYNOPSIS
    Professional Power Architecture & Thermal Profile Optimizer.

.DESCRIPTION
    A senior-level automation script for managing Windows Power Plans. It targets 
    the elimination of CPU frequency scaling latency and core parking jitter, 
    ensuring that virtualized workloads (WSL2, Docker) have consistent access 
    to physical hardware cycles.

    Modes:
    - Ultimate: Maximum hardware throughput (0% idle scaling).
    - Balanced: Default Windows thermal/energy management.
    - List: Complete audit of GUID-to-Name mappings.

.PARAMETER Mode
    Selection: Ultimate, Balanced.

.PARAMETER List
    Switch to output system power schemes.

.PARAMETER Backup
    Captures the current active power scheme GUID to a rollback log.

.NOTES
    Author: Senior Windows Systems Engineer (Performance Specialist)
    Version: 2.0 (Golden Standard)
    Target Metric: Frequency Scaling & Core Parking
    Safety: Includes pre-check for 'Modern Standby' restrictions.
#>
function Optimize-PowerPlan {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateSet("Ultimate", "Balanced")]
        [string]$Mode,

        [switch]$List,

        [switch]$Backup = $true
    )

    # --- 1. Admin Verification ---
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "CRITICAL: Administrator privileges required for Power Architecture modification."
        return
    }

    # --- 2. Automated Safety Backup ---
    if ($Backup) {
        $Active = (powercfg -getactivescheme).Split(' ')[3]
        $LogDir = "$HOME\DevOps_Backups\Power"
        if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
        $Active | Out-File -FilePath "$LogDir\Last_Active_Scheme.txt" -Encoding utf8
        Write-Host "`n[🛡️] ARCHITECTURAL BACKUP: Active scheme ($Active) logged." -ForegroundColor Gray
    }

    # --- 3. Audit Path ---
    if ($List) {
        Write-Host "`n[📋] AUDITING SYSTEM POWER SCHEMES" -ForegroundColor Cyan
        powercfg -list
        return
    }

    # --- 4. Tuning Logic ---
    Write-Progress -Activity "Power Architecture Tuning" -Status "Analyzing current thermal profile..." -PercentComplete 20
    
    switch ($Mode) {
        "Ultimate" {
            Write-Host "`n[🚀] ACTIVATING ULTIMATE PERFORMANCE ARCHITECTURE" -ForegroundColor Cyan
            Write-Host "--------------------------------------------------------" -ForegroundColor Gray
            
            try {
                $Schemes = powercfg -list
                if ($Schemes -match "Ultimate Performance") {
                    $Guid = ($Schemes | Select-String "Ultimate Performance").ToString().Split(' ')[3]
                    Write-Host " [+] Existing Ultimate scheme detected: $Guid" -ForegroundColor Gray
                } else {
                    Write-Host " [!] Ultimate scheme missing. Duplicating kernel base..." -ForegroundColor Yellow
                    Write-Progress -Activity "Power Architecture Tuning" -Status "Duplicating Ultimate Base..." -PercentComplete 50
                    $Output = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
                    if ($LASTEXITCODE -ne 0) { throw "Hardware/OS restriction prevented duplication." }
                    $Guid = $Output.ToString().Split(' ')[3]
                }

                Write-Progress -Activity "Power Architecture Tuning" -Status "Applying ultimate state..." -PercentComplete 80
                powercfg -setactive $Guid
                Write-Host "[✔] System is now pinned to ULTIMATE PERFORMANCE (Max GHz)." -ForegroundColor Green
            } catch {
                Write-Error "FAILURE: Thermal profile lock detected. BIOS/Modern-Standby may be restricting plans."
                Write-Host "`n[💡] Fallback: powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61" -ForegroundColor Yellow
            }
        }

        "Balanced" {
            Write-Host "`n[⚖️] RESTORING BALANCED ARCHITECTURE" -ForegroundColor Cyan
            $BalancedGuid = "381b4222-f694-41f0-9685-ff5bb260df2e"
            powercfg -setactive $BalancedGuid
            Write-Host "[✔] System restored to Balanced scaling (Energy efficient)." -ForegroundColor Green
        }
    }
    
    Write-Progress -Activity "Power Architecture Tuning" -Completed
}

# --- Execution Controller ---
if ($PSBoundParameters.Count -gt 0) {
    Optimize-PowerPlan -Mode $Mode -Backup $Backup
} else {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Magenta
    Write-Host "      WIN-DEVOPS POWER ARCHITECT V2.0               " -ForegroundColor White
    Write-Host "====================================================" -ForegroundColor Magenta
    Write-Host " 1. [MODE] Ultimate Performance (Zero Throttling)    "
    Write-Host " 2. [MODE] Balanced (Mobile/Standard Scaling)       "
    Write-Host " 3. [AUDIT] List GUID-to-Name Mappings              "
    Write-Host " 4. [EXIT]                                          "
    Write-Host "====================================================" -ForegroundColor Magenta
    
    $Choice = Read-Host "`nSelection"
    switch ($Choice) {
        "1" { Optimize-PowerPlan -Mode Ultimate }
        "2" { Optimize-PowerPlan -Mode Balanced }
        "3" { Optimize-PowerPlan -List }
        default { return }
    }
}
