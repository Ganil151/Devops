On PowerShell
```powershell
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -Method Get -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage -Path .\Microsoft.VCLibs.x64.14.00.Desktop.appx
```

```powershell
# Select the version you want to install, see https://github.com/microsoft/winget-cli/releases
$WinGetVer='1.8.1911'
$WinGetLicenseFile='76fba573f02545629706ab99170237bc_License1.xml'

# https://stackoverflow.com/questions/28682642/powershell-why-is-using-invoke-webrequest-much-slower-than-a-browser-download#
$ProgressPreference = 'SilentlyContinue'

# Download and install Microsoft.UI.Xaml
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile $env:TEMP\Microsoft.UI.Xaml.appx
Add-AppxPackage -Path $env:TEMP\Microsoft.UI.Xaml.appx

# Download and install Microsoft.DesktopAppInstaller.WinGet
Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v$WinGetVer/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile $env:TEMP\Microsoft.DesktopAppInstaller.WinGet.appx
Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v$WinGetVer/$WinGetLicenseFile" -OutFile $env:TEMP\license.xml
Add-AppxProvisionedPackage -Online -PackagePath $env:TEMP\Microsoft.DesktopAppInstaller.WinGet.appx -LicensePath $env:TEMP\license.xml
```