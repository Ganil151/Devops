# Remove-Partition

## Purpose
Deletes a specified partition and all data contained on it.

## Examples

### Remove a specific partition by disk and partition number
```powershell
Remove-Partition -DiskNumber 1 -PartitionNumber 3
```

### Remove a partition by drive letter without confirmation
```powershell
Remove-Partition -DriveLetter 'E' -Confirm:$false
```
