# --- Administrator Authorization ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! CRITICAL: This script requires Administrator privileges !!!"
    Pause; Exit
}

# --- Core GUIDs & Variables ---
$activeScheme = (powercfg -getactivescheme).Split(' ')[3]
$OverlaySubGroup = "fea34d30-22c7-4c07-889e-29f1797c2106"
$OverlaySetting  = "be337238-0d82-4146-a960-4f3749d470c7"

function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Magenta
    Write-Host "      WINDOWS 11 SUPREME OPTIMIZATION SUITE (2026)      " -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Magenta
    Write-Host " [CPU] 1. Unlock All CPU Settings & Set Best Performance "
    Write-Host " [GPU] 2. Enable HAGS & Disable PCIe Power Throttle      "
    Write-Host " [NET] 3. Global TCP Tuning & Cloudflare DNS (ETH/Wi-Fi) "
    Write-Host " [SYS] 4. Disable VBS, Telemetry & Input Lag Visuals     "
    Write-Host " [IO ] 5. Optimize NTFS & Disable LastAccess Writes      "
    Write-Host " [ALL] 6. FULL SYSTEM DEPLOYMENT (All of the above)      "
    Write-Host " [CHK] 7. Health Audit (Check Current Status)            "
    Write-Host " [OFF] 8. Exit                                           "
    Write-Host "=========================================================" -ForegroundColor Magenta
}

# --- Optimization Modules ---

function Set-CPU {
    Write-Host ">>> Unlocking CPU potential..." -ForegroundColor Green
    powercfg -attributes SUB_PROCESSOR -ATTRIB_HIDE
    $settings = Get-CimInstance -Namespace root\cimv2\power -Class Win32_PowerSetting | Where-Object { $_.InstanceID -match "SUB_PROCESSOR" }
    foreach ($s in $settings) { $guid = ($s.InstanceID -split '\\')[1]; powercfg -attributes SUB_PROCESSOR $guid -ATTRIB_HIDE }
    powercfg -setacvalueindex $activeScheme $OverlaySubGroup $OverlaySetting 2
    powercfg -setactive $activeScheme
}

function Set-GPU {
    Write-Host ">>> Reducing GPU Latency..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2
    powercfg -setacvalueindex $activeScheme "ee12f506-d177-44da-99c0-ad86a7408f92" "6618b965-7354-4ebd-9908-da3003056223" 0
    powercfg -setactive $activeScheme
}

function Set-Net {
    Write-Host ">>> Tuning Network for Latency..." -ForegroundColor Blue
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global rss=enabled
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($a in $adapters) { Set-DnsClientServerAddress -InterfaceAlias $a.Name -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue }
    ipconfig /flushdns
}

function Set-System {
    Write-Host ">>> Stripping Bloat & UI Delay..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0
    Get-Service -Name "DiagTrack" | Set-Service -StartupType Disabled -PassThru | Stop-Service -ErrorAction SilentlyContinue
}

function Set-IO {
    Write-Host ">>> Optimizing File System..." -ForegroundColor Green
    fsutil behavior set disablelastaccess 1
    fsutil behavior set memoryusage 2
    powercfg -h off
}

function Run-Audit {
    Write-Host "`n--- QUICK AUDIT ---" -ForegroundColor White
    $VBS = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction SilentlyContinue
    Write-Host "VBS Security: $(if($VBS.Enabled -eq 1){"ON (Protected)"}else{"OFF (Performance)"})"
    Write-Host "DNS: $( (Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.ServerAddresses -ne $null}).ServerAddresses -join ', ' )"
    Write-Host "Hibernation: $(if(Test-Path C:\hiberfil.sys){"ON"}else{"OFF (Space Saved)"})"
}

# --- Main Logic Loop ---
while($true) {
    Show-Menu
    $choice = Read-Host "Select Option"
    switch ($choice) {
        "1" { Set-CPU }
        "2" { Set-GPU }
        "3" { Set-Net }
        "4" { Set-System }
        "5" { Set-IO }
        "6" { Set-CPU; Set-GPU; Set-Net; Set-System; Set-IO }
        "7" { Run-Audit; Pause; continue }
        "8" { Exit }
    }
    Write-Host "`nApplied successfully!" -ForegroundColor Green
    Pause
}