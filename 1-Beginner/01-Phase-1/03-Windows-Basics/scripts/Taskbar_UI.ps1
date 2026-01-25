# --- Administrator Authorization ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "!!! Administrator privileges required !!!"
    Pause; Exit
}

$LogPath = "$env:USERPROFILE\Documents\WinUITweaks.log"
$taskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$visualPath  = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
# Note: The Package ID can vary slightly; this uses the standard store version string.
$RTBPackageName = "TorchGM.RoundedTB_fay99jwv86v92"
$RTBConfigDir = "$env:LOCALAPPDATA\Packages\$RTBPackageName\LocalState"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $LogEntry = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $LogPath -Value $LogEntry
    $color = switch($Level) { "ERROR" {"Red"} "WARN" {"Yellow"} "SUCCESS" {"Green"} Default {"White"} }
    Write-Host $LogEntry -ForegroundColor $color
}

function Set-RegistryValue {
    param([string]$Path, [string]$Name, [object]$Value)
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value
    Write-Log "Applied: $Name = $Value" "SUCCESS"
}

function Apply-RTBPreset {
    # Attempt to find the folder, if missing, we force-launch the app
    if (-not (Test-Path $RTBConfigDir)) {
        Write-Log "Config dir missing. Initializing RoundedTB..." "WARN"
        Start-Process "shell:AppsFolder\$RTBPackageName!App"
        Start-Sleep -Seconds 5 # Wait for folder generation
    }

    if (Test-Path $RTBConfigDir) {
        $ConfigPath = "$RTBConfigDir\settings.json"
        $RTBSettings = @{
            "margin" = 2
            "cornerRadius" = 12
            "transparencyLevel" = 2
            "enableDynamic" = $true
        } | ConvertTo-Json
        $RTBSettings | Out-File $ConfigPath -Encoding utf8 -Force
        Write-Log "Floating Preset injected. Restarting RoundedTB..." "SUCCESS"
        Stop-Process -Name "RoundedTB" -ErrorAction SilentlyContinue
        Start-Process "shell:AppsFolder\$RTBPackageName!App"
    }
}

function Invoke-Action {
    param([int]$ActionID)
    switch ($ActionID) {
        1 { Set-RegistryValue -Path $taskbarPath -Name "TaskbarAl" -Value 0 }
        2 { Set-RegistryValue -Path $taskbarPath -Name "TaskbarAl" -Value 1 }
        3 { 
            # Force Transparency and High Contrast off to ensure visibility
            Set-RegistryValue -Path $visualPath -Name "EnableTransparency" -Value 1
            Write-Log "Ensure Windows is Activated and Battery Saver is OFF for transparency to show." "WARN"
        }
        4 { 
            Set-RegistryValue -Path $taskbarPath -Name "ShowTaskViewButton" -Value 0
            Set-RegistryValue -Path $taskbarPath -Name "TaskbarDa" -Value 0 
        }
        5 { 
            Write-Log "Installing RoundedTB..." "INFO"
            winget install TorchGM.RoundedTB --silent --accept-package-agreements | Out-Null
            Apply-RTBPreset
        }
        6 { 
            reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "$env:USERPROFILE\Documents\UI_Backup.reg" /y | Out-Null
        }
        7 { 
            Stop-Process -Name explorer -Force
            Start-Sleep -Seconds 1
            Start-Process explorer
        }
    }
}

# --- Interactive Menu ---
while ($true) {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host "      WINDOWS 11 UI MASTER SUITE (DEVOPS)            " -ForegroundColor White
    Write-Host "=====================================================" -ForegroundColor Green
    Write-Host " 1. ALIGN LEFT | 2. ALIGN CENTER | 3. FORCE TRANSPARENCY "
    Write-Host " 4. HIDE TASK VIEW & CHAT        | 5. INSTALL & CONFIGURE RTB"
    Write-Host " 6. BACKUP REGISTRY              | 7. RESTART EXPLORER "
    Write-Host " 8. EXIT"
    Write-Host "=====================================================" -ForegroundColor Green
    $choice = Read-Host "Select"
    if ($choice -eq "8") { break }
    Invoke-Action ([int]$choice)
    Pause
}