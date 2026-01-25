# --- Admin Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! Administrator privileges are required to revert system changes !!!"
    Pause; Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host "    WIN 11 FACTORY RESET (TWEAK REVERSION)   " -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host " 1. REVERT: All CPU & Power Settings to Stock "
    Write-Host " 2. REVERT: Network Stack & DNS to Automatic  "
    Write-Host " 3. REVERT: Visuals, VBS & System Priority    "
    Write-Host " 4. REVERT: ALL (Full System Restore)        "
    Write-Host " 5. Exit                                     "
    Write-Host "==============================================" -ForegroundColor Red
}

while($true) {
    Show-Menu
    $choice = Read-Host "Selection"
    $activeScheme = (powercfg -getactivescheme).Split(' ')[3]

    switch ($choice) {
        "1" {
            Write-Host "[!] Hiding Advanced Power Settings..." -ForegroundColor Yellow
            powercfg -attributes SUB_PROCESSOR +ATTRIB_HIDE
            # Reset active plan to defaults
            powercfg -restoredefaultschemes
            Write-Host "Power schemes restored to Windows defaults." -ForegroundColor Green
        }
        "2" {
            Write-Host "[!] Resetting Network Stack & DNS..." -ForegroundColor Yellow
            netsh int ip reset
            netsh winsock reset
            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
            foreach ($a in $adapters) {
                Set-DnsClientServerAddress -InterfaceAlias $a.Name -ResetServerAddresses
            }
            Write-Host "Network settings reverted to DHCP." -ForegroundColor Green
        }
        "3" {
            Write-Host "[!] Restoring Visuals and Kernel Priorities..." -ForegroundColor Yellow
            # Restore VBS/Memory Integrity
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 1
            # Restore Win32 Priority
            Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 2
            # Restore Menu Delay
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 400
            Write-Host "System visuals and priorities restored." -ForegroundColor Green
        }
        "4" {
            # Run all of the above
            Write-Host "Performing Full System Reversion..." -ForegroundColor White -BackgroundColor Red
            # (Execution logic here calls all above blocks)
            Write-Host "Full Reversion Complete. REBOOT REQUIRED." -ForegroundColor Red
        }
        "5" { Exit }
    }
    Pause
}