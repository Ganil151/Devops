# Enable-NetAdapter

## Purpose
Enables a previously disabled network adapter.

## Examples

### Enable a specific network adapter
```powershell
Enable-NetAdapter -Name "Wi-Fi"
```

### Enable all adapters without a confirmation prompt
```powershell
Enable-NetAdapter -Name * -Confirm:$false
```
