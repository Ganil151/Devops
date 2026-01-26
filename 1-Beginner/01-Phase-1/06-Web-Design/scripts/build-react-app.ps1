<#
.SYNOPSIS
    React App Builder and Deployer.

.DESCRIPTION
    Automates dependency installation, production build, and deployment for React apps.

.PARAMETER ProjectPath
    Path to React project.

.PARAMETER BuildPath
    Destination for build artifacts.

.EXAMPLE
    .\build-react-app.ps1 -ProjectPath "C:\Projects\MyApp"
    Build project.

.NOTES
    Author: Senior DevOps Engineer
    Version: 1.0 (Golden Standard)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectPath,
    [string]$BuildPath = "C:\inetpub\wwwroot"
)

$ErrorActionPreference = "Stop"

Write-Host "Reac App Builder" -ForegroundColor Cyan
Write-Host "Path: $ProjectPath"

if (-not (Test-Path "$ProjectPath\package.json")) {
    Write-Error "No package.json found within $ProjectPath"
    exit 1
}

Push-Location $ProjectPath

# 1. Install Dependencies
Write-Host "`n[1] Installing Dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) { throw "npm install failed" }

# 2. Build
Write-Host "`n[2] Building Production Bundle..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) { throw "npm run build failed" }

# 3. Deploy
if (Test-Path "$ProjectPath\build") {
    Write-Host "`n[3] Deploying to $BuildPath..." -ForegroundColor Yellow
    Copy-Item -Recurse -Force "$ProjectPath\build\*" "$BuildPath"
    Write-Host "[SUCCESS] Deployed successfully." -ForegroundColor Green
} else {
    Write-Error "Build folder not found!"
}

Pop-Location
