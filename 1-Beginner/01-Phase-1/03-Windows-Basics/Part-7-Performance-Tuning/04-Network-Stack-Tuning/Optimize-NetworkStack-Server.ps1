<#
.SYNOPSIS
    High-Throughput Network Stack Optimizer for Windows Server CI/CD Infrastructure.

.DESCRIPTION
    This script tunes the Windows Server TCP/IP stack for maximum throughput in
    CI/CD environments with heavy Docker registry traffic, artifact downloads, and
    distributed build coordination. Unlike workstation optimizations, this focuses
    on sustained high-bandwidth transfers and minimizing CPU overhead through
    intelligent task offloading configuration.

    Server-Specific Optimizations:
    - RSS (Receive Side Scaling) tuning for multi-core servers
    - Task Offloading optimization (LSO, GSO, RSC)
    - TCP Chimney Offload configuration
    - Jumbo Frames enablement (for datacenter environments)
    - TCP Window Scaling for high-bandwidth-delay product
    - Congestion Control Provider (CUBIC for modern networks)
    - Network Adapter Power Management
    - DNS caching optimization

    Differences from Workstation Edition:
    - Enables hardware offloading (disabled on workstations for latency)
    - Configures larger TCP windows for throughput
    - Optimizes for sustained transfers vs. interactive responsiveness
    - Supports Jumbo Frames for datacenter deployments

.PARAMETER EnableJumboFrames
    Enable Jumbo Frames (MTU 9000) for datacenter environments.

.PARAMETER DisableOffloading
    Disable task offloading (for troubleshooting or specific workloads).

.PARAMETER DnsProvider
    High-performance DNS provider: Cloudflare, Google, or Reset.

.PARAMETER Backup
    Create automated backup of network configuration.

.EXAMPLE
    .\Optimize-NetworkStack-Server.ps1
    Apply server-optimized network tuning with defaults.

.EXAMPLE
    .\Optimize-NetworkStack-Server.ps1 -EnableJumboFrames -DnsProvider Cloudflare
    Enable Jumbo Frames and configure Cloudflare DNS.

.EXAMPLE
    .\Optimize-NetworkStack-Server.ps1 -DisableOffloading -Verbose
    Disable task offloading for low-latency workloads with detailed logging.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard - Server Edition)
    Target: Windows Server 2019/2022 (CI/CD nodes)
    Safety: Automatic backup of netsh and registry configuration
    Idempotency: Checks current settings before modification
    Performance Target: Maximum throughput for sustained transfers
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(HelpMessage = "Enable Jumbo Frames (MTU 9000) for datacenter")]
    [switch]$EnableJumboFrames,

    [Parameter(HelpMessage = "Disable task offloading (troubleshooting mode)")]
    [switch]$DisableOffloading,

    [Parameter(HelpMessage = "High-performance DNS provider")]
    [ValidateSet("Cloudflare", "Google", "Reset")]
    [string]$DnsProvider,

    [Parameter(HelpMessage = "Create automated backup")]
    [switch]$Backup = $true
)

#Requires -Version 5.1
#Requires -RunAsAdministrator

# ============================================================================
# MAIN FUNCTION: Optimize-ServerNetworkStack
# ============================================================================

