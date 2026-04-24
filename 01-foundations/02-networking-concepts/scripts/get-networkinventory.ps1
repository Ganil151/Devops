<#
.SYNOPSIS
    Network Configuration Inventory and Documentation Tool.

.DESCRIPTION
    Comprehensive network configuration documentation tool that captures all network
    settings, adapters, routes, DNS, proxy, VPN, and firewall configurations. Exports
    to multiple formats for documentation, auditing, and troubleshooting purposes.

.PARAMETER OutputFormat
    Output format: Console, JSON, CSV, or HTML (default: Console).

.PARAMETER OutputPath
    File path for JSON/CSV/HTML output.

.PARAMETER IncludeRoutes
    Include routing table in inventory.

.PARAMETER IncludeARP
    Include ARP cache in inventory.

.EXAMPLE
    .\Get-NetworkInventory.ps1
    Display network inventory in console.

.EXAMPLE
    .\Get-NetworkInventory.ps1 -OutputFormat JSON -OutputPath "C:\Reports\network-inventory.json"
    Export complete inventory to JSON.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard)
    Target: Windows 10/11, Windows Server 2019/2022
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Output format")]
    [ValidateSet("Console", "JSON", "CSV", "HTML")]
    [string]$OutputFormat = "Console",

    [Parameter(HelpMessage = "Output file path")]
    [string]$OutputPath,

    [Parameter(HelpMessage = "Include routing table")]
    [switch]$IncludeRoutes,

    [Parameter(HelpMessage = "Include ARP cache")]
    [switch]$IncludeARP
)

#Requires -Version 5.1

function Get-NetworkInventory {
    $inventory = @{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Hostname = $env:COMPUTERNAME
        Domain = $env:USERDNSDOMAIN
    }

    # Network Adapters
    $adapters = Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed, InterfaceDescription
    $inventory.Adapters = @()
    
    foreach ($adapter in $adapters) {
        $ipConfig = Get-NetIPAddress -InterfaceAlias $adapter.Name -ErrorAction SilentlyContinue
        $dnsServers = Get-DnsClientServerAddress -InterfaceAlias $adapter.Name -ErrorAction SilentlyContinue
        $gateway = Get-NetRoute -InterfaceAlias $adapter.Name -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
        
        $inventory.Adapters += @{
            Name = $adapter.Name
            Status = $adapter.Status
            MAC = $adapter.MacAddress
            LinkSpeed = $adapter.LinkSpeed
            IPv4 = ($ipConfig | Where-Object { $_.AddressFamily -eq "IPv4" }).IPAddress
            IPv6 = ($ipConfig | Where-Object { $_.AddressFamily -eq "IPv6" }).IPAddress
            DNS = $dnsServers.ServerAddresses
            Gateway = $gateway.NextHop
        }
    }

    # Routing Table
    if ($IncludeRoutes) {
        $inventory.Routes = Get-NetRoute | Select-Object DestinationPrefix, NextHop, InterfaceAlias, RouteMetric
    }

    # ARP Cache
    if ($IncludeARP) {
        $inventory.ARP = Get-NetNeighbor | Select-Object IPAddress, LinkLayerAddress, State
    }

    # Firewall Profiles
    $inventory.Firewall = Get-NetFirewallProfile | Select-Object Name, Enabled

    # Proxy Settings
    $proxy = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -ErrorAction SilentlyContinue
    $inventory.Proxy = @{
        Enabled = $proxy.ProxyEnable -eq 1
        Server = $proxy.ProxyServer
    }

    # VPN Connections
    $inventory.VPN = Get-VpnConnection -AllUserConnection -ErrorAction SilentlyContinue | Select-Object Name, ServerAddress, ConnectionStatus

    return $inventory
}

$results = Get-NetworkInventory

# Output
if ($OutputPath) {
    switch ($OutputFormat) {
        "JSON" { $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8 }
        "CSV" { $results.Adapters | Export-Csv -Path $OutputPath -NoTypeInformation }
        "HTML" {
            $html = $results | ConvertTo-Html -Title "Network Inventory"
            $html | Out-File -FilePath $OutputPath -Encoding UTF8
        }
    }
    Write-Host "[✔] Inventory exported to: $OutputPath" -ForegroundColor Green
} else {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "   NETWORK INVENTORY" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Hostname: $($results.Hostname)" -ForegroundColor White
    Write-Host "Timestamp: $($results.Timestamp)" -ForegroundColor White
    
    Write-Host "`n[NETWORK ADAPTERS]" -ForegroundColor Cyan
    foreach ($adapter in $results.Adapters) {
        Write-Host "`n$($adapter.Name) [$($adapter.Status)]" -ForegroundColor Yellow
        Write-Host "  MAC: $($adapter.MAC)" -ForegroundColor White
        Write-Host "  IPv4: $($adapter.IPv4 -join ', ')" -ForegroundColor White
        Write-Host "  DNS: $($adapter.DNS -join ', ')" -ForegroundColor White
        Write-Host "  Gateway: $($adapter.Gateway)" -ForegroundColor White
    }
    
    Write-Host "`n========================================`n" -ForegroundColor Cyan
}
