# Removes HP Omen Gaming Hub and related components from Windows

# Run as administrator

Write-Host "Stopping HP Omen related services..."
Get-Service | Where-Object { $_.Name -like "*Omen*" } | ForEach-Object {
    if ($_.Status -eq "Running") {
        Stop-Service -Name $_.Name -Force
    }
}

Write-Host "Uninstalling HP Omen Gaming Hub (OmenGameHub)..."
Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*Omen*" -or $_.Name -like "*HPInc.Omen*" } | ForEach-Object {
    Write-Host "Removing package: $($_.Name)"
    Remove-AppxPackage -Package $_.PackageFullName -AllUsers
}

Write-Host "Uninstalling via Win32_Product (may take time)..."
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Omen*" } | ForEach-Object {
    Write-Host "Uninstalling: $($_.Name)"
    $_.Uninstall()
}

Write-Host "Removing leftover files and folders..."
$paths = @(
    "$env:ProgramFiles\HP\OMEN",
    "$env:ProgramFiles(x86)\HP\OMEN",
    "$env:ProgramData\HP\OMEN",
    "$env:LOCALAPPDATA\Packages\HPInc.OmenCommandCenter*",
    "$env:APPDATA\HP\OMEN"
)
foreach ($path in $paths) {
    Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Cleaning registry entries..."
$regPaths = @(
    "HKLM:\SOFTWARE\HP\OMEN",
    "HKLM:\SOFTWARE\WOW6432Node\HP\OMEN"
)
foreach ($reg in $regPaths) {
    Remove-Item -Path $reg -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "HP Omen Gaming Hub removal complete."