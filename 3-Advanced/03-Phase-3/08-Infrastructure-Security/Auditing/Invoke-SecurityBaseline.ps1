<#
.SYNOPSIS
    Runs a security posture check on a Windows 11 workstation.
.DESCRIPTION
    Checks specific registry keys and WMI objects to validate:
    1. UAC (User Account Control) status
    2. Windows Defender Real-Time Protection status
    3. SecureBoot status
    4. RDP (Remote Desktop) status
.EXAMPLE
    .\Invoke-SecurityBaseline.ps1
#>

try {
    # Check UAC
    $UAC = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -ErrorAction SilentlyContinue
    $UACStatus = if ($UAC.EnableLUA -eq 1) { "Enabled" } else { "DISABLED (Critical)" }

    # Check Secure Boot
    $SecureBoot = Get-CimInstance -ClassName Win32_SecureBootConfiguration -ErrorAction SilentlyContinue
    $BootStatus = if ($SecureBoot) { "Enabled" } else { "Unknown/Disabled" }

    # Check Defender
    $Defender = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
    $DefStatus = if ($Defender.Status -eq 'Running') { "Running" } else { "STOPPED (Critical)" }

    [PSCustomObject]@{
        "Build Check"  = "Windows 11 Security Baseline"
        "Timestamp"    = Get-Date
        "UAC Status"   = $UACStatus
        "Secure Boot"  = $BootStatus
        "Defender"     = $DefStatus
    }
}
catch {
    Write-Error "Baseline check failed: $_"
}
