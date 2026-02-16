# Get-NetIPAddress

## Purpose
Retrieves IP address configuration details (IPv4 and IPv6) for network interfaces.

## Examples

### List all IPv4 addresses on the system
```powershell
Get-NetIPAddress -AddressFamily IPv4
```

### Get IP information for a specific interface index
```powershell
Get-NetIPAddress -InterfaceIndex 12
```
