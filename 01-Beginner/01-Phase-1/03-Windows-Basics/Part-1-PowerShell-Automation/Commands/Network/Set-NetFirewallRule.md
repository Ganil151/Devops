# Set-NetFirewallRule

## Purpose
Modifies the properties of an existing firewall rule.

## Examples

### Disable an existing firewall rule
```powershell
Set-NetFirewallRule -DisplayName "Allow App Port 8080" -Enabled False
```

### Change the action of a rule to Block
```powershell
Set-NetFirewallRule -DisplayName "Allow Telnet" -Action Block
```
