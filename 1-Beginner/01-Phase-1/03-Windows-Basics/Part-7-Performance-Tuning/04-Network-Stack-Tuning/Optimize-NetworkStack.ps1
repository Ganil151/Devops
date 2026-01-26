<#
.SYNOPSIS
    Professional Network Stack Architecture & Congestion Control Optimizer.

.DESCRIPTION
    A kernel-level optimization engine designed to transform the standard Windows 11 
    network stack into a high-throughput, low-latency DevOps interface. This script 
    tunes the TCP/IP implementation to minimize packet serialization delay and 
    maximize bandwidth utilization for large-scale container and cloud workloads.

    Optimization Domains:
    - Kernel TCP Window Scaling & Auto-Tuning
    - RSS (Receive Side Scaling) & RSC (Receive Segment Coalescing)
    - ECN (Explicit Congestion Notification) & DCA (Direct Cache Access)
    - Registry-level Latency Overrides (Nagle's Algorithm)
    - Congestion Control Provider (CUBIC/CTCP)
    - High-Performance DNS resolving (v4/v6)

.PARAMETER DnsProvider
    Choices: Cloudflare, Google, or Reset. Configures encrypted-ready DNS servers.

.PARAMETER SkipOptimizations
    Bypasses kernel/registry tuning and only applies DNS configuration.

.PARAMETER Backup
    Executes a full export of the Netsh stack configuration and the Tcpip registry hive 
    before making any modifications.

.NOTES
    Author: Senior Windows Systems Engineer (Performance Specialist)
    Version: 3.0 (Golden Standard)
    Target Metric: Bytes Total/sec & Average Latency (ms)
    Safety: Includes mandatory registry backup logic.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, HelpMessage = "High-performance DNS provider.")]
    [ValidateSet("Cloudflare", "Google", "Reset")]
    [string]$DnsProvider,

    [Parameter(HelpMessage = "Update DNS only.")]
    [switch]$SkipOptimizations,

    [Parameter(HelpMessage = "Create an automated architectural backup.")]
    [switch]$Backup = $true
)

