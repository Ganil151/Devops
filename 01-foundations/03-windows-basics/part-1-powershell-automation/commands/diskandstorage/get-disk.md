# Get-Disk

## Purpose
Gets run-time information about disks available to the operating system, such as their status, size, and partition style.

## Examples

### Get all visible disks
```powershell
Get-Disk
```

### Get a specific disk by number
```powershell
Get-Disk -Number 1
```

### Filter for disks that are currently offline
```powershell
Get-Disk | Where-Object IsOffline -Eq $True
```
