# --- Run as Admin Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! CRITICAL: This script MUST be run as Administrator to access Power Schemes !!!"
    Pause; Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "    WIN 11 POWER OVERLAY FIX (NO REGISTRY)    " -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host " 1. SET: Best Performance (Maximum Power)     "
    Write-Host " 2. SET: Balanced (Standard)                 "
    Write-Host " 3. SET: Best Power Efficiency (Battery)     "
    Write-Host " 4. UNHIDE: All CPU & Performance Settings   "
    Write-Host " 5. Exit                                     "
    Write-Host "==============================================" -ForegroundColor Cyan
}

Show-Menu
$choice = Read-Host "Select an option [1-5]"
$activeScheme = (powercfg -getactivescheme).Split(' ')[3]

# GUIDs for the Windows 11 Overlay System
$OverlaySubGroup = "fea34d30-22c7-4c07-889e-29f1797c2106"
$OverlaySetting  = "be337238-0d82-4146-a960-4f3749d470c7"

switch ($choice) {
    "1" { 
        $index = 2
        Write-Host "Applying 'Best Performance' Overlay..." -ForegroundColor Green
    }
    "2" { 
        $index = 1
        Write-Host "Applying 'Balanced' Overlay..." -ForegroundColor Yellow
    }
    "3" { 
        $index = 0
        Write-Host "Applying 'Best Power Efficiency' Overlay..." -ForegroundColor Cyan
    }
    "4" {
        Write-Host "Unlocking hidden CPU attributes..." -ForegroundColor Green
        # Unhide the main subgroup
        powercfg -attributes SUB_PROCESSOR -ATTRIB_HIDE
        # Unhide every single setting under the processor group (Full God Mode)
        $settings = Get-CimInstance -Namespace root\cimv2\power -Class Win32_PowerSetting | Where-Object { $_.InstanceID -match "SUB_PROCESSOR" }
        foreach ($s in $settings) {
            $guid = ($s.InstanceID -split '\\')[1]
            powercfg -attributes SUB_PROCESSOR $guid -ATTRIB_HIDE
        }
        Write-Host "All Processor settings are now visible in Advanced Power Options." -ForegroundColor Green
        Pause; return
    }
    "5" { Exit }
    default { Write-Warning "Invalid selection"; Pause; return }
}

# Apply using the index method which is more stable on Windows 11 22H2/23H2+
# This avoids the "Registry Access Denied" error
powercfg -setacvalueindex $activeScheme $OverlaySubGroup $OverlaySetting $index
powercfg -setdcvalueindex $activeScheme $OverlaySubGroup $OverlaySetting $index

# Crucial: Re-activate the plan to force the Windows 11 UI to refresh
powercfg -setactive $activeScheme

Write-Host "`nSuccess! Mode updated via PowerCFG." -ForegroundColor Green
Write-Host "Verify in: Settings > System > Power & Battery > Power mode" -ForegroundColor Gray
Pause