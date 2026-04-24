# Get-NetAdapter

## Purpose
Gets the basic properties of network adapters present on the computer.

## Examples

### List all physical network adapters
```powershell
Get-NetAdapter -Physical
```

### Get a specific adapter by name
```powershell
Get-NetAdapter -Name "Ethernet"
```
