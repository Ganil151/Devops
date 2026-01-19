param(
    [string]$Root = "C:\Users\Ganil\Documents\Devops\5-Boilerplates\1-Beginner\Shell",
    [switch]$AutoByExt
)

if (-not (Test-Path $Root)) { Write-Error "Root not found: $Root"; exit 1 }

if ($AutoByExt) {
    Get-ChildItem -Path $Root -File -Recurse | ForEach-Object {
        $ext = ($_.Extension.TrimStart('.') -as [string]).ToLower()
        if (-not $ext) { $ext = "noext" }
        $dest = Join-Path $Root $ext
        New-Item -Path $dest -ItemType Directory -Force | Out-Null
        Move-Item -Path $_.FullName -Destination $dest -Force
        Write-Host "Moved $($_.Name) -> $dest"
    }
    return
}

$files = Get-ChildItem -Path $Root -File -Recurse | Sort-Object FullName
foreach ($f in $files) {
    Write-Host "`n---`nFile: $($f.FullName)`n---"
    try { Get-Content -Path $f.FullName -TotalCount 20 -ErrorAction Stop | ForEach-Object { Write-Host $_ } } catch {}
    $subject = Read-Host "Enter subject folder name for this file (blank = skip, '.' = root)"
    if ($subject -eq "") { Write-Host "Skipped"; continue }
    $destDir = if ($subject -eq ".") { $Root } else { Join-Path $Root $subject }
    New-Item -Path $destDir -ItemType Directory -Force | Out-Null
    Move-Item -Path $f.FullName -Destination $destDir -Force
    Write-Host "Moved to $destDir"
}