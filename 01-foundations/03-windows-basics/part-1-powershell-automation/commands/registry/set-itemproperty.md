# Set-ItemProperty

## Purpose
Creates or changes the value of a property in a registry key.

## Examples

### Enable Remote Desktop (fDenyTSConnections = 0)
```powershell
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
```

### Change the path of the personal folder in User Shell Folders
```powershell
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Value "D:\Documents"
```
