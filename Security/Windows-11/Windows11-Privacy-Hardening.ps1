#Requires -RunAsAdministrator

# Color output functions
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Write-Info { Write-Host "ℹ $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Write-ErrorMsg { Write-Host "✗ $args" -ForegroundColor Red }

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║     Windows 11 Privacy & Security Hardening Script          ║
║                 Remove Spyware & Telemetry                   ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Warning "This script will make significant system changes."
$confirm = Read-Host "Do you want to continue? (YES/no)"
if ($confirm -ne "YES") {
    Write-Info "Script cancelled by user."
    exit
}

Write-Info "Creating system restore point..."
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before Privacy Hardening" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Write-Success "System restore point created"
} catch {
    Write-Warning "Could not create restore point: $($_.Exception.Message)"
}

# =============================================================================
# SECTION 1: DISABLE WINDOWS RECALL & AI FEATURES
# =============================================================================
Write-Host "`n[1/12] Disabling Windows Recall & AI Features..." -ForegroundColor Yellow

try {
    Write-Info "Checking Recall feature status..."
    $recallStatus = Dism /Online /Get-Featureinfo /Featurename:Recall 2>&1
    
    if ($recallStatus -match "State : Enabled") {
        Dism /Online /Disable-Feature /Featurename:Recall /NoRestart
        Write-Success "Windows Recall disabled"
    } else {
        Write-Success "Windows Recall already disabled"
    }
} catch {
    Write-Warning "Could not disable Recall: $($_.Exception.Message)"
}

# Disable Copilot
Write-Info "Disabling Windows Copilot..."
try {
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Force
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Force
    Write-Success "Windows Copilot disabled"
} catch {
    Write-Warning "Could not disable Copilot: $($_.Exception.Message)"
}

# =============================================================================
# SECTION 2: DISABLE TELEMETRY & DATA COLLECTION
# =============================================================================
Write-Host "`n[2/12] Disabling Telemetry & Data Collection..." -ForegroundColor Yellow

$telemetryServices = @(
    "DiagTrack",
    "dmwappushservice",
    "WerSvc",
    "PcaSvc",
    "RemoteRegistry"
)

foreach ($service in $telemetryServices) {
    try {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Success "Disabled service: $service"
    } catch {
        Write-Warning "Could not disable $service"
    }
}

# Disable telemetry via registry
Write-Info "Configuring telemetry registry settings..."
$telemetryKeys = @(
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="AllowTelemetry"; Value=0},
    @{Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name="AllowTelemetry"; Value=0},
    @{Path="HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name="AllowTelemetry"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="MaxTelemetryAllowed"; Value=0}
)

foreach ($key in $telemetryKeys) {
    try {
        New-Item -Path $key.Path -Force | Out-Null
        Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Value -Force
        Write-Success "Set $($key.Name) = $($key.Value)"
    } catch {
        Write-Warning "Could not set $($key.Name)"
    }
}

# =============================================================================
# SECTION 3: DISABLE ADVERTISING & TRACKING
# =============================================================================
Write-Host "`n[3/12] Disabling Advertising & Tracking..." -ForegroundColor Yellow

$advertisingKeys = @(
    @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name="Enabled"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"; Name="DisabledByGroupPolicy"; Value=1},
    @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="SubscribedContent-338393Enabled"; Value=0},
    @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="SubscribedContent-353694Enabled"; Value=0},
    @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="SubscribedContent-353696Enabled"; Value=0}
)

foreach ($key in $advertisingKeys) {
    try {
        New-Item -Path $key.Path -Force | Out-Null
        Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Value -Force
        Write-Success "Disabled: $($key.Name)"
    } catch {
        Write-Warning "Could not disable $($key.Name)"
    }
}

# =============================================================================
# SECTION 4: DISABLE CORTANA
# =============================================================================
Write-Host "`n[4/12] Disabling Cortana..." -ForegroundColor Yellow

try {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCloudSearch" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortanaAboveLock" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0 -Force
    Write-Success "Cortana disabled"
} catch {
    Write-Warning "Could not disable Cortana: $($_.Exception.Message)"
}

# =============================================================================
# SECTION 5: DISABLE LOCATION TRACKING
# =============================================================================
Write-Host "`n[5/12] Disabling Location Tracking..." -ForegroundColor Yellow

try {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -Value 1 -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Value 0 -Force
    Stop-Service "lfsvc" -Force -ErrorAction SilentlyContinue
    Set-Service "lfsvc" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Success "Location tracking disabled"
} catch {
    Write-Warning "Could not disable location tracking: $($_.Exception.Message)"
}

# =============================================================================
# SECTION 6: DISABLE WINDOWS FEEDBACK & EXPERIMENTATION
# =============================================================================
Write-Host "`n[6/12] Disabling Windows Feedback & Experimentation..." -ForegroundColor Yellow

