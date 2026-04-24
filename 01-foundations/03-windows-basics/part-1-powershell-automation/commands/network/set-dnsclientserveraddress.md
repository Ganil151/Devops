# Set-DnsClientServerAddress

## Purpose
Configures the DNS server addresses for a network interface.

## Examples

### Set primary and secondary DNS servers for an interface
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("8.8.8.8", "8.8.4.4")
```

### Revert to using DHCP for DNS (Clear static addresses)
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
```
