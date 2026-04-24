# Set-Volume

## Purpose
Changes the file system label or other properties of an existing volume.

## Examples

### Rename the C drive volume label
```powershell
Set-Volume -DriveLetter 'C' -NewFileSystemLabel "SystemDrive"
```

### Modify a specific volume retrieved by pipeline
```powershell
Get-Volume -FileSystemLabel "OldLabel" | Set-Volume -NewFileSystemLabel "NewLabel"
```
