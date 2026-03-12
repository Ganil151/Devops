<#
.SYNOPSIS
    Installs and configures Windows Subsystem for Linux (WSL) with a distribution selector.
.DESCRIPTION
    This script checks for admin privileges, enables required Windows features,
    presents a menu of available Linux distributions, installs the selected one,
    and configures WSL 2 as the default version.
.NOTES
    Requires: PowerShell 5.1+, Windows 10/11, Administrator Privileges.
#>

# Ensure Script Stops on Error
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -----------------------------------------------------------------------------
# Color Helper Functions
# -----------------------------------------------------------------------------
function Write-LogInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-LogWarning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-LogError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# -----------------------------------------------------------------------------
# 1. Administrator Check & Elevation
# -----------------------------------------------------------------------------
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-LogWarning "This script requires Administrator privileges."
    Write-LogInfo "Attempting to restart as Administrator..."
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
    catch {
        Write-LogError "Failed to elevate privileges. Please run this script from an Admin PowerShell window."
        exit 1
    }
}

# -----------------------------------------------------------------------------
# 2. Prerequisite Checks
# -----------------------------------------------------------------------------
Write-LogInfo "Checking WSL availability..."

try {
    $wslCheck = wsl --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-LogWarning "WSL command not found or not functional. Running 'wsl --install' to enable features."
        Write-LogInfo "This may require a reboot. If prompted, please reboot and run this script again."
        
        # Attempt to install core WSL features
        wsl --install --no-distribution
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to enable WSL optional features."
        }
        Write-LogSuccess "WSL features enabled."
    }
    else {
        Write-LogSuccess "WSL is already available."
    }
}
catch {
    Write-LogError "Error checking WSL status: $_"
    exit 1
}

# -----------------------------------------------------------------------------
# 3. Distribution List (Based on User Provided List)
# -----------------------------------------------------------------------------
$distros = @(
    @{Name="Ubuntu"; Friendly="Ubuntu"},
    @{Name="Ubuntu-24.04"; Friendly="Ubuntu 24.04 LTS"},
    @{Name="openSUSE-Tumbleweed"; Friendly="openSUSE Tumbleweed"},
    @{Name="openSUSE-Leap-16.0"; Friendly="openSUSE Leap 16.0"},
    @{Name="SUSE-Linux-Enterprise-15-SP7"; Friendly="SUSE Linux Enterprise 15 SP7"},
    @{Name="SUSE-Linux-Enterprise-16.0"; Friendly="SUSE Linux Enterprise 16.0"},
    @{Name="kali-linux"; Friendly="Kali Linux Rolling"},
    @{Name="Debian"; Friendly="Debian GNU/Linux"},
    @{Name="AlmaLinux-8"; Friendly="AlmaLinux OS 8"},
    @{Name="AlmaLinux-9"; Friendly="AlmaLinux OS 9"},
    @{Name="AlmaLinux-Kitten-10"; Friendly="AlmaLinux OS Kitten 10"},
    @{Name="AlmaLinux-10"; Friendly="AlmaLinux OS 10"},
    @{Name="archlinux"; Friendly="Arch Linux"},
    @{Name="FedoraLinux-43"; Friendly="Fedora Linux 43"},
    @{Name="FedoraLinux-42"; Friendly="Fedora Linux 42"},
    @{Name="eLxr"; Friendly="eLxr 12.12.0.0 GNU/Linux"},
    @{Name="Ubuntu-20.04"; Friendly="Ubuntu 20.04 LTS"},
    @{Name="Ubuntu-22.04"; Friendly="Ubuntu 22.04 LTS"},
    @{Name="OracleLinux_7_9"; Friendly="Oracle Linux 7.9"},
    @{Name="OracleLinux_8_10"; Friendly="Oracle Linux 8.10"},
    @{Name="OracleLinux_9_5"; Friendly="Oracle Linux 9.5"},
    @{Name="openSUSE-Leap-15.6"; Friendly="openSUSE Leap 15.6"},
    @{Name="SUSE-Linux-Enterprise-15-SP6"; Friendly="SUSE Linux Enterprise 15 SP6"}
)

