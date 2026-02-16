# Resolve-DnsName

## Purpose
Performs a DNS name resolution query for a specified name, functioning as a modern alternative to `nslookup`.

## Examples

### Resolve a hostname to an IP address
```powershell
Resolve-DnsName -Name "microsoft.com"
```

### Query a specific record type (e.g., MX for mail)
```powershell
Resolve-DnsName -Name "gmail.com" -Type MX
```

### Query a specific DNS server directly
```powershell
Resolve-DnsName -Name "example.com" -Server "1.1.1.1"
```
