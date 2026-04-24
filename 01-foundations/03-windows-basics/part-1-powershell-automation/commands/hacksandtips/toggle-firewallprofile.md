# Toggle-FirewallProfile

> Safely toggles specific firewall profiles (Domain, Private, Public) with built-in safety warnings.

```powershell
param(
    [ValidateSet("Domain", "Private", "Public")]
    [string]$TargetProfile = "Private",
    
    [switch]$TurnOff
)

try {
    if ($TurnOff) {
        Write-Warning "DISABLING the $TargetProfile firewall profile."
        Write-Warning "Do not leave this disabled permanently. Use for testing connectivity only."
        Set-NetFirewallProfile -Profile $TargetProfile -Enabled False -ErrorAction Stop
        Write-Host "Status: $TargetProfile Profile is now DOWN (Off)." -ForegroundColor Red
    }
    else {
        Set-NetFirewallProfile -Profile $TargetProfile -Enabled True -ErrorAction Stop
        Write-Host "Status: $TargetProfile Profile is now UP (On)." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to toggle profile: $_"
}
```

## Permissions
*   **Required:** Administrator Privileges

## Rollback
```powershell
# Re-enable the profile immediately
Set-NetFirewallProfile -Profile "Private" -Enabled True
Write-Host "Safety Rollback: Private profile enabled."
```
