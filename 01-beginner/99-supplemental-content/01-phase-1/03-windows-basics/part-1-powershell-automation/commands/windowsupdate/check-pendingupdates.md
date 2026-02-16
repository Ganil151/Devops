# Check-PendingUpdates

## Purpose
Checks for updates that are available for the system but not yet installed, using the native Windows Update Agent (COM Object).

## Examples

### Scan and list available updates
```powershell
# Create the update session
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

# Search for updates that are not installed (IsInstalled=0)
$SearchResult = $UpdateSearcher.Search("IsInstalled=0")

# Display titles of available updates
$SearchResult.Updates | Select-Object Title, MsrcSeverity
```

### Check if a reboot is required by Windows Update
```powershell
$SysInfo = New-Object -ComObject Microsoft.Update.SystemInfo
$SysInfo.RebootRequired
```