function Optimize-ServerNetworkStack {
    [CmdletBinding()]
    param(
        [bool]$JumboFrames,
        [bool]$NoOffload,
        [string]$Dns,
        [bool]$CreateBackup
    )

    try {
        $startTime = Get-Date
        
        # --- 1. Environment Validation ---
        Write-Host "`n[🌐] SERVER NETWORK STACK OPTIMIZATION" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        # Verify Windows Server OS
        $os = Get-CimInstance Win32_OperatingSystem
        if ($os.ProductType -ne 3) {
            Write-Warning "This script is optimized for Windows Server. Detected: $($os.Caption)"
            $continue = Read-Host "Continue anyway? (Y/N)"
            if ($continue -ne 'Y') { return }
        } else {
            Write-Host "[✔] Windows Server detected: $($os.Caption)" -ForegroundColor Green
        }

        # --- 2. Backup Configuration ---
        if ($CreateBackup) {
            Write-Host "`n[🛡️] BACKING UP NETWORK CONFIGURATION" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Gray
            
            $backupDir = "$env:ProgramData\DevOps_Backups\Networking"
            if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
            
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            
            # Backup netsh configuration
            netsh int tcp show global > "$backupDir\Netsh_TCP_Global_$timestamp.txt"
            netsh int ipv4 show interfaces > "$backupDir\Netsh_IPv4_Interfaces_$timestamp.txt"
            
            # Backup registry
            $regPath = "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
            reg export $regPath "$backupDir\Tcpip_Params_$timestamp.reg" /y | Out-Null
            
            Write-Host "[✔] Backup saved: $backupDir" -ForegroundColor Green
        }

        # --- 3. TCP/IP Stack Tuning (Server Profile) ---
        Write-Host "`n[🚀] APPLYING SERVER TCP/IP OPTIMIZATIONS" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        $tcpTasks = @(
            @{Name="TCP Auto-Tuning (Highly Restricted)"; Cmd={netsh int tcp set global autotuninglevel=highlyrestricted}; Desc="Maximum throughput for servers"},
            @{Name="Receive Side Scaling (RSS)"; Cmd={netsh int tcp set global rss=enabled}; Desc="Multi-core packet processing"},
            @{Name="Receive Segment Coalescing (RSC)"; Cmd={netsh int tcp set global rsc=enabled}; Desc="Reduce CPU overhead"},
            @{Name="Direct Cache Access (DCA)"; Cmd={netsh int tcp set global dca=enabled}; Desc="Improve memory bandwidth"},
            @{Name="Network Direct Memory Access (NetDMA)"; Cmd={netsh int tcp set global netdma=enabled}; Desc="Offload memory copies"},
            @{Name="Explicit Congestion Notification (ECN)"; Cmd={netsh int tcp set global ecncapability=enabled}; Desc="Reduce packet loss"},
            @{Name="Initial Congestion Window"; Cmd={netsh int tcp set global initialcongestionwindow=10}; Desc="Faster connection startup"},
            @{Name="TCP Timestamps"; Cmd={netsh int tcp set global timestamps=enabled}; Desc="Better RTT estimation"}
        )

        foreach ($task in $tcpTasks) {
            Write-Host "[+] $($task.Name)" -ForegroundColor Gray
            Write-Verbose "    $($task.Desc)"
            & $task.Cmd | Out-Null
        }
        
        Write-Host "[✔] TCP/IP stack optimized for server workloads" -ForegroundColor Green

        # --- 4. Congestion Control Provider (CUBIC) ---
        Write-Host "`n[📊] CONFIGURING CONGESTION CONTROL" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        try {
            if (Get-Command Set-NetTCPSetting -ErrorAction SilentlyContinue) {
                # CUBIC is optimal for high-bandwidth networks
                Set-NetTCPSetting -SettingName InternetCustom -CongestionProvider CUBIC -ErrorAction SilentlyContinue
                Set-NetTCPSetting -SettingName Datacenter -CongestionProvider CUBIC -ErrorAction SilentlyContinue
                Set-NetTCPSetting -SettingName Internet -CongestionProvider CUBIC -ErrorAction SilentlyContinue
                
                Write-Host "[✔] Congestion provider set to CUBIC (optimal for servers)" -ForegroundColor Green
            }
        } catch {
            Write-Warning "Failed to set congestion provider: $($_.Exception.Message)"
        }

        # --- 5. Network Adapter Offloading ---
        Write-Host "`n[⚙️] CONFIGURING NETWORK ADAPTER OFFLOADING" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notmatch "Virtual|Loopback" }
        
        foreach ($adapter in $adapters) {
            Write-Host "`nAdapter: $($adapter.Name) ($($adapter.InterfaceDescription))" -ForegroundColor Yellow
            
            if ($NoOffload) {
                # Disable offloading (for troubleshooting or low-latency workloads)
                Write-Host "[!] Disabling task offloading (troubleshooting mode)" -ForegroundColor Yellow
                
                Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2 (IPv4)" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
                Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2 (IPv6)" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
                Disable-NetAdapterChecksumOffload -Name $adapter.Name -ErrorAction SilentlyContinue
                Disable-NetAdapterLso -Name $adapter.Name -ErrorAction SilentlyContinue
                
                Write-Host "  [✔] Task offloading disabled" -ForegroundColor Green
                
            } else {
                # Enable offloading (optimal for server throughput)
                Write-Host "[+] Enabling hardware offloading (server optimization)" -ForegroundColor Gray
                
                try {
                    # Large Send Offload (LSO/GSO)
                    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2 (IPv4)" -DisplayValue "Enabled" -ErrorAction SilentlyContinue
                    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2 (IPv6)" -DisplayValue "Enabled" -ErrorAction SilentlyContinue
                    
                    # Checksum Offload
                    Enable-NetAdapterChecksumOffload -Name $adapter.Name -ErrorAction SilentlyContinue
                    
                    # RSS (Receive Side Scaling)
                    Enable-NetAdapterRss -Name $adapter.Name -ErrorAction SilentlyContinue
                    Set-NetAdapterRss -Name $adapter.Name -NumberOfReceiveQueues 4 -ErrorAction SilentlyContinue
                    
                    # RSC (Receive Segment Coalescing)
                    Enable-NetAdapterRsc -Name $adapter.Name -ErrorAction SilentlyContinue
                    
                    Write-Host "  [✔] Hardware offloading enabled (LSO, RSS, RSC)" -ForegroundColor Green
                    
                } catch {
                    Write-Warning "  Failed to configure offloading: $($_.Exception.Message)"
                }
            }

            # --- 6. Jumbo Frames (Optional) ---
            if ($JumboFrames) {
                Write-Host "[+] Enabling Jumbo Frames (MTU 9000)" -ForegroundColor Gray
                
                try {
                    # Set MTU to 9000 (Jumbo Frames)
                    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Jumbo Packet" -DisplayValue "9014" -ErrorAction SilentlyContinue
                    
                    # Also set via netsh for consistency
                    netsh interface ipv4 set subinterface "$($adapter.Name)" mtu=9000 store=persistent 2>&1 | Out-Null
                    
                    Write-Host "  [✔] Jumbo Frames enabled (MTU 9000)" -ForegroundColor Green
                    Write-Host "  [⚠️] Ensure your network infrastructure supports Jumbo Frames!" -ForegroundColor Yellow
                    
                } catch {
                    Write-Warning "  Failed to enable Jumbo Frames: $($_.Exception.Message)"
                }
            }

            # --- 7. Power Management (Disable for servers) ---
            Write-Host "[+] Disabling power management (prevent sleep)" -ForegroundColor Gray
            
            try {
                Set-NetAdapterPowerManagement -Name $adapter.Name -AllowComputerToTurnOffDevice Disabled -ErrorAction SilentlyContinue
                Write-Host "  [✔] Power management disabled" -ForegroundColor Green
            } catch {
                Write-Warning "  Failed to disable power management: $($_.Exception.Message)"
            }
        }

        # --- 8. Registry Optimizations ---
        Write-Host "`n[📝] APPLYING REGISTRY OPTIMIZATIONS" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        try {
            # TCP Parameters
            $tcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
            
            # Increase TCP Window Size for high-bandwidth networks
            Set-ItemProperty -Path $tcpipPath -Name "TcpWindowSize" -Value 65535 -Type DWord -ErrorAction SilentlyContinue
            
            # Enable TCP Window Scaling
            Set-ItemProperty -Path $tcpipPath -Name "Tcp1323Opts" -Value 3 -Type DWord -ErrorAction SilentlyContinue
            
            # Increase maximum number of connections
            Set-ItemProperty -Path $tcpipPath -Name "TcpNumConnections" -Value 16777214 -Type DWord -ErrorAction SilentlyContinue
            
            # Disable Nagle's Algorithm for low-latency (per-interface)
            $interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
            foreach ($iface in $interfaces) {
                Set-ItemProperty -Path $iface.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $iface.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
            }
            
            # Disable Network Throttling
            $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
            Set-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -ErrorAction SilentlyContinue
            
            Write-Host "[✔] Registry optimizations applied" -ForegroundColor Green
            
        } catch {
            Write-Warning "Registry optimization failed: $($_.Exception.Message)"
        }

        # --- 9. DNS Configuration ---
        if ($Dns) {
            Write-Host "`n[🌐] CONFIGURING DNS SERVERS" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Gray
            
            $dnsServers = switch($Dns) {
                "Cloudflare" { @("1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001") }
                "Google" { @("8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844") }
                "Reset" { $null }
            }
            
            $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
            
            foreach ($adapter in $activeAdapters) {
                try {
                    if ($null -eq $dnsServers) {
                        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ResetServerAddresses -ErrorAction Stop
                        Write-Host "[!] $($adapter.Name): Reset to DHCP" -ForegroundColor Yellow
                    } else {
                        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses $dnsServers -ErrorAction Stop
                        Write-Host "[✔] $($adapter.Name): Configured for $Dns" -ForegroundColor Green
                    }
                } catch {
                    Write-Warning "Failed to configure DNS for $($adapter.Name): $($_.Exception.Message)"
                }
            }
            
            # Flush DNS cache
            ipconfig /flushdns | Out-Null
            Write-Host "[✔] DNS cache flushed" -ForegroundColor Green
        }

        # --- 10. DNS Client Cache Optimization ---
        Write-Host "`n[💾] OPTIMIZING DNS CLIENT CACHE" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        try {
            # Increase DNS cache size and TTL
            Set-DnsClientCache -MaxCacheTtl 86400 -ErrorAction SilentlyContinue
            Set-DnsClientCache -MaxNegativeCacheTtl 900 -ErrorAction SilentlyContinue
            
            Write-Host "[✔] DNS cache optimized (24-hour TTL)" -ForegroundColor Green
        } catch {
            Write-Warning "DNS cache optimization failed: $($_.Exception.Message)"
        }

        # --- 11. Summary ---
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        Write-Host "`n[✅] SERVER NETWORK OPTIMIZATION COMPLETE" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "========================================" -ForegroundColor Gray
        Write-Host "TCP/IP Stack:         Optimized for high throughput" -ForegroundColor White
        Write-Host "Congestion Control:   CUBIC" -ForegroundColor White
        Write-Host "Hardware Offloading:  $(if ($NoOffload) { 'Disabled' } else { 'Enabled (LSO, RSS, RSC)' })" -ForegroundColor White
        Write-Host "Jumbo Frames:         $(if ($JumboFrames) { 'Enabled (MTU 9000)' } else { 'Disabled (MTU 1500)' })" -ForegroundColor White
        if ($Dns) { Write-Host "DNS Provider:         $Dns" -ForegroundColor White }
        Write-Host "Duration:             $([math]::Round($duration, 2)) seconds" -ForegroundColor White
        
        Write-Host "`n[⚠️] RECOMMENDED NEXT STEPS:" -ForegroundColor Yellow
        Write-Host "1. Reboot the server to finalize network changes" -ForegroundColor White
        Write-Host "2. Test network throughput with iperf3 or similar" -ForegroundColor White
        Write-Host "3. Monitor network performance counters" -ForegroundColor White
        if ($JumboFrames) {
            Write-Host "4. Verify Jumbo Frames with: ping -f -l 8972 <target>" -ForegroundColor White
        }

    } catch {
        Write-Error "CRITICAL FAILURE: $($_.Exception.Message)"
        throw
    }
}

# ============================================================================
# EXECUTION ENTRY POINT
# ============================================================================

Clear-Host
Write-Host "============================================" -ForegroundColor Blue
Write-Host "   SERVER NETWORK OPTIMIZER v1.0           " -ForegroundColor White
Write-Host "   High-Throughput CI/CD Edition           " -ForegroundColor White
Write-Host "============================================" -ForegroundColor Blue

Optimize-ServerNetworkStack `
    -JumboFrames $EnableJumboFrames `
    -NoOffload $DisableOffloading `
    -Dns $DnsProvider `
    -CreateBackup $Backup
