# New-NetFirewallRule

## Purpose
Creates a new inbound or outbound firewall rule.

## Examples

### Allow inbound TCP traffic on port 8080
```powershell
New-NetFirewallRule -DisplayName "Allow App Port 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

### Block outbound traffic to a specific remote IP
```powershell
New-NetFirewallRule -DisplayName "Block Bad IP" -Direction Outbound -RemoteAddress "10.10.10.10" -Action Block
```
