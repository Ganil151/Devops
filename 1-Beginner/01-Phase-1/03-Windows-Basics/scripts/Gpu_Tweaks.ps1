# --- Run as Admin Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Administrator privileges required for GPU and System tweaks."
    Pause; Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Magenta
    Write-Host "    WIN 11 GPU & SYSTEM PERFORMANCE HACKS     " -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor Magenta
    Write-Host " 1. UNLOCK: All GPU Power Settings            "
    Write-Host " 2. ENABLE: Hardware Accelerated GPU Scheduling"
    Write-Host " 3. TWEAK: Win32 Priority (High IDE Response) "
    Write-Host " 4. DISABLE: Driver Power Management (Latency)"
    Write-Host " 5. Exit                                     "
    Write-Host "==============================================" -ForegroundColor Magenta
}

Show-Menu
$choice = Read-Host "Select an option [1-5]"

switch ($choice) {
    "1" {
        Write-Host "Unlocking GPU Power Subgroup..." -ForegroundColor Green
        # Subgroup for Graphics: 633bc23d-a567-4614-b1ec-16c80c0570b8
        powercfg -attributes 633bc23d-a567-4614-b1ec-16c80c0570b8 -ATTRIB_HIDE
        # GPU Power Level: d0ef203d-8153-4819-8664-968940428d06
        powercfg -attributes 633bc23d-a567-4614-b1ec-16c80c0570b8 d0ef203d-8153-4819-8664-968940428d06 -ATTRIB_HIDE
    }
    "2" {
        Write-Host "Enabling HAGS (Hardware Accelerated GPU Scheduling)..." -ForegroundColor Cyan
        $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        Set-ItemProperty -Path $registryPath -Name "HwSchMode" -Value 2
        Write-Host "Requires RESTART to take effect." -ForegroundColor Yellow
    }
    "3" {
        Write-Host "Setting Win32 Priority Separation to 38 (0x26)..." -ForegroundColor Green
        # 38 (Dec) / 26 (Hex) gives longer, variable time-slices to foreground apps (like VS Code)
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38
    }
    "4" {
        Write-Host "Disabling PCIe Link State Power Management..." -ForegroundColor Red
        $activeScheme = (powercfg -getactivescheme).Split(' ')[3]
        # PCIe Subgroup: ee12f506-d177-44da-99c0-ad86a7408f92
        # Link State: 6618b965-7354-4ebd-9908-da3003056223
        # 0 = Off (Performance)
        powercfg -setacvalueindex $activeScheme ee12f506-d177-44da-99c0-ad86a7408f92 6618b965-7354-4ebd-9908-da3003056223 0
        powercfg -setactive $activeScheme
    }
    "5" { Exit }
}
Pause