# Get-NetFirewallRule

## Purpose
Retrieves firewall rules from the local computer.

## Examples

### Get a specific firewall rule by its list name
```powershell
Get-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
```

### List all enabled inbound rules
```powershell
Get-NetFirewallRule -Direction Inbound -Enabled True
```
