# Get-DnsClientServerAddress

## Purpose
Gets the DNS server addresses configured on the network interfaces.

## Examples

### List DNS servers for all interfaces
```powershell
Get-DnsClientServerAddress
```

### Get DNS servers for a specific interface
```powershell
Get-DnsClientServerAddress -InterfaceAlias "Ethernet"
```