# -----------------------------------------------------------------------------
# 4. Menu Selection
# -----------------------------------------------------------------------------
function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor DarkGray
    Write-Host "       WSL Distribution Installer       " -ForegroundColor DarkGray
    Write-Host "========================================" -ForegroundColor DarkGray
    Write-Host ""
    
    for ($i = 0; $i -lt $distros.Count; $i++) {
        $num = $i + 1
        $name = $distros[$i].Name
        $friendly = $distros[$i].Friendly
        Write-Host "  [$num] $friendly ($name)"
    }
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor Red
    Write-Host ""
}

$selection = -1
while ($selection -lt 0 -or $selection -gt $distros.Count) {
    Show-Menu
    $inputVal = Read-Host "Select a distribution number to install"
    
    if (-not ([int]::TryParse($inputVal, [ref]$selection))) {
        Write-LogWarning "Invalid input. Please enter a number."
        Start-Sleep -Seconds 1
        continue
    }

    if ($selection -eq 0) {
        Write-LogInfo "Exiting script."
        exit 0
    }
    
    if ($selection -lt 1 -or $selection -gt $distros.Count) {
        Write-LogWarning "Selection out of range. Please choose between 0 and $($distros.Count)."
        Start-Sleep -Seconds 1
    }
}

$selectedDistro = $distros[$selection - 1]
Write-LogInfo "You selected: $($selectedDistro.Friendly) ($($selectedDistro.Name))"

# -----------------------------------------------------------------------------
# 5. Installation Process
# -----------------------------------------------------------------------------
try {
    Write-LogInfo "Starting installation of $($selectedDistro.Name)..."
    Write-LogWarning "Do not close this window until the installation completes."
    
    # Run WSL Install for specific distro
    # Note: wsl --install -d <Distro>
    wsl --install -d $selectedDistro.Name
    
    if ($LASTEXITCODE -ne 0) {
        throw "WSL installation command failed with exit code $LASTEXITCODE"
    }
    
    Write-LogSuccess "Installation command completed."
}
catch {
    Write-LogError "Installation failed: $_"
    Write-LogWarning "Sometimes WSL requires a reboot after enabling features. If this persists, reboot and try again."
    exit 1
}

# -----------------------------------------------------------------------------
# 6. Configuration (WSL 2 Default)
# -----------------------------------------------------------------------------
Write-LogInfo "Configuring WSL defaults..."

try {
    # Set WSL 2 as default version
    wsl --set-default-version 2
    if ($LASTEXITCODE -ne 0) {
        Write-LogWarning "Could not set default version to 2. Virtualization might be disabled in BIOS."
    }
    else {
        Write-LogSuccess "WSL 2 set as default backend."
    }

    # Set the newly installed distro as default (Optional, but convenient)
    Write-LogInfo "Setting $($selectedDistro.Name) as default distribution..."
    wsl --set-default $selectedDistro.Name
    if ($LASTEXITCODE -ne 0) {
        Write-LogWarning "Could not set default distribution."
    }
    else {
        Write-LogSuccess "$($selectedDistro.Name) is now the default distribution."
    }
}
catch {
    Write-LogError "Configuration step failed: $_"
}

# -----------------------------------------------------------------------------
# 7. Final Verification & Cleanup
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "========================================" -ForegroundColor DarkGray
Write-LogSuccess "WSL Setup Complete!"
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host ""
Write-LogInfo "To finish the setup, launch the distribution from the Start Menu or type:"
Write-Host "  wsl -d $($selectedDistro.Name)" -ForegroundColor White
Write-Host ""
Write-LogWarning "The first launch will require you to create a UNIX username and password."
Write-Host ""

# List installed distros
Write-LogInfo "Currently installed distributions:"
wsl --list --verbose