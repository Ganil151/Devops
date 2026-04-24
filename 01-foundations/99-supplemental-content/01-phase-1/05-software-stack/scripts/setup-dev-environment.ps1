<#
.SYNOPSIS
    Automated Development Environment Setup for Windows.

.DESCRIPTION
    Bootstraps a complete DevOps development environment on Windows using Winget.
    Installs Git, Node.js, Python, VS Code, Docker, and configures key settings.

.PARAMETER Minimal
    Install only Git, VS Code, and Python.

.EXAMPLE
    .\setup-dev-environment.ps1
    Install full stack.

.NOTES
    Author: Senior DevOps Engineer
    Version: 1.0 (Golden Standard)
#>

[CmdletBinding()]
param(
    [switch]$Minimal
)

#Requires -RunAsAdministrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DEV ENVIRONMENT BOOTSTRAP" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan

# 1. Check Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget is not installed. Please update Windows 10/11."
    exit 1
}

$packages = @(
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "Python.Python.3.11"
)

if (-not $Minimal) {
    $packages += @(
        "OpenJS.NodeJS",
        "Docker.DockerDesktop",
        "Microsoft.PowerShell",
        "Hashicorp.Terraform",
        "Starship.Starship"
    )
}

# 2. Install Packages
foreach ($id in $packages) {
    Write-Host "`nInstalling $id..." -ForegroundColor Yellow
    winget install --id $id -e --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Success." -ForegroundColor Green
    } else {
        Write-Warning "Failed to install $id or already installed."
    }
}

# 3. Configure Git (Interactive)
Write-Host "`nConfiguring Git..." -ForegroundColor Cyan
if (-not (git config --global user.name)) {
    $name = Read-Host "Enter your Git Name"
    $email = Read-Host "Enter your Git Email"
    git config --global user.name "$name"
    git config --global user.email "$email"
    git config --global core.autocrlf false
    Write-Host "Git configured." -ForegroundColor Green
} else {
    Write-Host "Git already configured." -ForegroundColor Green
}

# 4. VS Code Extensions
Write-Host "`nInstalling VS Code Extensions..." -ForegroundColor Cyan
$extensions = @(
    "ms-python.python",
    "ms-vscode.powershell",
    "esbenp.prettier-vscode",
    "yzhang.markdown-all-in-one"
)

foreach ($ext in $extensions) {
    code --install-extension $ext --force
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   SETUP COMPLETE" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Please restart your terminal." -ForegroundColor Yellow
