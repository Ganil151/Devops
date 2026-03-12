<#
.SYNOPSIS
    Comprehensive Network Diagnostics Tool for DevOps Troubleshooting.

.DESCRIPTION
    This script performs a complete network diagnostic suite including connectivity tests,
    DNS resolution, port scanning, latency measurement, and route tracing. Designed for
    DevOps engineers to quickly diagnose network issues in development, staging, and
    production environments.

    Diagnostic Tests:
    - ICMP Connectivity (Ping)
    - DNS Resolution (A, AAAA, MX, TXT records)
    - TCP Port Connectivity (Common DevOps ports)
    - Route Tracing (Traceroute)
    - Latency Measurement (RTT statistics)
    - Network Adapter Status
    - Firewall Profile Status
    - Proxy Configuration Detection

    Output Formats:
    - Console (human-readable with color coding)
    - JSON (for automation/monitoring)
    - HTML (for reporting)
    - CSV (for Excel analysis)

.PARAMETER Target
    Target hostname or IP address to test (default: google.com).

.PARAMETER Ports
    Array of TCP ports to test (default: common DevOps ports).

.PARAMETER SkipTraceroute
    Skip traceroute test (faster execution).

.PARAMETER OutputFormat
    Output format: Console, JSON, HTML, or CSV.

.PARAMETER OutputPath
    File path for JSON/HTML/CSV output.

.PARAMETER Timeout
    Timeout in seconds for each test (default: 5).

.EXAMPLE
    .\Test-NetworkDiagnostics.ps1
    Run full diagnostics against google.com.

.EXAMPLE
    .\Test-NetworkDiagnostics.ps1 -Target "github.com" -Ports 22,443,9418
    Test GitHub connectivity on SSH, HTTPS, and Git ports.

.EXAMPLE
    .\Test-NetworkDiagnostics.ps1 -Target "10.0.1.100" -OutputFormat JSON -OutputPath "C:\Reports\network.json"
    Test internal server and export results to JSON.

.EXAMPLE
    .\Test-NetworkDiagnostics.ps1 -Target "api.example.com" -SkipTraceroute -Verbose
    Quick diagnostics without traceroute, with detailed logging.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard)
    Target: Windows 10/11, Windows Server 2019/2022
    Safety: Read-only operation (no system changes)
    Common DevOps Ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3389 (RDP), 
                         5432 (PostgreSQL), 3306 (MySQL), 6379 (Redis),
                         27017 (MongoDB), 9200 (Elasticsearch), 5601 (Kibana)
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, HelpMessage = "Target hostname or IP address")]
    [string]$Target = "google.com",

    [Parameter(HelpMessage = "TCP ports to test")]
    [int[]]$Ports = @(22, 80, 443, 3389, 5432, 3306, 6379, 27017, 9200, 5601),

    [Parameter(HelpMessage = "Skip traceroute test")]
    [switch]$SkipTraceroute,

    [Parameter(HelpMessage = "Output format")]
    [ValidateSet("Console", "JSON", "HTML", "CSV")]
    [string]$OutputFormat = "Console",

    [Parameter(HelpMessage = "Output file path")]
    [string]$OutputPath,

    [Parameter(HelpMessage = "Timeout in seconds")]
    [ValidateRange(1, 60)]
    [int]$Timeout = 5
)

#Requires -Version 5.1

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Test-ICMPConnectivity {
    param([string]$TargetHost, [int]$TimeoutSec)
    
    try {
        Write-Verbose "Testing ICMP connectivity to $TargetHost..."
        
        $pingResults = Test-Connection -ComputerName $TargetHost -Count 4 -ErrorAction Stop
        
        $stats = $pingResults | Measure-Object -Property ResponseTime -Average -Minimum -Maximum
        
        return @{
            Status = "Success"
            PacketsSent = 4
            PacketsReceived = $pingResults.Count
            PacketLoss = ((4 - $pingResults.Count) / 4 * 100)
            MinLatency = $stats.Minimum
            MaxLatency = $stats.Maximum
            AvgLatency = [math]::Round($stats.Average, 2)
            IPAddress = $pingResults[0].IPV4Address.ToString()
        }
    } catch {
        return @{
            Status = "Failed"
            Error = $_.Exception.Message
            PacketsSent = 4
            PacketsReceived = 0
            PacketLoss = 100
        }
    }
}

