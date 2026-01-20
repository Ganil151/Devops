# Disable-NetAdapter

## Purpose
Disables a network adapter.

## Examples

### Disable a specific network adapter
```powershell
Disable-NetAdapter -Name "Wi-Fi"
```

### Disable an adapter without asking for confirmation
```powershell
Disable-NetAdapter -Name "Ethernet" -Confirm:$false
```
