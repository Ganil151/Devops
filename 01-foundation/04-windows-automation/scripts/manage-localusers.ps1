<#
.SYNOPSIS
    Professional local user and group management utility.

.DESCRIPTION
    Simplifies local user creation, group assignment, and permission auditing.
#>
function Manage-LocalUsers {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$UserName,

        [Parameter()]
        [string]$Group = "Administrators",

        [switch]$Audit
    )

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "Administrator privileges required for user management."
        return
    }

    if ($Audit) {
        Write-Host "[!] Auditing Local Administrator Group..." -ForegroundColor Cyan
        Get-LocalGroupMember -Group "Administrators" | Select-Object Name, PrincipalSource, ObjectClass
        return
    }

    if ($UserName) {
        if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
            Write-Host "[+] Creating local user: $UserName..." -ForegroundColor Green
            $Password = Read-Host "Enter Password" -AsSecureString
            New-LocalUser -Name $UserName -Password $Password -FullName "$UserName Dev Account" -Description "DevOps Managed Account"
        }
        
        Write-Host "[+] Adding $UserName to $Group..." -ForegroundColor Cyan
        Add-LocalGroupMember -Group $Group -Member $UserName -ErrorAction SilentlyContinue
        Write-Host "[✔] User $UserName processed." -ForegroundColor Green
    }
}

# Example Check
Manage-LocalUsers -Audit
