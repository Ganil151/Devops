# PurgeApp.ps1 - Requires Administrative Privileges
param (
    [Parameter(Mandatory=$true)]
    [string]$AppName
)

# 1. Search for the app to get the exact ID/Name
Write-Host "Searching for: $AppName..." -ForegroundColor Cyan
$App = winget list --name $AppName | Select-Object -Skip 2

if ($null -eq $App) {
    Write-Error "Could not find an application matching '$AppName'. Please check the spelling."
    return
}

# 2. Uninstall via Winget
Write-Host "Starting uninstallation..." -ForegroundColor Yellow
winget uninstall --name $AppName --silent

# Check if the uninstallation was successful
if ($LASTEXITCODE -ne 0) {
    Write-Error "Winget uninstall failed for '$AppName'. The application may still be installed. Aborting cleanup."
    return
} else {
    Write-Host "Uninstallation of '$AppName' was successful." -ForegroundColor Green
}

# 3. Define residue paths
# We use common patterns for Adobe and others
$FoldersToClean = @(
    "$env:ProgramFiles\$AppName",
    "$env:ProgramFiles(x86)\$AppName",
    "$env:AppData\$AppName",
    "$env:LocalAppData\$AppName",
    "C:\ProgramData\$AppName"
)

# 4. Clean Folders
Write-Host "Scrubbing leftover directories..." -ForegroundColor Cyan
foreach ($Path in $FoldersToClean) {
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Deleted: $Path" -ForegroundColor Green
    }
}

# 5. Clean Registry (Software Keys)
Write-Host "Cleaning Registry keys..." -ForegroundColor Cyan
$RegPaths = @(
    "HKCU:\Software\$AppName",
    "HKLM:\Software\$AppName",
    "HKLM:\Software\WOW6432Node\$AppName"
)

foreach ($RegPath in $RegPaths) {
    if (Test-Path $RegPath) {
        Remove-Item -Path $RegPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Removed Registry Key: $RegPath" -ForegroundColor Green
    }
}

Write-Host "Purge of $AppName complete!" -ForegroundColor White -BackgroundColor DarkGreen