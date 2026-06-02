<#
.SYNOPSIS
    Interactively removes entries from the User PATH environment variable.
.DESCRIPTION
    This script lists all current User PATH entries, allows the user to select
    which ones to remove via a numbered menu, and safely updates the registry.
    It requires Administrator privileges to run.
#>

# 1. Ensure the script is running with Administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] This script requires Administrator privileges." -ForegroundColor Yellow
    Write-Host "    Attempting to restart as Administrator..." -ForegroundColor Yellow
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    } catch {
        Write-Error "Failed to elevate privileges. Please run PowerShell as Administrator manually."
        exit 1
    }
}

# 2. Get the current User PATH
$targetScope = "User" # Change to "Machine" if you want to edit the System PATH instead
$oldPath = [Environment]::GetEnvironmentVariable("Path", $targetScope)

if ([string]::IsNullOrWhiteSpace($oldPath)) {
    Write-Error "No PATH variable found for scope '$targetScope'."
    exit 1
}

# Split into an array and remove empty entries
$pathEntries = $oldPath -split ';' | Where-Object { $_.Trim() -ne '' }

# 3. List the variables in the path
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " Current PATH Entries ($targetScope Scope)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
for ($i = 0; $i -lt $pathEntries.Count; $i++) {
    Write-Host ("[{0,3}] {1}" -f ($i + 1), $pathEntries[$i])
}
Write-Host "==================================================`n" -ForegroundColor Cyan

# 4. Prompt user to choose which paths to delete
Write-Host "Enter the number(s) of the path(s) you want to remove." -ForegroundColor Yellow
Write-Host "(Example: 3 or 1,4,7)" -ForegroundColor DarkGray
$selection = Read-Host "Selection"

if ([string]::IsNullOrWhiteSpace($selection)) {
    Write-Host "No selection made. Exiting." -ForegroundColor Red
    exit
}

# Parse and validate user input
$indicesToRemove = @()
$hasError = $false

foreach ($item in ($selection -split ',')) {
    $num = $item.Trim()
    if ($num -match '^\d+$') {
        $index = [int]$num - 1
        if ($index -ge 0 -and $index -lt $pathEntries.Count) {
            $indicesToRemove += $index
        } else {
            Write-Warning "Index $num is out of range (1 to $($pathEntries.Count))."
            $hasError = $true
        }
    } else {
        Write-Warning "Invalid input format: '$num'. Please use numbers separated by commas."
        $hasError = $true
    }
}

if ($hasError -or $indicesToRemove.Count -eq 0) {
    Write-Host "Operation cancelled due to invalid input." -ForegroundColor Red
    exit
}

# 5. Remove the selected entries safely using array filtering
$removedEntries = @()
$newPathEntries = @()

for ($i = 0; $i -lt $pathEntries.Count; $i++) {
    if ($indicesToRemove -contains $i) {
        $removedEntries += $pathEntries[$i]
    } else {
        $newPathEntries += $pathEntries[$i]
    }
}

# Rejoin the array (This inherently prevents any double semicolons ;;)
$newPath = $newPathEntries -join ';'

# 6. Confirm before saving to registry
Write-Host "`nYou are about to remove the following entries:" -ForegroundColor Magenta
$removedEntries | ForEach-Object { Write-Host "  [-] $_" -ForegroundColor Red }

$confirm = Read-Host "Are you sure you want to save these changes to the registry? (Y/N)"
if ($confirm -notin @('Y', 'y', 'Yes', 'yes')) {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    exit
}

# 7. Save the cleaned Path back to the User environment
try {
    [Environment]::SetEnvironmentVariable("Path", $newPath, $targetScope)
    Write-Host "`n[+] Successfully updated the $targetScope PATH in the registry." -ForegroundColor Green
} catch {
    Write-Error "Failed to update the registry: $_"
    exit 1
}

# 8. Refresh the current session's environment variable immediately
# Note: $env:Path is a merged view of User and Machine paths.
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$env:Path = "$newPath;$machinePath"

# 9. Verify the result
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " Verification Summary" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Old Path length: $($oldPath.Length) characters"
Write-Host "New Path length: $($newPath.Length) characters"
Write-Host "Entries removed: $($removedEntries.Count)"
Write-Host "Entries remain : $($newPathEntries.Count)"
Write-Host "==================================================`n" -ForegroundColor Cyan

Write-Host "Note: The current PowerShell session has been updated." -ForegroundColor Yellow
Write-Host "You may need to restart other open terminals or apps to see the changes.`n" -ForegroundColor Yellow
