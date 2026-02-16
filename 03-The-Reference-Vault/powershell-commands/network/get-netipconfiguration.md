# Get-NetIPConfiguration

## Purpose
Gets valid and usable network configuration information (interfaces, IP addresses, DNS) in a readable format, similar to `ipconfig /all`.

## Examples

### Get configuration for all interfaces
```powershell
Get-NetIPConfiguration
```

### Get detailed configuration for a specific interface
```powershell
Get-NetIPConfiguration -InterfaceAlias "Wi-Fi" -Detailed
```