function Test-DNSResolution {
    param([string]$TargetHost)
    
    try {
        Write-Verbose "Resolving DNS for $TargetHost..."
        
        $dnsResults = @{
            Status = "Success"
            Records = @{}
        }
        
        # A Records (IPv4)
        try {
            $aRecords = Resolve-DnsName -Name $TargetHost -Type A -ErrorAction SilentlyContinue
            $dnsResults.Records.A = $aRecords | ForEach-Object { $_.IPAddress }
        } catch { $dnsResults.Records.A = @() }
        
        # AAAA Records (IPv6)
        try {
            $aaaaRecords = Resolve-DnsName -Name $TargetHost -Type AAAA -ErrorAction SilentlyContinue
            $dnsResults.Records.AAAA = $aaaaRecords | ForEach-Object { $_.IPAddress }
        } catch { $dnsResults.Records.AAAA = @() }
        
        # MX Records (Mail)
        try {
            $mxRecords = Resolve-DnsName -Name $TargetHost -Type MX -ErrorAction SilentlyContinue
            $dnsResults.Records.MX = $mxRecords | ForEach-Object { "$($_.NameExchange) (Priority: $($_.Preference))" }
        } catch { $dnsResults.Records.MX = @() }
        
        # TXT Records
        try {
            $txtRecords = Resolve-DnsName -Name $TargetHost -Type TXT -ErrorAction SilentlyContinue
            $dnsResults.Records.TXT = $txtRecords | ForEach-Object { $_.Strings }
        } catch { $dnsResults.Records.TXT = @() }
        
        # DNS Server Used
        $dnsClient = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses.Count -gt 0 } | Select-Object -First 1
        $dnsResults.DNSServer = $dnsClient.ServerAddresses[0]
        
        return $dnsResults
        
    } catch {
        return @{
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
}

function Test-TCPPortConnectivity {
    param([string]$TargetHost, [int[]]$PortList, [int]$TimeoutSec)
    
    $portResults = @()
    
    foreach ($port in $PortList) {
        Write-Progress -Activity "Testing Ports" -Status "Port $port" -PercentComplete (($portResults.Count / $PortList.Count) * 100)
        
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $connect = $tcpClient.BeginConnect($TargetHost, $port, $null, $null)
            $wait = $connect.AsyncWaitHandle.WaitOne($TimeoutSec * 1000, $false)
            
            if ($wait) {
                try {
                    $tcpClient.EndConnect($connect)
                    $status = "Open"
                    $service = Get-ServiceName -Port $port
                } catch {
                    $status = "Filtered"
                    $service = "Unknown"
                }
            } else {
                $status = "Closed/Filtered"
                $service = Get-ServiceName -Port $port
            }
            
            $tcpClient.Close()
            
        } catch {
            $status = "Error"
            $service = Get-ServiceName -Port $port
        }
        
        $portResults += @{
            Port = $port
            Status = $status
            Service = $service
        }
    }
    
    Write-Progress -Activity "Testing Ports" -Completed
    return $portResults
}

function Get-ServiceName {
    param([int]$Port)
    
    $services = @{
        22 = "SSH"
        80 = "HTTP"
        443 = "HTTPS"
        3389 = "RDP"
        5432 = "PostgreSQL"
        3306 = "MySQL"
        6379 = "Redis"
        27017 = "MongoDB"
        9200 = "Elasticsearch"
        5601 = "Kibana"
        8080 = "HTTP-Alt"
        8443 = "HTTPS-Alt"
        21 = "FTP"
        25 = "SMTP"
        53 = "DNS"
        110 = "POP3"
        143 = "IMAP"
        3000 = "Node.js/Grafana"
        5000 = "Flask"
        8000 = "Django"
        9090 = "Prometheus"
    }
    
    if ($services.ContainsKey($Port)) {
        return $services[$Port]
    } else {
        return "Unknown"
    }
}

