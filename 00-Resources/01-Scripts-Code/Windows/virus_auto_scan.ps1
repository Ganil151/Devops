<#
.SYNOPSIS
    DefenderGuard: Auto Virus Scanner & Monitor
    
.DESCRIPTION
    A background security tool that monitors USBs and Downloads using 
    FileSystemWatcher and WMI.
#>

param (
    [switch]$Setup,
    [switch]$Uninstall
)

# ==============================================================================
# 1. SETUP / INSTALLATION ROUTINE
# ==============================================================================
if ($Setup -or $Uninstall) {
    $TaskName = "DefenderGuard_Monitor"
    
    if ($Uninstall) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Uninstalled DefenderGuard Persistence." -ForegroundColor Yellow
        return
    }

    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "Setup requires Administrator privileges."
        return
    }

    $ScriptPath = $PSCommandPath
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Days 0) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
    $Principal = New-ScheduledTaskPrincipal -GroupId "INTERACTIVE" -RunLevel Highest

    Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -TaskName $TaskName -Force | Out-Null
    
    Write-Host "SUCCESS: DefenderGuard installed!" -ForegroundColor Green
    Start-ScheduledTask -TaskName $TaskName
    return
}

# ==============================================================================
# 2. RUNTIME ENGINE
# ==============================================================================

# A. Framework & Config
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$LogPath = "$env:PROGRAMDATA\DefenderGuard\activity_log.txt"
$DownloadsPath = "$env:USERPROFILE\Downloads"
$AppTitle = "DefenderGuard"

if (!(Test-Path (Split-Path $LogPath))) { New-Item -ItemType Directory -Path (Split-Path $LogPath) -Force | Out-Null }

# B. GUI Helper (Tray Icon)
$IconPath = "$env:SystemRoot\System32\SHELL32.dll"
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($IconPath)
$NotifyIcon.Text = "${AppTitle}: Active"
$NotifyIcon.Visible = $true

$CtxMenu = New-Object System.Windows.Forms.ContextMenu
$ExitItem = $CtxMenu.MenuItems.Add("Exit Monitor")
$ExitItem.add_Click({ 
    $NotifyIcon.Visible = $false
    [System.Windows.Forms.Application]::Exit() 
})
$NotifyIcon.ContextMenu = $CtxMenu

Function Write-Log ($Msg, $Type="Info") {
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$TimeStamp][$Type] $Msg" | Out-File -FilePath $LogPath -Append
}

Function Show-Balloon ($Title, $Text, $Icon="Info") {
    $NotifyIcon.ShowBalloonTip(3000, $Title, $Text, [System.Windows.Forms.ToolTipIcon]::$Icon)
}

# C. Threat Mitigation Logic
Function Invoke-MitigationScan {
    param($Target, $SourceType)
    
    Show-Balloon "Scanning Detected Item" "Analyzing $SourceType...`n$Target" "Info"
    $NotifyIcon.Text = "${AppTitle}: Scanning..."
    
    try {
        Write-Log "Starting Scan on: $Target"
        Start-MpScan -ScanType CustomScan -ScanPath $Target -ErrorAction Stop
        
        Show-Balloon "Scan Complete" "No active threats found in $Target." "Info"
        Write-Log "Scan Finished: Clean"
    }
    catch {
        Write-Log "Scan Alert/Action: $($_.Exception.Message)" "Warning"
        Show-Balloon "Security Alert" "Scan handled for $Target." "Warning"
    }
    finally {
        $NotifyIcon.Text = "${AppTitle}: Active"
        [System.GC]::Collect()
    }
}

# D. Event Handlers
$GlobalAction = {
    # $Event is automatically available in the script block context
    $Path = $null
    $Reason = $null

    if ($Event.SourceIdentifier -eq "USBWatcher") {
        # WMI DriveName detection
        $Path = $Event.SourceEventArgs.NewEvent.DriveName
        $Reason = "USB Device"
    } 
    elseif ($Event.SourceIdentifier -eq "DownloadWatcher") {
        # FileSystemWatcher FullPath detection
        $Path = $Event.SourceEventArgs.FullPath
        $Reason = "New Download"
    }

    if ($Path) {
        Invoke-MitigationScan -Target $Path -SourceType $Reason
    }
} # Closing brace fixed here

# E. Start Listeners
# 1. USB Listener (WMI)
$WmiQuery = "SELECT * FROM Win32_VolumeChangeEvent WHERE EventType = 2"
Register-WmiEvent -Query $WmiQuery -SourceIdentifier "USBWatcher" -Action $GlobalAction

# 2. Download Listener (Filesystem)
$FSWatcher = New-Object System.IO.FileSystemWatcher
$FSWatcher.Path = $DownloadsPath
$FSWatcher.EnableRaisingEvents = $true
Register-ObjectEvent -InputObject $FSWatcher -EventName "Created" -SourceIdentifier "DownloadWatcher" -Action $GlobalAction

# F. Main Loop
Write-Log "Monitor Service Started"
Show-Balloon "DefenderGuard Active" "Protection enabled." "Info"

[System.Windows.Forms.Application]::Run()

# Cleanup
Unregister-Event -SourceIdentifier "USBWatcher" -ErrorAction SilentlyContinue
Unregister-Event -SourceIdentifier "DownloadWatcher" -ErrorAction SilentlyContinue