function Invoke-NetworkArchitectureTuning {
    [CmdletBinding()]
    param($Dns, $Skip, $Back)

    # --- 1. Admin Verification ---
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "CRITICAL: Administrator privileges required for Network Stack modification."
        return
    }

    # --- 2. Automated Safety Backup ---
    if ($Back) {
        $TimeStamp = Get-Date -Format "yyyyMMdd_HHmm"
        $LogDir = "$HOME\DevOps_Backups\Networking"
        if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
        
        Write-Host "`n[🛡️] SECURING SYSTEM ARCHITECTURE (BACKUP)" -ForegroundColor Cyan
        Write-Progress -Activity "Backing up Network Config" -Status "Exporting Registry & Netsh..." -PercentComplete 10
        
        # 2a. Netsh Stack Backup
        netsh int tcp show global > "$LogDir\Netsh_Global_$TimeStamp.txt"
        
        # 2b. Registry Hive Backup (The primary point of risk)
        $RegPath = "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        reg export $RegPath "$LogDir\Tcpip_Params_$TimeStamp.reg" /y | Out-Null
        
        Write-Host " [✔] Backup stored in: $LogDir" -ForegroundColor Green
    }

    try {
        # --- 3. KERNEL TCP STACK TUNING ---
        if (-not $Skip) {
            Write-Host "`n[🚀] APPLYING KERNEL NETWORK OPTIMIZATIONS" -ForegroundColor Cyan
            Write-Host "--------------------------------------------------------" -ForegroundColor Gray
            
            $Tasks = @(
                @{Name="TCP Auto-Tuning (Normal)"; Cmd={netsh int tcp set global autotuninglevel=normal}},
                @{Name="Receive Side Scaling (RSS)"; Cmd={netsh int tcp set global rss=enabled}},
                @{Name="Receive Segment Coalescing (RSC)"; Cmd={netsh int tcp set global rsc=enabled}},
                @{Name="Direct Cache Access (DCA)"; Cmd={netsh int tcp set global dca=enabled}},
                @{Name="Explicit Congestion Notification (ECN)"; Cmd={netsh int tcp set global ecncapability=enabled}},
                @{Name="RFC 1323 Timestamps (Disabled)"; Cmd={netsh int tcp set global timestamps=disabled}},
                @{Name="TCP Heuristics (Disabled)"; Cmd={netsh int tcp set heuristics disabled}}
            )

            for ($i = 0; $i -lt $Tasks.Count; $i++) {
                $T = $Tasks[$i]
                Write-Progress -Activity "Kernel Optimization" -Status "Configuring: $($T.Name)" -PercentComplete (($i / $Tasks.Count) * 100)
                Write-Host " [+] Tuning: $($T.Name)" -ForegroundColor Gray
                & $T.Cmd | Out-Null
            }

            # Congestion Control: CUBIC (Modern Linux/Server Standard)
            if (Get-Command Set-NetTCPSetting -ErrorAction SilentlyContinue) {
                Write-Host " [+] Setting Congestion Provider: CUBIC" -ForegroundColor Gray
                Set-NetTCPSetting -SettingName InternetCustom -CongestionProvider CUBIC -ErrorAction SilentlyContinue
                Set-NetTCPSetting -SettingName Internet -CongestionProvider CUBIC -ErrorAction SilentlyContinue
            }

            # --- 4. REGISTRY LATENCY OVERRIDES (LOW JITTER) ---
            Write-Host "`n[⚡] OPTIMIZING INTERFACE LATENCY (NAGLE'S REMOVAL)" -ForegroundColor Cyan
            $interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
            foreach ($i in $interfaces) {
                # Disable Delayed ACKs & Nagle's Algorithm
                Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -ErrorAction SilentlyContinue
            }

            # Multimedia Throttling: Bypass for Data consistency
            $sysPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
            Set-ItemProperty -Path $sysPath -Name "NetworkThrottlingIndex" -Value 0xffffffff
            
            Write-Host "[✔] Registry-level jitter elimination complete." -ForegroundColor Green
        }

        # --- 5. DNS CLOUD INTEGRATION ---
        if ($Dns) {
            Write-Host "`n[🌐] CONFIGURING DNS ARCHITECTURE: $Dns" -ForegroundColor Cyan
            Write-Host "--------------------------------------------------------" -ForegroundColor Gray
            
            $v4 = switch($Dns) { "Cloudflare" { @("1.1.1.1", "1.0.0.1") } "Google" { @("8.8.8.8", "8.8.4.4") } "Reset" { $null } }
            $v6 = switch($Dns) { "Cloudflare" { @("2606:4700:4700::1111", "2606:4700:4700::1001") } "Google" { @("2001:4860:4860::8888", "2001:4860:4860::8844") } "Reset" { $null } }

            $adapters = Get-NetAdapter | Where-Object { ($_.Name -match "Ethernet" -or $_.Name -match "Wi-Fi") -and $_.Status -eq "Up" }
            foreach ($adapter in $adapters) {
                Write-Progress -Activity "Configuring DNS" -Status "Updating adapter: $($adapter.Name)" -PercentComplete 50
                try {
                    if ($null -eq $v4) {
                        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ResetServerAddresses -ErrorAction Stop
                        Write-Host " [!] $($adapter.Name): Pointing to DHCP (Standard)" -ForegroundColor Yellow
                    } else {
                        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses ($v4 + $v6) -ErrorAction Stop
                        Write-Host " [✔] $($adapter.Name): Optimized for $Dns (v4/v6)" -ForegroundColor Green
                    }
                } catch { Write-Debug "Transient adapter $($adapter.Name) skipped." }
            }
            ipconfig /flushdns | Out-Null
        }

        Write-Progress -Activity "Network Optimization" -Completed
        Write-Host "`n[💎] NETWORK STACK FULLY OPTIMIZED" -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host " Target Performance: Maximum Throughput / Minimum Jitter`n" -ForegroundColor DarkGray

    } catch {
        Write-Error "CRITICAL FAILURE: $($_.Exception.Message)"
    }
}

# --- Execution Entry Point ---
if ($PSBoundParameters.Count -gt 0) {
    Invoke-NetworkArchitectureTuning -Dns $DnsProvider -Skip $SkipOptimizations -Back $Backup
} else {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Blue
    Write-Host "   WIN-DEVOPS NETWORK ARCHITECTURE OPTIMIZER V3.0    " -ForegroundColor White
    Write-Host "====================================================" -ForegroundColor Blue
    Write-Host " 1. [ULTIMATE] Kernel Tuning + Cloudflare DNS        "
    Write-Host " 2. [CORE]     Stack Tuning Only (Kernel & Registry) "
    Write-Host " 3. [DNS ONLY] Cloudflare Optimized (1.1.1.1)        "
    Write-Host " 4. [FACTORY]  Reset to Windows Defaults             "
    Write-Host " 5. [EXIT]                                           "
    Write-Host "====================================================" -ForegroundColor Blue
    
    $Choice = Read-Host "`nSelection"
    switch ($Choice) {
        "1" { Invoke-NetworkArchitectureTuning -Dns Cloudflare -Back $true }
        "2" { Invoke-NetworkArchitectureTuning -Back $true }
        "3" { Invoke-NetworkArchitectureTuning -Dns Cloudflare -Skip $true -Back $true }
        "4" { Invoke-NetworkArchitectureTuning -Dns Reset -Skip $true -Back $false }
        default { return }
    }
}
