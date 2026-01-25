function Show-Launcher {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Magenta
    Write-Host "           DEVOPS WORKSTATION: MASTER CONTROL            " -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Magenta
    Write-Host " [1] PERFORMANCE : CPU, Network, & Hardware Tuning       "
    Write-Host " [2] INTEGRITY   : Privacy, Security, & Watchdog         "
    Write-Host " [3] DEVOPS PACK : AWS, K8s, WSL, & Project Bootstrap    "
    Write-Host " [4] UI & STYLE  : Taskbar, Transparency, & RoundedTB    "
    Write-Host " [5] MAINTENANCE : System Disk & Component Cleanup       "
    Write-Host " [6] CLOUD TOOLS : Docker, K8s, Terraform & Lang Caches  "
    Write-Host " [7] EXIT                                                "
    Write-Host "=========================================================" -ForegroundColor Magenta
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

while ($true) {
    Show-Launcher
    $choice = Read-Host "Select Suite"
    switch ($choice) {
        "1" { powershell -ExecutionPolicy Bypass -File "$ScriptDir\Dev_Performance.ps1" }
        "2" { powershell -ExecutionPolicy Bypass -File "$ScriptDir\Secure_Suit.ps1" }
        "3" { powershell -ExecutionPolicy Bypass -File "$ScriptDir\DevOps_Master.ps1" }
        "4" { powershell -ExecutionPolicy Bypass -File "$ScriptDir\WinUI_Master.ps1" }
        "5" { powershell -ExecutionPolicy Bypass -File "$ScriptDir\Sys_Cleanup.ps1" }
        "6" { powershell -ExecutionPolicy Bypass -File "$ScriptDir\Cloud_Cleanup.ps1" }
        "7" { Exit }
    }
}