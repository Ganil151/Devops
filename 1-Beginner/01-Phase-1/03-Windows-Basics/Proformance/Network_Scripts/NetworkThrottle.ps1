# Set NetworkThrottlingIndex to disable network throttling
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
$propertyName = "NetworkThrottlingIndex"
$propertyValue = 0xffffffff

# Create the property if it doesn't exist, or set it if it does
Set-ItemProperty -Path $regPath -Name $propertyName -Value $propertyValue -Type DWord

Write-Output "NetworkThrottlingIndex set to 0xffffffff. Please restart your computer for changes to take effect."