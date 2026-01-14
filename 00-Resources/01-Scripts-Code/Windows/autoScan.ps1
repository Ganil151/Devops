<#
.SYNOPSIS
    Automated Virus Scan Trigger
    Monitors Downloads folder and USB insertions to trigger Windows Defender scans.

.DESCRIPTION
    This script uses .NET FileSystemWatcher and WMI Events to detect file system changes
    in real-time. It is designed to run in the background with minimal footprint.

.NOTES
    Author: DevOps Engineer
    OS: Windows 11
    Requires: Run as Administrator (for WMI and Defender access)
#>

# --- Configuration ---
$DownloadsPath = "$env:USERPROFILE\Downloads"
$LogFile = "$env:USERPROFILE\Documents\VirusScanLog.txt"

# --- Helper Functions ---

function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$TimeStamp] $Message"
    Add-Content -Path $LogFile -Value $LogEntry
    Write-Host $LogEntry -ForegroundColor Cyan
}

function InvokeScan {
    param ([string]$Path, [string]$Type)
    
    if (-not (Test-Path $Path)) {
        Write-Log "Error: Path not found - $Path"
        return
    }

    Write-Log "Starting $Type scan for: $Path"
    
    try {
        # Start-MpScan is the native Windows Defender cmdlet
        # ScanType Custom allow us to scan specific files/folders
        $ScanJob = Start-MpScan -ScanType Custom -ScanPath $Path -PassThru
        
        if ($ScanJob) {
            Write-Log "Scan completed successfully."
        }
    }
    catch {
        Write-Log "CRITICAL ERROR: Failed to scan $Path. Details: $_"
    }
}

# --- 1. File Download Monitor (FileSystemWatcher) ---

$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $DownloadsPath
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true

# Define the action block for new files
$Action = {
    $Path = $Event.SourceEventArgs.FullPath
    $ChangeType = $Event.SourceEventArgs.ChangeType
    
    Write-Host "New File Detected: $Path" -ForegroundColor Green
    
    # Wait briefly for file handle to be released (download completion)
    # Scalability Note: For very large files, a more robust "wait for lock" loop might be needed.
    Start-Sleep -Seconds 2
    
    # Call the scanner function (must scope specifically in event block)
    # We reference the script-scope function
    $Function:InvokeScan.Invoke($Path, "Download")
}

# Register the event subscriber
Register-ObjectEvent -InputObject $Watcher -EventName "Created" -SourceIdentifier "FileDownloadWatcher" -Action $Action | Out-Null
Write-Log "Monitoring Downloads folder: $DownloadsPath"

# --- 2. USB Insertion Monitor (WMI) ---

$WmiQuery = "SELECT * FROM Win32_VolumeChangeEvent WHERE EventType = 2"
# EventType 2 = Device Arrival

Register-WmiEvent -Query $WmiQuery -SourceIdentifier "USBWatcher" -Action {
    $DriveLetter = $Event.SourceEventArgs.NewEvent.DriveName
    $Time = $Event.TimeGenerated
    
    Write-Host "USB Device Inserted: $DriveLetter" -ForegroundColor Yellow
    
    # WMI event gives us the drive letter (e.g., E:)
    if ($DriveLetter) {
        $Function:InvokeScan.Invoke($DriveLetter, "External Device")
    }
} | Out-Null

Write-Log "Monitoring for USB Device insertion..."

# --- Main Loop ---
# Keep the script running to listen for events
Write-Host "Automation Service Started. Press Ctrl+C to exit." -ForegroundColor Green

try {
    while ($true) {
        Start-Sleep -Seconds 5
    }
}
finally {
    # Cleanup on exit
    Unregister-Event -SourceIdentifier "FileDownloadWatcher" -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier "USBWatcher" -ErrorAction SilentlyContinue
    $Watcher.Dispose()
    Write-Log "Service Stopped."
}