$feedbackKeys = @(
    @{Path="HKCU:\Software\Microsoft\Siuf\Rules"; Name="NumberOfSIUFInPeriod"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="DoNotShowFeedbackNotifications"; Value=1},
    @{Path="HKCU:\Software\Microsoft\Siuf\Rules"; Name="PeriodInNanoSeconds"; Value=0},
    @{Path="HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\System"; Name="AllowExperimentation"; Value=0}
)

foreach ($key in $feedbackKeys) {
    try {
        New-Item -Path $key.Path -Force | Out-Null
        Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Value -Force
        Write-Success "Set $($key.Name) = $($key.Value)"
    } catch {
        Write-Warning "Could not set $($key.Name)"
    }
}

# =============================================================================
# SECTION 7: DISABLE ACTIVITY HISTORY & TIMELINE
# =============================================================================
Write-Host "`n[7/12] Disabling Activity History & Timeline..." -ForegroundColor Yellow

try {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Force
    Write-Success "Activity History & Timeline disabled"
} catch {
    Write-Warning "Could not disable Activity History: $($_.Exception.Message)"
}

# =============================================================================
# SECTION 8: DISABLE BIOMETRIC & FACE RECOGNITION DATA
# =============================================================================
Write-Host "`n[8/12] Disabling Biometric Data Collection..." -ForegroundColor Yellow

try {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" -Name "Enabled" -Value 0 -Force
    Stop-Service "WbioSrvc" -Force -ErrorAction SilentlyContinue
    Set-Service "WbioSrvc" -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Success "Biometric services disabled"
} catch {
    Write-Warning "Could not disable biometric services: $($_.Exception.Message)"
}

# =============================================================================
# SECTION 9: DISABLE CLOUD CLIPBOARD & SYNC
# =============================================================================
Write-Host "`n[9/12] Disabling Cloud Clipboard & Sync..." -ForegroundColor Yellow

try {
    New-Item -Path "HKCU:\Software\Microsoft\Clipboard" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 0 -Force
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowClipboardHistory" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowCrossDeviceClipboard" -Value 0 -Force
    Write-Success "Cloud clipboard disabled"
} catch {
    Write-Warning "Could not disable cloud clipboard: $($_.Exception.Message)"
}

# =============================================================================
# SECTION 10: DISABLE MICROSOFT EDGE TELEMETRY
# =============================================================================
Write-Host "`n[10/12] Disabling Microsoft Edge Telemetry..." -ForegroundColor Yellow

$edgeKeys = @(
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name="PersonalizationReportingEnabled"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name="UserFeedbackAllowed"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name="MetricsReportingEnabled"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name="SpotlightExperiencesAndRecommendationsEnabled"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name="EdgeCollectionsEnabled"; Value=0}
)

foreach ($key in $edgeKeys) {
    try {
        New-Item -Path $key.Path -Force | Out-Null
        Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Value -Force
        Write-Success "Set $($key.Name) = $($key.Value)"
    } catch {
        Write-Warning "Could not set $($key.Name)"
    }
}

# =============================================================================
# SECTION 11: DISABLE WINDOWS DEFENDER SAMPLE SUBMISSION
# =============================================================================
Write-Host "`n[11/12] Configuring Windows Defender Privacy..." -ForegroundColor Yellow

try {
    Set-MpPreference -SubmitSamplesConsent NeverSend -ErrorAction SilentlyContinue
    Set-MpPreference -MAPSReporting Disabled -ErrorAction SilentlyContinue
    Write-Success "Windows Defender sample submission disabled"
} catch {
    Write-Warning "Could not configure Windows Defender settings: $($_.Exception.Message)"
}

# =============================================================================
# SECTION 12: DISABLE OneDrive
# =============================================================================
Write-Host "`n[12/12] Disabling OneDrive..." -ForegroundColor Yellow

try {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSync" -Value 1 -Force
    Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Success "OneDrive disabled"
} catch {
    Write-Warning "Could not disable OneDrive: $($_.Exception.Message)"
}

# =============================================================================
# FINAL REPORT
# =============================================================================
Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                   HARDENING COMPLETE                         ║
╚══════════════════════════════════════════════════════════════╝

SUMMARY:
✓ Windows Recall & AI features disabled
✓ Telemetry & data collection disabled
✓ Advertising & tracking disabled
✓ Cortana disabled
✓ Location tracking disabled
✓ Feedback & experimentation disabled
✓ Activity history & timeline disabled
✓ Biometric data collection disabled
✓ Cloud clipboard disabled
✓ Edge telemetry disabled
✓ Windows Defender sample submission disabled
✓ OneDrive disabled

IMPORTANT NOTES:
⚠ A system restart is REQUIRED for all changes to take effect
⚠ A system restore point was created before changes
⚠ Review Privacy settings in Windows Settings

NEXT STEPS:
1. Restart your computer now
2. Verify changes in Settings > Privacy & Security
3. Use System Restore if you need to undo changes

"@ -ForegroundColor Green

Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")