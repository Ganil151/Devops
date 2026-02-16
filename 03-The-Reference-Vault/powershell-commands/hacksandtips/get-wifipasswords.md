# Get-WiFiPasswords

> Retrieves saved Wi-Fi profiles and extracts their plain-text keys using native netsh commands wrapped in PowerShell objects.

```powershell
try {
    $Profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    
    foreach ($Profile in $Profiles) {
        $Details = netsh wlan show profile name="$Profile" key=clear
        $KeyLine = $Details | Select-String "Key Content"
        
        if ($KeyLine) {
            $Password = $KeyLine.ToString().Split(":")[1].Trim()
        } else {
            $Password = "[No Key Present]"
        }

        [PSCustomObject]@{
            SSID = $Profile
            Password = $Password
        }
    }
}
catch {
    Write-Error "Failed to retrieve Wi-Fi info. Ensure WLAN service is running."
}
```

## Permissions
*   **Required:** Administrator (required to see cleartext keys)

## Rollback
N/A (Read-only operation)
