# --- Administrator Authorization ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! CRITICAL: This script MUST be run as Administrator !!!"
    Pause; Exit
}

$logFile = "$env:USERPROFILE\Documents\Win11_Enhancement_Audit.log"

function Log-Message {
    param ( [string]$Message, [string]$Level = "Info" )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp][$Level] $Message"
    Add-Content -Path $logFile -Value $logEntry
    $color = switch($Level) { "Error" {"Red"} "Warn" {"Yellow"} "Success" {"Green"} Default {"White"} }
    Write-Host $logEntry -ForegroundColor $color
}

function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Magenta
    Write-Host "      WINDOWS 11 SYSTEM INTEGRITY SUITE (2026)          " -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Magenta
    Write-Host " [1] PRIVACY  : Disable Telemetry, Tracking & Ads        "
    Write-Host " [2] SECURITY : Harden Kernel, Network & TLS Protocols   "
    Write-Host " [3] DISK     : WinSxS Cleanup & Re-Trim SSD             "
    Write-Host " [4] NETWORK  : Firewall Shield (Block Telemetry IPs)    "
    Write-Host " [5] ALL      : Run Full Integrity Deployment            "
    Write-Host " [6] LOGS     : View Audit History                       "
    Write-Host " [7] WATCHDOG : Audit for 'Tweak Drift' & Fix Issues     "
    Write-Host " [8] EXIT                                                "
    Write-Host "=========================================================" -ForegroundColor Magenta
}

# --- Shared Optimization Logic ---
function Optimize-Privacy {
    Log-Message "[+] Initiating Privacy Lockdown..." -Level "Info"
    try {
        $paths = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection")
        foreach ($p in $paths) { if (!(Test-Path $p)) { New-Item $p -Force | Out-Null }; Set-ItemProperty -Path $p -Name "AllowTelemetry" -Value 0 }
        $advPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        if (!(Test-Path $advPath)) { New-Item $advPath -Force | Out-Null }
        Set-ItemProperty -Path $advPath -Name "Enabled" -Value 0
        Log-Message "[✔] Privacy Lockdown Complete." -Level "Success"
    } catch { Log-Message "[-] Privacy Error: $_" -Level "Error" }
}

function Harden-Security {
    Log-Message "[+] Hardening System Security..." -Level "Info"
    try {
        $tlsBase = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
        foreach ($v in @("TLS 1.0", "TLS 1.1")) {
            $cPath = "$tlsBase\$v\Client"; $sPath = "$tlsBase\$v\Server"
            if (!(Test-Path $cPath)) { New-Item $cPath -Force | Out-Null }
            if (!(Test-Path $sPath)) { New-Item $sPath -Force | Out-Null }
            Set-ItemProperty $cPath -Name "Enabled" -Value 0
            Set-ItemProperty $sPath -Name "Enabled" -Value 0
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2
        Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart | Out-Null
        Log-Message "[✔] Security Hardening Complete." -Level "Success"
    } catch { Log-Message "[-] Security Error: $_" -Level "Error" }
}

function Set-NetworkShield {
    Log-Message "[+] Deploying Network Firewall Shield..." -Level "Info"
    try {
        $RuleName = "Block_Windows_Telemetry_Outbound"
        if (!(Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue)) {
            New-NetFirewallRule -DisplayName $RuleName -Direction Outbound -Action Block `
            -RemoteAddress "20.190.128.0/18", "40.126.0.0/18", "52.149.21.11" | Out-Null
        }
        Log-Message "[✔] Network Shield Active." -Level "Success"
    } catch { Log-Message "[-] Network Shield Error: $_" -Level "Error" }
}

# --- Watchdog Logic (The Auditor) ---
function Run-Watchdog {
    Log-Message "[*] Starting System Integrity Audit..." -Level "Info"
    $drift = $false

    # Check Telemetry
    $tele = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
    if ($tele.AllowTelemetry -ne 0) { Log-Message "[!] Drift Detected: Telemetry re-enabled!" -Level "Warn"; $drift = $true }

    # Check Firewall
    if (!(Get-NetFirewallRule -DisplayName "Block_Windows_Telemetry_Outbound" -ErrorAction SilentlyContinue)) { 
        Log-Message "[!] Drift Detected: Firewall Shield missing!" -Level "Warn"; $drift = $true 
    }

    if ($drift) {
        $confirm = Read-Host "Drift detected. Re-apply all optimizations? (Y/N)"
        if ($confirm -eq 'Y') { Optimize-Privacy; Harden-Security; Set-NetworkShield }
    } else {
        Log-Message "[✔] No drift detected. System is secure." -Level "Success"
    }
}

# --- Main Logic ---
while ($true) {
    Show-Menu
    $choice = Read-Host "Select an Option"
    switch ($choice) {
        "1" { Optimize-Privacy }
        "2" { Harden-Security }
        "3" { dism /online /cleanup-image /startcomponentcleanup /resetbase; Optimize-Volume -DriveLetter C -ReTrim }
        "4" { Set-NetworkShield }
        "5" { Optimize-Privacy; Harden-Security; Set-NetworkShield }
        "6" { if (Test-Path $logFile) { Get-Content $logFile | Select-Object -Last 30 } else { Write-Host "No logs yet." } }
        "7" { Run-Watchdog }
        "8" { Exit }
    }
    Write-Host "`nOperation Finished." -ForegroundColor Green
    Pause
}