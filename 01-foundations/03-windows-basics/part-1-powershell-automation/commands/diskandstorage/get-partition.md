# Get-Partition

## Purpose
Retrieves partition information from one or more disks.

## Examples

### Get all partitions on disk 0
```powershell
Get-Partition -DiskNumber 0
```

### Get a specific partition by drive letter
```powershell
Get-Partition -DriveLetter 'C'
```
