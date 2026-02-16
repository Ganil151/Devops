# Restart-NetAdapter

## Purpose
Restarts (disables and then re-enables) a network adapter.

## Examples

### Restart a specific network adapter to reset connectivity
```powershell
Restart-NetAdapter -Name "Wi-Fi"
```

### Restart a physical adapter by interface description
```powershell
Restart-NetAdapter -InterfaceDescription "Intel(R) Ethernet Connection*"
```
