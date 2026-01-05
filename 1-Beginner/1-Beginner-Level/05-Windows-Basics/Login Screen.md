```powershell
$MessageText = @" 
“Enter your text here” 
"@ 
$MessageTitle = "Enter a Title for the text 

$MessageTextPolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 

$MessageTitlePolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 

Set-ItemProperty -Path $MessageTextPolicyPath -Name legalnoticetext -Value $MessageText 

Set-ItemProperty -Path $MessageTitlePolicyPath -Name legalnoticecaption -Value $MessageTitle  
```