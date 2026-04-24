<#
.SYNOPSIS
    DNS Troubleshooting and Resolution Tool.

.DESCRIPTION
    Automated DNS troubleshooting tool that diagnoses and resolves common DNS issues
    including cache problems, server connectivity, and propagation delays.

.PARAMETER Target
    Target domain to troubleshoot.

.PARAMETER FlushCache
    Flush DNS cache before testing.

.PARAMETER TestServers
    Test multiple DNS servers (Cloudflare, Google, OpenDNS).

.EXAMPLE
    .\Resolve-DNSIssues.ps1 -Target "example.com" -FlushCache
    Troubleshoot DNS for example.com with cache flush.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, HelpMessage = "Target domain")]
    [string]$Target,

    [Parameter(HelpMessage = "Flush DNS cache")]
    [switch]$FlushCache,

    [Parameter(HelpMessage = "Test multiple DNS servers")]
    [switch]$TestServers
)

#Requires -Version 5.1

if ($FlushCache) {
    Write-Host "[🔄] Flushing DNS cache..." -ForegroundColor Cyan
    ipconfig /flushdns | Out-Null
    Write-Host "[✔] DNS cache flushed" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   DNS TROUBLESHOOTING REPORT" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Target: $Target" -ForegroundColor White

# Test current DNS
Write-Host "`n[1] Testing Current DNS Configuration" -ForegroundColor Cyan
try {
    $currentDNS = Resolve-DnsName -Name $Target -ErrorAction Stop
    Write-Host "[✔] Resolution successful" -ForegroundColor Green
    Write-Host "IP Addresses: $($currentDNS.IPAddress -join ', ')" -ForegroundColor White
} catch {
    Write-Host "[✘] Resolution failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test alternative DNS servers
if ($TestServers) {
    Write-Host "`n[2] Testing Alternative DNS Servers" -ForegroundColor Cyan
    
    $dnsServers = @{
        "Cloudflare" = "1.1.1.1"
        "Google" = "8.8.8.8"
        "OpenDNS" = "208.67.222.222"
    }
    
    foreach ($server in $dnsServers.GetEnumerator()) {
        try {
            $result = Resolve-DnsName -Name $Target -Server $server.Value -ErrorAction Stop
            Write-Host "[✔] $($server.Key): $($result.IPAddress -join ', ')" -ForegroundColor Green
        } catch {
            Write-Host "[✘] $($server.Key): Failed" -ForegroundColor Red
        }
    }
}

# Check DNS cache
Write-Host "`n[3] DNS Cache Analysis" -ForegroundColor Cyan
$cache = Get-DnsClientCache -Name "*$Target*" -ErrorAction SilentlyContinue
if ($cache) {
    Write-Host "Cached entries found: $($cache.Count)" -ForegroundColor White
} else {
    Write-Host "No cached entries" -ForegroundColor Yellow
}

# Recommendations
Write-Host "`n[RECOMMENDATIONS]" -ForegroundColor Cyan
Write-Host "1. If resolution fails, try flushing DNS cache: ipconfig /flushdns" -ForegroundColor White
Write-Host "2. Consider using alternative DNS (Cloudflare: 1.1.1.1)" -ForegroundColor White
Write-Host "3. Check firewall rules for port 53 (DNS)" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan
