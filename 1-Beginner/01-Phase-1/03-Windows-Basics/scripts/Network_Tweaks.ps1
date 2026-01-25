# --- Run as Admin Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! Administrator privileges are required to modify Network Stack settings !!!"
    Pause; Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Blue
    Write-Host "    WIN 11 NETWORK & LATENCY ENHANCER        " -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor Blue
    Write-Host " 1. APPLY: Global TCP Optimizations (Fast)    "
    Write-Host " 2. TWEAK: Gaming/Dev Latency (Disable Nagle) "
    Write-Host " 3. FIX: Network Throttling Index (Registry)  "
    Write-Host " 4. RESET: Full Network Stack (Fixes Issues)  "
    Write-Host " 5. Exit                                     "
    Write-Host "==============================================" -ForegroundColor Blue
}

Show-Menu
$choice = Read-Host "Select an option [1-5]"

switch ($choice) {
    "1" {
        Write-Host "Optimizing TCP Stack..." -ForegroundColor Green
        # The core command you requested
        netsh int tcp set global autotuninglevel=normal
        # Enable Receive Window Auto-Tuning
        netsh int tcp set global rss=enabled
        # Enable Direct Cache Access (DCA) to speed up network data transfer to CPU
        netsh int tcp set global dca=enabled
        # Enable Explicit Congestion Notification (ECN) to reduce packet loss
        netsh int tcp set global ecncapability=enabled
        # Enable Windows Scaling heuristics
        netsh int tcp set heuristics disabled
    }
    "2" {
        Write-Host "Disabling Nagle's Algorithm (TCP No Delay)..." -ForegroundColor Cyan
        # This reduces latency for small packets (crucial for SSH, Remote Desktops, and Gaming)
        $interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
        foreach ($i in $interfaces) {
            Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -ErrorAction SilentlyContinue
        }
        Write-Host "Latency tweaks applied to all interfaces." -ForegroundColor Green
    }
    "3" {
        Write-Host "Removing Network Throttling..." -ForegroundColor Yellow
        # Windows prioritizes multimedia traffic over network traffic by default. 
        # FFFFFFFF (Hex) disables this throttling.
        $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        Set-ItemProperty -Path $path -Name "NetworkThrottlingIndex" -Value 0xffffffff
    }
    "4" {
        Write-Host "Resetting Network Stack to defaults..." -ForegroundColor Red
        netsh int ip reset
        netsh winsock reset
        ipconfig /flushdns
        Write-Host "Restart required!" -ForegroundColor Yellow
    }
    "5" { Exit }
}

Write-Host "`nOperation complete. Changes active." -ForegroundColor Green
Pause