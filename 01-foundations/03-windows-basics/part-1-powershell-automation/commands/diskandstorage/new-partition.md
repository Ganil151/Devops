# New-Partition

## Purpose
Creates a new partition on an existing disk object.

## Examples

### Create a partition using the maximum available space and assign a drive letter
```powershell
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
```

### Create a 10GB partition assigned to drive letter E
```powershell
New-Partition -DiskNumber 1 -Size 10GB -DriveLetter 'E'
```
