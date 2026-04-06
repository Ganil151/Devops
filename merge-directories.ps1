# PowerShell script to merge duplicate directories
# This will consolidate content from overlapping directories

$ErrorActionPreference = "Stop"
$rootPath = "c:\Users\ganil\Documents\Devops"

function Copy-DirectoryContent {
    param(
        [string]$Source,
        [string]$Destination
    )
    
    if (-not (Test-Path $Source)) {
        Write-Host "  [SKIP] Source not found: $Source" -ForegroundColor Yellow
        return
    }
    
    if (-not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        Write-Host "  [CREATE] $Destination" -ForegroundColor Cyan
    }
    
    # Copy all content from source to destination
    Get-ChildItem -Path $Source -Recurse | ForEach-Object {
        $targetPath = $_.FullName.Replace($Source, $Destination)
        
        if ($_.PSIsContainer) {
            if (-not (Test-Path $targetPath)) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
            }
        } else {
            $targetDir = Split-Path $targetPath -Parent
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            # Only copy if file doesn't exist or is different
            if (-not (Test-Path $targetPath)) {
                Copy-Item -Path $_.FullName -Destination $targetPath -Force
                Write-Host "  [COPY] $($_.Name)" -ForegroundColor Green
            } else {
                # Check if files are different
                $sourceHash = Get-FileHash $_.FullName -Algorithm MD5
                $targetHash = Get-FileHash $targetPath -Algorithm MD5
                if ($sourceHash.Hash -ne $targetHash.Hash) {
                    # Create a duplicate with suffix
                    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($targetPath)
                    $extension = [System.IO.Path]::GetExtension($targetPath)
                    $newPath = "$targetDir\$baseName-duplicate$extension"
                    Copy-Item -Path $_.FullName -Destination $newPath -Force
                    Write-Host "  [DUPLICATE] $($_.Name) -> $baseName-duplicate$extension" -ForegroundColor Magenta
                }
            }
        }
    }
}

Write-Host "=== DevOps Directory Merge ===" -ForegroundColor Cyan
Write-Host "Root: $rootPath`n" -ForegroundColor Cyan

# Step 1: Merge 01-foundation into 01-beginner, then rename to 01-foundations
Write-Host "[1/6] Merging 01-foundation into 01-beginner..." -ForegroundColor Yellow
Copy-DirectoryContent -Source "$rootPath\01-foundation" -Destination "$rootPath\01-beginner"

# Step 2: Merge 02-core-engineering into 02-intermediate
Write-Host "`n[2/6] Merging 02-core-engineering into 02-intermediate..." -ForegroundColor Yellow
Copy-DirectoryContent -Source "$rootPath\02-core-engineering" -Destination "$rootPath\02-intermediate"

# Step 3: Merge 03-career-strategy into 00-career-mastery
Write-Host "`n[3/6] Merging 03-career-strategy into 00-career-mastery..." -ForegroundColor Yellow
Copy-DirectoryContent -Source "$rootPath\03-career-strategy" -Destination "$rootPath\00-career-mastery"

# Step 4: Merge 04-interview-readiness into 00-career-mastery
Write-Host "`n[4/6] Merging 04-interview-readiness into 00-career-mastery..." -ForegroundColor Yellow
Copy-DirectoryContent -Source "$rootPath\04-interview-readiness" -Destination "$rootPath\00-career-mastery"

# Step 5: Merge 07-boilerplates into 08-resources
Write-Host "`n[5/6] Merging 07-boilerplates into 08-resources..." -ForegroundColor Yellow
Copy-DirectoryContent -Source "$rootPath\07-boilerplates" -Destination "$rootPath\08-resources"

Write-Host "`n[6/6] Removing duplicate directories..." -ForegroundColor Yellow

# Remove duplicate directories after merging
$duplicates = @(
    "$rootPath\01-foundation",
    "$rootPath\02-core-engineering",
    "$rootPath\03-career-strategy",
    "$rootPath\04-interview-readiness",
    "$rootPath\07-boilerplates"
)

foreach ($dup in $duplicates) {
    if (Test-Path $dup) {
        Remove-Item -Path $dup -Recurse -Force
        Write-Host "  [REMOVE] $dup" -ForegroundColor Red
    }
}

# Step 6: Rename 01-beginner to 01-foundations
Write-Host "`nRenaming 01-beginner to 01-foundations..." -ForegroundColor Yellow
if (Test-Path "$rootPath\01-beginner") {
    Rename-Item -Path "$rootPath\01-beginner" -NewName "01-foundations" -Force
    Write-Host "  [RENAME] 01-beginner -> 01-foundations" -ForegroundColor Cyan
}

Write-Host "`n=== Merge Complete! ===" -ForegroundColor Green
Write-Host "Please verify the content and update LEARN-PATH.md references.`n" -ForegroundColor Green
