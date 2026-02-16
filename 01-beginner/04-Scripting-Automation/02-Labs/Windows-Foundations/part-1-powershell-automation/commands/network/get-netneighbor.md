# Get-NetNeighbor

## Purpose
Gets the neighbor cache entries (ARP/NDP table), mapping IP addresses to link-layer addresses.

## Examples

### View the full neighbor cache (ARP table)
```powershell
Get-NetNeighbor
```

### Find the MAC address for a specific neighbor IP
```powershell
Get-NetNeighbor -IPAddress "192.168.1.1"
```
