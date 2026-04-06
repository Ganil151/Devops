# ==============================================================================
# Script Name: Install-AwsCli.ps1
# Description: Installs or updates the AWS CLI v2 on Windows via PowerShell.
# Author: Gemini (inspired by Antigravity AI)
# ==============================================================================

$ErrorActionPreference = "Stop"

# Colors for output
$Green = "Green"
$Blue = "Cyan"

Write-Host ">>> Starting AWS CLI v2 Installation..." -ForegroundColor $Blue

# 1. Define paths
$InstallerUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$DownloadPath = Join-Path $env:TEMP "AWSCLIV2.msi"

# 2. Download the AWS CLI MSI
Write-Host ">>> Downloading AWS CLI v2 installer..." -ForegroundColor $Green
Invoke-WebRequest -Uri $InstallerUrl -OutFile $DownloadPath

# 3. Run the installer
Write-Host ">>> Running installation (MSI)..." -ForegroundColor $Green
# Start-Process waits for completion and handles the update automatically
$InstallerProcess = Start-Process msiexec.exe -ArgumentList "/i `"$DownloadPath`" /quiet /norestart" -Wait -PassThru

if ($InstallerProcess.ExitCode -ne 0) {
    Write-Error "Installation failed with exit code $($InstallerProcess.ExitCode)"
}

# 4. Cleanup
Write-Host ">>> Cleaning up temporary files..." -ForegroundColor $Green
Remove-Item $DownloadPath -Force

# 5. Verify installation
# Note: PowerShell might need to refresh its env path to see the new 'aws' command
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host ">>> AWS CLI installed successfully!" -ForegroundColor $Blue
aws --version
