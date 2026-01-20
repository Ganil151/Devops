# Toggle-FirewallProfile

> Safely toggles the firewall profile state for troubleshooting.

```powershell
$Profile = "Private"
$State = "False" # False = Off, True = On

try {
    Set-NetFirewallProfile -Profile $Profile -Enabled $State -ErrorAction Stop
    Write-Host "Firewall profile '$Profile' set to Enabled=$State" -ForegroundColor Yellow
}
catch {
    Write-Error "Failed to change firewall state: $_"
}
```

## Permissions
*   **Required:** Administrator (Elevated)

## Rollback
```powershell
# Re-enable the firewall
Set-NetFirewallProfile -Profile "Private" -Enabled "True"
Write-Host "Firewall profile 'Private' re-enabled." -ForegroundColor Green
```
