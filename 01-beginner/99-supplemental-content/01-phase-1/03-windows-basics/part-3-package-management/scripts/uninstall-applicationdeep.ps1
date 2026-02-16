<#
.SYNOPSIS
    Uninstalls an application and scrubs all residue folders and registry keys.

.DESCRIPTION
    Uses Winget for the initial uninstallation, then recursively deletes files 
    in ProgramFiles, AppData, and Clean Registry keys.
#>
function Uninstall-ApplicationDeep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$AppName
    )

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "Administrator privileges required to purge applications."
        return
    }

    Write-Host "[!] Purging Application: $AppName" -ForegroundColor Cyan

    # 1. Winget Uninstall
    Write-Host "[+] Attempting silent uninstall via Winget..." -ForegroundColor Gray
    winget uninstall --name $AppName --silent --accept-source-agreements | Out-Null
    
    # 2. Residue Scrubbing
    $Paths = @(
        "$env:ProgramFiles\$AppName",
        "${env:ProgramFiles(x86)}\$AppName",
        "$env:AppData\$AppName",
        "$env:LocalAppData\$AppName",
        "C:\ProgramData\$AppName"
    )

    Write-Host "[+] Scrubbing directory leftovers..." -ForegroundColor Gray
    foreach ($p in $Paths) {
        if (Test-Path $p) {
            Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host " [✔] Removed: $p" -ForegroundColor Green
        }
    }

    # 3. Registry Scrubbing
    $RegKeys = @(
        "HKCU:\Software\$AppName",
        "HKLM:\Software\$AppName",
        "HKLM:\Software\WOW6432Node\$AppName"
    )

    Write-Host "[+] Scrubbing registry keys..." -ForegroundColor Gray
    foreach ($r in $RegKeys) {
        if (Test-Path $r) {
            Remove-Item -Path $r -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host " [✔] Removed Key: $r" -ForegroundColor Green
        }
    }

    Write-Host "[✔] Deep Purge of $AppName Complete." -ForegroundColor Cyan
}

Uninstall-ApplicationDeep -AppName (Read-Host "Enter App Name (e.g., Adobe)")
