<#
.SYNOPSIS
    Interactively removes entries from the User PATH environment variable.
#>

# 1. Scope (Defaulting to User is safer and does not require Admin)
$targetScope = "User"
$oldPath = [Environment]::GetEnvironmentVariable("Path", $targetScope)

if ([string]::IsNullOrWhiteSpace($oldPath)) {
    Write-Error "No PATH variable found for scope '$targetScope'."
    exit 1
}

$pathEntries = $oldPath -split ';' | Where-Object { $_.Trim() -ne '' }

# 2. List the variables
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " Current User PATH Entries" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
for ($i = 0; $i -lt $pathEntries.Count; $i++) {
    Write-Host ("[{0,3}] {1}" -f ($i + 1), $pathEntries[$i])
}

# 3. Prompt and Validate
$selection = Read-Host "`nEnter index numbers to remove (e.g. 1,4,7)"
$rawIndices = ($selection -split ',').Trim() | Where-Object { $_ -match '^\d+$' }
$indicesToRemove = $rawIndices | ForEach-Object { [int]$_ - 1 } | Sort-Object -Unique

if ($indicesToRemove.Count -eq 0) {
    Write-Host "No valid indices provided. Exiting." -ForegroundColor Red; exit
}

# 4. Filter
$newPathEntries = New-Object System.Collections.Generic.List[string]
$removedEntries = New-Object System.Collections.Generic.List[string]

for ($i = 0; $i -lt $pathEntries.Count; $i++) {
    if ($indicesToRemove -contains $i) { $removedEntries.Add($pathEntries[$i]) }
    else { $newPathEntries.Add($pathEntries[$i]) }
}

$newPath = $newPathEntries -join ';'

# 5. Confirm
Write-Host "`nRemoving these entries:" -ForegroundColor Magenta
$removedEntries | ForEach-Object { Write-Host "  [-] $_" -ForegroundColor Red }

if ((Read-Host "`nProceed with registry update? (Y/N)") -ne 'Y') { exit }

# 6. Safe Update
try {
    [Environment]::SetEnvironmentVariable("Path", $newPath, $targetScope)
    Write-Host "[+] Successfully updated registry." -ForegroundColor Green

    # Refresh current session (Merge User + Machine)
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $env:Path = "$newPath;$machinePath"
} catch {
    Write-Error "Failed: $_"
}

# 7. Verification
Write-Host "`nVerification: New length is $($newPath.Length) chars." -ForegroundColor Cyan
