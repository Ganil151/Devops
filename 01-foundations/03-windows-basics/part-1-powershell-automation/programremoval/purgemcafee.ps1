# Require administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires administrative privileges. Please run as Administrator."
    exit 1
}

# Function to attempt removal using WMI
function Remove-McAfeeWMI {
    $mcafeeProducts = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*McAfee*" }
    foreach ($product in $mcafeeProducts) {
        Write-Host "Attempting to remove: $($product.Name)"
        try {
            $product.Uninstall()
            Write-Host "Successfully uninstalled $($product.Name)"
        }
        catch {
            Write-Warning "Failed to uninstall $($product.Name): $_"
        }
    }
}

# Function to attempt removal using Package Provider
function Remove-McAfeePackage {
    $packages = Get-Package -Provider Programs -IncludeWindowsInstaller -Name "*McAfee*" -ErrorAction SilentlyContinue
    foreach ($package in $packages) {
        Write-Host "Attempting to remove package: $($package.Name)"
        try {
            $package | Uninstall-Package -Force -ErrorAction Stop
            Write-Host "Successfully uninstalled $($package.Name)"
        }
        catch {
            Write-Warning "Failed to uninstall $($package.Name): $_"
        }
    }
}

# Function to run direct uninstallers
function Remove-McAfeeDirect {
    $uninstallerPaths = @(
        "C:\Program Files\McAfee\WebAdvisor\uninstaller.exe",
        "C:\Program Files\McAfee\MSC\mcuihost.exe",
        "D:\Windows-Deployment-main\MCPR.exe"
    )

    foreach ($path in $uninstallerPaths) {
        if (Test-Path $path) {
            Write-Host "Attempting to run uninstaller: $path"
            try {
                Start-Process -FilePath $path -ArgumentList "/silent" -Wait
                Start-Process -FilePath $path -ArgumentList "-silent" -Wait
                Write-Host "Uninstaller completed: $path"
            }
            catch {
                Write-Warning "Failed to run uninstaller $path $($_.Exception.Message)"
            }
        }
        else {
            Write-Warning "Uninstaller not found: $path"
        }
    }
}

# Main execution
Write-Host "Starting McAfee removal process..."
Remove-McAfeeWMI
Remove-McAfeePackage
Remove-McAfeeDirect
Write-Host "McAfee removal process completed."

# Optional: Force restart after removal
$restart = Read-Host "Do you want to restart the computer to complete removal? (y/n)"
if ($restart -eq 'y') {
    Restart-Computer -Force
}