# Format-Volume

## Purpose
Formats a volume, allowing you to choose the file system, allocation unit size, and volume label.

## Examples

### Format drive D as NTFS with a label
```powershell
Format-Volume -DriveLetter 'D' -FileSystem NTFS -NewFileSystemLabel "DataVolume" -Confirm:$false
```

### Format a newly created partition object (via pipeline)
```powershell
Get-Partition -DiskNumber 1 -PartitionNumber 2 | Format-Volume -FileSystem FAT32
```
