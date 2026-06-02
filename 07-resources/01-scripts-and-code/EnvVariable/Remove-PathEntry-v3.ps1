<#
.SYNOPSIS
    Advanced Windows User PATH Manager.
    Features: List, Remove, Add, Alter, and Deduplicate.
#>

$targetScope = "User"
$oldPath = [Environment]::GetEnvironmentVariable("Path", $targetScope)

# Get unique entries to prevent initial clutter, ensure it's strictly an array using @()
$pathEntries = @($oldPath -split ';' | Where-Object { $_.Trim() -ne '' } | Select-Object -Unique)

function Save-Path {
    param($entries)
    # Join entries back into a single semicolon-separated string
    $newPath = ($entries -join ';').TrimEnd(';')
    [Environment]::SetEnvironmentVariable("Path", $newPath, $targetScope)

    # Update current session immediately
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $env:Path = "$newPath;$machinePath"
    Write-Host "[+] Path successfully updated in Registry and session." -ForegroundColor Green
}

# 1. Main Menu
Write-Host "`n--- Windows Path Manager ---" -ForegroundColor Cyan
Write-Host "1) List & Remove"
Write-Host "2) Add New Entry"
Write-Host "3) Alter Existing Entry"
Write-Host "4) Clean Duplicates & Empty Entries"
$choice = Read-Host "Select an option"

switch ($choice) {
    "1" { # Remove
        # FIX: Use ::new() with a strongly-typed string array to prevent unrolling issues
        $pathList = [System.Collections.Generic.List[string]]::new([string[]]$pathEntries)

        for ($i = 0; $i -lt $pathList.Count; $i++) {
            Write-Host "[$($i + 1)] $($pathList[$i])"
        }

        $idx = (Read-Host "Enter index to remove") -as [int]
        if ($idx -gt 0 -and $idx -le $pathList.Count) {
            $removed = $pathList[$idx - 1]
            $pathList.RemoveAt($idx - 1)
            Write-Host "Removing: $removed" -ForegroundColor Yellow
            Save-Path $pathList
        } else {
            Write-Warning "Invalid index."
        }
    }
    "2" { # Add
        $newEntry = Read-Host "Enter the full path to add"
        if (Test-Path $newEntry) {
            $pathList = [System.Collections.Generic.List[string]]::new([string[]]$pathEntries)
            $pathList.Add($newEntry)
            Save-Path $pathList
        } else {
            Write-Warning "Path does not exist!"
        }
    }
    "3" { # Alter
        for ($i = 0; $i -lt $pathEntries.Count; $i++) {
            Write-Host "[$($i + 1)] $($pathEntries[$i])"
        }
        $idx = (Read-Host "Enter index to edit") -as [int]
        if ($idx -gt 0 -and $idx -le $pathEntries.Count) {
            $newVal = Read-Host "Enter new path for index $idx"
            $pathList = [System.Collections.Generic.List[string]]::new([string[]]$pathEntries)
            $pathList[$idx - 1] = $newVal
            Save-Path $pathList
        } else {
            Write-Warning "Invalid index."
        }
    }
    "4" { # Deduplicate & Clean
        $uniquePaths = @($pathEntries | Select-Object -Unique)
        $diff = $pathEntries.Count - $uniquePaths.Count
        Write-Host "Found and removed $diff duplicates/empty entries." -ForegroundColor Yellow
        Save-Path $uniquePaths
    }
    default {
        Write-Warning "Invalid option selected."
    }
}
