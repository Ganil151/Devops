# Initialize-Disk

## Purpose
Initializes a new RAW disk for first-time use, enabling it to be partitioned and formatted.

## Examples

### Initialize disk 1 using the GPT partition style (default)
```powershell
Initialize-Disk -Number 1
```

### Initialize a disk with MBR partition style and bring it online
```powershell
Initialize-Disk -Number 2 -PartitionStyle MBR -PassThru | Set-Disk -IsOffline $False
```
