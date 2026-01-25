# Run this to UNHIDE all advanced power settings
# Note: This script requires Administrator privileges to modify the Registry.

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings"

Get-ChildItem -Path $registryPath -Recurse | ForEach-Object {
    $path = $_.PSPath
    # Check if 'Attributes' exists. If so, set it to 2 (Unhide).
    if (Get-ItemProperty -Path $path -Name "Attributes" -ErrorAction SilentlyContinue) {
        Set-ItemProperty -Path $path -Name "Attributes" -Value 2
        
        # Attempt to get a friendly name for display, fallback to GUID
        $name = (Get-ItemProperty -Path $path -Name "FriendlyName" -ErrorAction SilentlyContinue).FriendlyName
        if (-not $name) { $name = $_.PSChildName }
        
        Write-Host "Unlocking: $name" -ForegroundColor Cyan
    }
}