# --- Admin Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! Please restart this script as Administrator !!!"
    Pause; Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "      WINDOWS 11 DEVELOPER MASTER OPTIMIZER (2026)      " -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host " 1. CPU: Unlock God Mode & Set Best Performance Overlay  "
    Write-Host " 2. GPU: Enable HAGS & Disable PCIe Power Savings        "
    Write-Host " 3. NET: TCP Autotuning, Nagle Disable & Cloudflare DNS  "
    Write-Host " 4. DISK: Disable NTFS LastAccess & Enable Large Cache   "
    Write-Host " 5. SYSTEM: Kill Telemetry & Instant Menu Speed          "
    Write-Host " 6. ALL: Run All Optimizations (Full House)              "
    Write-Host " 7. Exit                                                 "
    Write-Host "=========================================================" -ForegroundColor Cyan
}

# --- Shared Variables ---
$activeScheme = (powercfg -getactivescheme).Split(' ')[3]

# --- Functions ---
function Optimize-CPU {
    Write-Host "[+] Unlocking Hidden CPU Attributes..." -ForegroundColor Green
    powercfg -attributes SUB_PROCESSOR -ATTRIB_HIDE
    $settings = Get-CimInstance -Namespace root\cimv2\power -Class Win32_PowerSetting | Where-Object { $_.InstanceID -match "SUB_PROCESSOR" }
    foreach ($s in $settings) {
        $guid = ($s.InstanceID -split '\\')[1]
        powercfg -attributes SUB_PROCESSOR $guid -ATTRIB_HIDE
    }
    # Force Win11 Overlay to Best Performance
    powercfg -setacvalueindex $activeScheme fea34d30-22c7-4c07-889e-29f1797c2106 be337238-0d82-4146-a960-4f3749d470c7 2
    powercfg -setactive $activeScheme
}

function Optimize-GPU {
    Write-Host "[+] Optimizing GPU & PCIe..." -ForegroundColor Magenta
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2
    powercfg -setacvalueindex $activeScheme ee12f506-d177-44da-99c0-ad86a7408f92 6618b965-7354-4ebd-9908-da3003056223 0
    powercfg -setactive $activeScheme
}

function Optimize-Net {
    Write-Host "[+] Enhancing Network Stack & DNS..." -ForegroundColor Blue
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global dca=enabled
    netsh int tcp set global netdma=enabled
    # Smart DNS for Ethernet & Wi-Fi
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($a in $adapters) {
        Set-DnsClientServerAddress -InterfaceAlias $a.Name -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue
    }
    ipconfig /flushdns
}

function Optimize-Disk {
    Write-Host "[+] Tuning NTFS for High-Volume I/O..." -ForegroundColor Yellow
    fsutil behavior set disablelastaccess 1
    fsutil behavior set memoryusage 2
    # Disable Hibernation to save space and reduce disk wear
    powercfg -h off
}

function Optimize-System {
    Write-Host "[+] Stripping Telemetry & Speeding Up UI..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    # Disable VBS/Memory Integrity (Impacts CPU performance)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0
}

# --- Main Logic ---
while($true) {
    Show-Menu
    $choice = Read-Host "Selection"
    switch ($choice) {
        "1" { Optimize-CPU }
        "2" { Optimize-GPU }
        "3" { Optimize-Net }
        "4" { Optimize-Disk }
        "5" { Optimize-System }
        "6" { Optimize-CPU; Optimize-GPU; Optimize-Net; Optimize-Disk; Optimize-System }
        "7" { Exit }
    }
    Write-Host "`nOptimization Complete!" -ForegroundColor Green
    Pause
}