# Get-Volume

## Purpose
Gets the specified Volume object, providing details like file system type, size, and remaining free space.

## Examples

### List all volumes on the computer
```powershell
Get-Volume
```

### Get metrics for the C drive
```powershell
Get-Volume -DriveLetter 'C'
```

### Find volumes with low disk space (less than 5GB free)
```powershell
Get-Volume | Where-Object SizeRemaining -lt 5GB
```
