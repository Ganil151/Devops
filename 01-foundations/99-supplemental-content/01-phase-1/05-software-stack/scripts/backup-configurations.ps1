<#
.SYNOPSIS
    Configuration Backup Tool.

.DESCRIPTION
    Backs up critical developer configurations (Git, SSH, VS Code) to a secure archive.

.PARAMETER BackupDir
    Destination directory for backup.

.EXAMPLE
    .\backup-configurations.ps1
    Backup to default location.

.NOTES
    Author: Senior DevOps Engineer
    Version: 1.0 (Golden Standard)
#>

[CmdletBinding()]
param(
    [string]$BackupDir = "$HOME\DevOps_Backups"
)

$date = Get-Date -Format "yyyyMMdd_HHmmss"
$targetDir = "$BackupDir\ConfigBackup_$date"

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

Write-Host "Starting Backup to: $targetDir" -ForegroundColor Cyan

# 1. Git Config
Write-Host "Backing up Git configuration..." -ForegroundColor Yellow
if (Test-Path "$HOME\.gitconfig") {
    Copy-Item "$HOME\.gitconfig" "$targetDir\"
    Write-Host " [OK] .gitconfig" -ForegroundColor Green
}

# 2. SSH Keys (Public only for safety default, private optional)
Write-Host "Backing up SSH Public Keys..." -ForegroundColor Yellow
if (Test-Path "$HOME\.ssh") {
    New-Item -ItemType Directory -Force -Path "$targetDir\.ssh" | Out-Null
    Get-ChildItem "$HOME\.ssh\*.pub" | Copy-Item -Destination "$targetDir\.ssh\"
    Write-Host " [OK] SSH Public Keys" -ForegroundColor Green
}

# 3. VS Code Settings
Write-Host "Backing up VS Code Settings..." -ForegroundColor Yellow
$vscodePath = "$env:APPDATA\Code\User\settings.json"
if (Test-Path $vscodePath) {
    Copy-Item $vscodePath "$targetDir\vscode_settings.json"
    Write-Host " [OK] VS Code Settings" -ForegroundColor Green
}

# 4. Environment Variables
Write-Host "Exporting Environment Variables..." -ForegroundColor Yellow
Get-ChildItem Env: | Select-Object Name, Value | Export-Csv "$targetDir\env_vars.csv"
Write-Host " [OK] Environment Variables" -ForegroundColor Green

# Summary
$zipPath = "$BackupDir\ConfigBackup_$date.zip"
Write-Host "`nCompressing backup..." -ForegroundColor Cyan
Compress-Archive -Path "$targetDir\*" -DestinationPath $zipPath
Remove-Item -Recurse -Force $targetDir

Write-Host "Backup Complete: $zipPath" -ForegroundColor Green
