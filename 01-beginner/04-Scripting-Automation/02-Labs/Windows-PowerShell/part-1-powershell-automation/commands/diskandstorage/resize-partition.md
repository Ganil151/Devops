# Resize-Partition

## Purpose
Resizes a partition and the underlying file system to a new specified size.

## Examples

### Resize partition C to 100GB
```powershell
Resize-Partition -DriveLetter 'C' -Size 100GB
```

### Extend a partition to use the maximum supported size available on the disk
```powershell
Resize-Partition -DiskNumber 1 -PartitionNumber 2 -Size (Get-PartitionSupportedSize -DiskNumber 1 -PartitionNumber 2).SizeMax
```