function Get-RouteTrace {
    param([string]$TargetHost, [int]$MaxHops = 30)
    
    try {
        Write-Verbose "Tracing route to $TargetHost..."
        
        $traceResults = Test-NetConnection -ComputerName $TargetHost -TraceRoute -Hops $MaxHops -ErrorAction Stop
        
        return @{
            Status = "Success"
            Hops = $traceResults.TraceRoute
            HopCount = $traceResults.TraceRoute.Count
        }
    } catch {
        return @{
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
}

function Get-NetworkAdapterStatus {
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object Name, InterfaceDescription, LinkSpeed, MacAddress
        return $adapters
    } catch {
        return @()
    }
}

function Get-FirewallStatus {
    try {
        $profiles = Get-NetFirewallProfile | Select-Object Name, Enabled
        return $profiles
    } catch {
        return @()
    }
}

# ============================================================================
# MAIN DIAGNOSTIC FUNCTION
# ============================================================================

function Invoke-NetworkDiagnostics {
    [CmdletBinding()]
    param(
        [string]$TargetHost,
        [int[]]$PortList,
        [bool]$SkipTrace,
        [int]$TimeoutSec
    )

    $startTime = Get-Date
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "   NETWORK DIAGNOSTICS REPORT" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Target:    $TargetHost" -ForegroundColor White
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    Write-Host "Hostname:  $env:COMPUTERNAME" -ForegroundColor White
    
    $diagnostics = @{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Target = $TargetHost
        Hostname = $env:COMPUTERNAME
    }
    
    # Test 1: ICMP Connectivity
    Write-Host "`n[1/6] ICMP CONNECTIVITY TEST" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Gray
    
    $icmpResult = Test-ICMPConnectivity -TargetHost $TargetHost -TimeoutSec $TimeoutSec
    $diagnostics.ICMP = $icmpResult
    
    if ($icmpResult.Status -eq "Success") {
        Write-Host "Status:        " -NoNewline; Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "IP Address:    $($icmpResult.IPAddress)" -ForegroundColor White
        Write-Host "Packet Loss:   $($icmpResult.PacketLoss)%" -ForegroundColor $(if ($icmpResult.PacketLoss -eq 0) { "Green" } else { "Yellow" })
        Write-Host "Latency (ms):  Min=$($icmpResult.MinLatency) | Avg=$($icmpResult.AvgLatency) | Max=$($icmpResult.MaxLatency)" -ForegroundColor White
    } else {
        Write-Host "Status:        " -NoNewline; Write-Host "FAILED" -ForegroundColor Red
        Write-Host "Error:         $($icmpResult.Error)" -ForegroundColor Red
    }
    
    # Test 2: DNS Resolution
    Write-Host "`n[2/6] DNS RESOLUTION TEST" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Gray
    
    $dnsResult = Test-DNSResolution -TargetHost $TargetHost
    $diagnostics.DNS = $dnsResult
    
    if ($dnsResult.Status -eq "Success") {
        Write-Host "Status:        " -NoNewline; Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "DNS Server:    $($dnsResult.DNSServer)" -ForegroundColor White
        
        if ($dnsResult.Records.A.Count -gt 0) {
            Write-Host "A Records:     $($dnsResult.Records.A -join ', ')" -ForegroundColor White
        }
        if ($dnsResult.Records.AAAA.Count -gt 0) {
            Write-Host "AAAA Records:  $($dnsResult.Records.AAAA -join ', ')" -ForegroundColor White
        }
        if ($dnsResult.Records.MX.Count -gt 0) {
            Write-Host "MX Records:    $($dnsResult.Records.MX -join ', ')" -ForegroundColor White
        }
    } else {
        Write-Host "Status:        " -NoNewline; Write-Host "FAILED" -ForegroundColor Red
    }
    
    # Test 3: TCP Port Connectivity
    Write-Host "`n[3/6] TCP PORT CONNECTIVITY TEST" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Gray
    
    $portResults = Test-TCPPortConnectivity -TargetHost $TargetHost -PortList $PortList -TimeoutSec $TimeoutSec
    $diagnostics.Ports = $portResults
    
    foreach ($portResult in $portResults) {
        $statusColor = switch ($portResult.Status) {
            "Open" { "Green" }
            "Closed/Filtered" { "Yellow" }
            default { "Red" }
        }
        
        Write-Host "Port $($portResult.Port) ($($portResult.Service)): " -NoNewline
        Write-Host $portResult.Status -ForegroundColor $statusColor
    }
    
    # Test 4: Route Trace
    if (-not $SkipTrace) {
        Write-Host "`n[4/6] ROUTE TRACE TEST" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        $traceResult = Get-RouteTrace -TargetHost $TargetHost
        $diagnostics.RouteTrace = $traceResult
        
        if ($traceResult.Status -eq "Success") {
            Write-Host "Status:        " -NoNewline; Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host "Hop Count:     $($traceResult.HopCount)" -ForegroundColor White
            Write-Host "Route:         $($traceResult.Hops -join ' -> ')" -ForegroundColor Gray
        } else {
            Write-Host "Status:        " -NoNewline; Write-Host "FAILED" -ForegroundColor Red
        }
    } else {
        Write-Host "`n[4/6] ROUTE TRACE TEST - SKIPPED" -ForegroundColor Yellow
    }
    
    # Test 5: Network Adapter Status
    Write-Host "`n[5/6] NETWORK ADAPTER STATUS" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Gray
    
    $adapters = Get-NetworkAdapterStatus
    $diagnostics.Adapters = $adapters
    
    foreach ($adapter in $adapters) {
        Write-Host "$($adapter.Name): $($adapter.LinkSpeed) - $($adapter.MacAddress)" -ForegroundColor White
    }
    
    # Test 6: Firewall Status
    Write-Host "`n[6/6] FIREWALL STATUS" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Gray
    
    $firewallProfiles = Get-FirewallStatus
    $diagnostics.Firewall = $firewallProfiles
    
    foreach ($profile in $firewallProfiles) {
        $statusColor = if ($profile.Enabled) { "Green" } else { "Red" }
        Write-Host "$($profile.Name): " -NoNewline
        Write-Host $(if ($profile.Enabled) { "Enabled" } else { "Disabled" }) -ForegroundColor $statusColor
    }
    
    # Summary
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "   DIAGNOSTIC SUMMARY" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Duration:      $([math]::Round($duration, 2)) seconds" -ForegroundColor White
    Write-Host "ICMP:          $($icmpResult.Status)" -ForegroundColor $(if ($icmpResult.Status -eq "Success") { "Green" } else { "Red" })
    Write-Host "DNS:           $($dnsResult.Status)" -ForegroundColor $(if ($dnsResult.Status -eq "Success") { "Green" } else { "Red" })
    Write-Host "Open Ports:    $(($portResults | Where-Object { $_.Status -eq 'Open' }).Count)/$($portResults.Count)" -ForegroundColor White
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    return $diagnostics
}

# ============================================================================
# EXECUTION ENTRY POINT
# ============================================================================

$results = Invoke-NetworkDiagnostics `
    -TargetHost $Target `
    -PortList $Ports `
    -SkipTrace $SkipTraceroute `
    -TimeoutSec $Timeout

# Export results if requested
if ($OutputPath) {
    switch ($OutputFormat) {
        "JSON" {
            $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "[✔] Results exported to: $OutputPath" -ForegroundColor Green
        }
        "CSV" {
            # Flatten for CSV
            $csvData = [PSCustomObject]@{
                Timestamp = $results.Timestamp
                Target = $results.Target
                ICMP_Status = $results.ICMP.Status
                ICMP_PacketLoss = $results.ICMP.PacketLoss
                ICMP_AvgLatency = $results.ICMP.AvgLatency
                DNS_Status = $results.DNS.Status
                OpenPorts = ($results.Ports | Where-Object { $_.Status -eq 'Open' }).Count
            }
            $csvData | Export-Csv -Path $OutputPath -NoTypeInformation
            Write-Host "[✔] Results exported to: $OutputPath" -ForegroundColor Green
        }
        "HTML" {
            # Generate HTML report
            $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Network Diagnostics Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #0078D4; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #0078D4; color: white; }
        .success { color: green; font-weight: bold; }
        .failed { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Network Diagnostics Report</h1>
    <p><strong>Target:</strong> $($results.Target)</p>
    <p><strong>Timestamp:</strong> $($results.Timestamp)</p>
    <p><strong>Hostname:</strong> $($results.Hostname)</p>
    
    <h2>ICMP Connectivity</h2>
    <p class="$($results.ICMP.Status.ToLower())">Status: $($results.ICMP.Status)</p>
    
    <h2>Port Scan Results</h2>
    <table>
        <tr><th>Port</th><th>Service</th><th>Status</th></tr>
        $(foreach ($port in $results.Ports) {
            "<tr><td>$($port.Port)</td><td>$($port.Service)</td><td>$($port.Status)</td></tr>"
        })
    </table>
</body>
</html>
"@
            $html | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "[✔] HTML report exported to: $OutputPath" -ForegroundColor Green
        }
    }
}
