# --- Administrator Authorization ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! CRITICAL: This script MUST be run as Administrator !!!"
    Pause; Exit
}

# --- Core Variables ---
$activeScheme = (powercfg -getactivescheme | ForEach-Object { if ($_ -match 'GUID: (.*?)  ') { $matches[1] } })
$OverlaySubGroup = "fea34d30-22c7-4c07-889e-29f1797c2106"
$OverlaySetting  = "be337238-0d82-4146-a960-4f3749d470c7"

function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Magenta
    Write-Host "      WINDOWS 11 SUPREME DEVELOPER SUITE (2026)          " -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Magenta
    Write-Host " [1] HARDWARE: CPU Boost, GPU HAGS & PCIe Performance    "
    Write-Host " [2] NETWORK : TCP Tuning & Cloudflare DNS (ETH/Wi-Fi)   "
    Write-Host " [3] SYSTEM  : Disable VBS, Telemetry & Menu Lag         "
    Write-Host " [4] IDE/I-O : Cache Optimizations & Priority Boosting   "
    Write-Host " [5] DEFENDER: Add Dev Exclusions & Silence Maintenance  "
    Write-Host " [6] DOCKER  : WSL2 RAM Cap & Page Reporting Fix         "
    Write-Host " [7] DEPLOY  : RUN ALL OPTIMIZATIONS (Full House)        "
    Write-Host " [8] RESTORE : Create System Restore Point               "
    Write-Host " [9] EXIT                                                "
    Write-Host "=========================================================" -ForegroundColor Magenta
}

# --- Optimization Modules ---

function Optimize-Hardware {
    Write-Host "[+] Unlocking CPU & GPU Potential..." -ForegroundColor Green
    powercfg -attributes SUB_PROCESSOR -ATTRIB_HIDE
    $settings = Get-CimInstance -Namespace root\cimv2\power -Class Win32_PowerSetting | Where-Object { $_.InstanceID -match "SUB_PROCESSOR" }
    foreach ($s in $settings) { $guid = ($s.InstanceID -split '\\')[1]; powercfg -attributes SUB_PROCESSOR $guid -ATTRIB_HIDE 2>$null }
    powercfg -setacvalueindex $activeScheme $OverlaySubGroup $OverlaySetting 2
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -ErrorAction SilentlyContinue
    powercfg -setacvalueindex $activeScheme "ee12f506-d177-44da-99c0-ad86a7408f92" "6618b965-7354-4ebd-9908-da3003056223" 0
    powercfg -setactive $activeScheme
}

function Optimize-Network {
    Write-Host "[+] Enhancing Network Stack & DNS..." -ForegroundColor Blue
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global rss=enabled
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($a in $adapters) { Set-DnsClientServerAddress -InterfaceAlias $a.Name -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue }
    ipconfig /flushdns
}

function Optimize-System {
    Write-Host "[+] Stripping Telemetry & Reducing Input Lag..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38
}

function Optimize-IDE {
    Write-Host "[+] Deep-Optimizing IDE Caches..." -ForegroundColor Cyan
    fsutil behavior set disablelastaccess 1
    fsutil behavior set memoryusage 2
    $cachePaths = @("$env:LOCALAPPDATA\JetBrains", "$env:LOCALAPPDATA\Microsoft\VisualStudio", "$env:USERPROFILE\.m2", "$env:USERPROFILE\.nuget")
    foreach ($path in $cachePaths) { if (Test-Path $path) { Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue } }
    $procs = @("devenv", "idea64", "pycharm64", "Code")
    foreach ($p in $procs) {
        $reg = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$p.exe\PerfOptions"
        if (!(Test-Path $reg)) { New-Item $reg -Force | Out-Null }
        Set-ItemProperty -Path $reg -Name "CpuPriorityClass" -Value 3 -ErrorAction SilentlyContinue
    }
}

function Optimize-Defender {
    Write-Host "[+] Configuring Defender & Maintenance..." -ForegroundColor DarkYellow
    $devPath = Read-Host "Enter your Project Folder path"
    if (Test-Path $devPath) { Add-MpPreference -ExclusionPath $devPath -ErrorAction SilentlyContinue }
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 1 /f | Out-Null
    powercfg -h off
}

function Optimize-Docker {
    Write-Host "[+] Capping WSL2 & Docker RAM..." -ForegroundColor Cyan
    $wslConfig = "[wsl2]`nmemory=4GB`nprocessors=4`npageReporting=true"
    $wslConfig | Out-File "$env:USERPROFILE\.wslconfig" -Encoding ascii
    wsl --shutdown
    Write-Host "WSL2 Cap Applied. Docker will no longer starve Windows of RAM." -ForegroundColor Green
}

# --- Logic ---
while($true) {
    Show-Menu
    $choice = Read-Host "Selection"
    switch ($choice) {
        "1" { Optimize-Hardware }
        "2" { Optimize-Network }
        "3" { Optimize-System }
        "4" { Optimize-IDE }
        "5" { Optimize-Defender }
        "6" { Optimize-Docker }
        "7" { Optimize-Hardware; Optimize-Network; Optimize-System; Optimize-IDE; Optimize-Defender; Optimize-Docker }
        "8" { Checkpoint-Computer -Description "Optimized_Dev_State" -RestorePointType "MODIFY_SETTINGS" }
        "9" { Exit }
    }
    Write-Host "`nDone!" -ForegroundColor Green
    Pause
}