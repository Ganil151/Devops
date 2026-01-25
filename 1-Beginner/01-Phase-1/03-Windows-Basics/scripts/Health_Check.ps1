# --- Admin Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! Please run as Administrator to access System Diagnostics !!!"
    Pause; Exit
}

Clear-Host
Write-Host "=========================================================" -ForegroundColor White
Write-Host "        WINDOWS 11 PERFORMANCE & HEALTH AUDIT          " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor White

function Get-Status {
    param($Condition)
    if ($Condition) { return "OPTIMIZED" } else { return "FACTORY/STOCK" }
}

# 1. Check Power Overlay
$OverlaySetting = powercfg -getactivescheme
$PowerMode = "Unknown"
if ($OverlaySetting -match "Ultimate") { $PowerMode = "Ultimate" }
elseif ($OverlaySetting -match "High") { $PowerMode = "High Performance" }
else { $PowerMode = "Balanced/Other" }

# 2. Check VBS Status
$VBS = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction SilentlyContinue
$VBSStatus = if ($VBS.Enabled -eq 0) { "OFF (Performance Mode)" } else { "ON (Security Mode)" }

# 3. Check Network AutoTuning
$AutoTune = (netsh int tcp show global | Select-String "Receive Window Auto-Tuning Level").ToString().Split(":")[1].Trim()

# 4. Check DNS
$DNS = (Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses -ne $null }).ServerAddresses -join ", "

# 5. Check NTFS LastAccess
$LastAccess = (fsutil behavior query disablelastaccess)

# --- DISPLAY RESULTS ---
Write-Host "`n[ POWER ]" -ForegroundColor Yellow
Write-Host "Current Plan: $PowerMode"
Write-Host "Power Overlay: $(Get-Status ($PowerMode -ne "Balanced/Other"))"

Write-Host "`n[ SECURITY vs PERFORMANCE ]" -ForegroundColor Yellow
Write-Host "Memory Integrity (VBS): $VBSStatus"

Write-Host "`n[ NETWORK ]" -ForegroundColor Yellow
Write-Host "TCP Auto-Tuning: $AutoTune"
Write-Host "Active DNS Servers: $DNS"
$DNSStatus = if ($DNS -match "1.1.1.1") { "Cloudflare" } elseif ($DNS -match "8.8.8.8") { "Google" } else { "ISP/Default" }
Write-Host "DNS Provider: $DNSStatus"

Write-Host "`n[ DISK I/O ]" -ForegroundColor Yellow
Write-Host "NTFS LastAccess: $LastAccess"

Write-Host "`n[ VISUALS ]" -ForegroundColor Yellow
$MenuDelay = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay"
Write-Host "Menu Response Delay: $($MenuDelay.MenuShowDelay)ms (Default is 400ms)"

Write-Host "`n=========================================================" -ForegroundColor White
Write-Host "   Audit Complete. Use your Master Script to adjust.     " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor White
Pause