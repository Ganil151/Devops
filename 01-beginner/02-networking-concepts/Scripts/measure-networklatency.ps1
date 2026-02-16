<#
.SYNOPSIS
    Network Latency Measurement and Monitoring Tool.

.DESCRIPTION
    Continuous network latency monitoring with jitter calculation, packet loss tracking,
    and Grafana-compatible JSON export for DevOps observability.

.PARAMETER Target
    Target host to monitor.

.PARAMETER Duration
    Monitoring duration in seconds (default: 60).

.PARAMETER Interval
    Ping interval in seconds (default: 1).

.PARAMETER OutputPath
    JSON output path for Grafana integration.

.EXAMPLE
    .\Measure-NetworkLatency.ps1 -Target "api.example.com" -Duration 300
    Monitor latency for 5 minutes.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, HelpMessage = "Target host")]
    [string]$Target,

    [Parameter(HelpMessage = "Duration in seconds")]
    [int]$Duration = 60,

    [Parameter(HelpMessage = "Ping interval in seconds")]
    [int]$Interval = 1,

    [Parameter(HelpMessage = "JSON output path")]
    [string]$OutputPath
)

#Requires -Version 5.1

$measurements = @()
$startTime = Get-Date
$endTime = $startTime.AddSeconds($Duration)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   NETWORK LATENCY MONITORING" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Target: $Target" -ForegroundColor White
Write-Host "Duration: $Duration seconds" -ForegroundColor White
Write-Host "Interval: $Interval second(s)" -ForegroundColor White
Write-Host "Start Time: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

while ((Get-Date) -lt $endTime) {
    try {
        $ping = Test-Connection -ComputerName $Target -Count 1 -ErrorAction Stop
        $latency = $ping.ResponseTime
        
        $measurements += @{
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            Latency = $latency
            Status = "Success"
        }
        
        $color = if ($latency -lt 50) { "Green" } elseif ($latency -lt 100) { "Yellow" } else { "Red" }
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] Latency: $latency ms" -ForegroundColor $color
        
    } catch {
        $measurements += @{
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            Latency = $null
            Status = "Failed"
        }
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] Packet lost" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds $Interval
}

# Calculate statistics
$successfulPings = $measurements | Where-Object { $_.Status -eq "Success" }
$latencies = $successfulPings | ForEach-Object { $_.Latency }

if ($latencies.Count -gt 0) {
    $stats = $latencies | Measure-Object -Average -Minimum -Maximum
    $jitter = if ($latencies.Count -gt 1) {
        ($latencies | ForEach-Object { [Math]::Abs($_ - $stats.Average) } | Measure-Object -Average).Average
    } else { 0 }
    
    $packetLoss = (($measurements.Count - $successfulPings.Count) / $measurements.Count) * 100
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "   LATENCY STATISTICS" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Packets Sent: $($measurements.Count)" -ForegroundColor White
    Write-Host "Packets Received: $($successfulPings.Count)" -ForegroundColor White
    Write-Host "Packet Loss: $([math]::Round($packetLoss, 2))%" -ForegroundColor $(if ($packetLoss -eq 0) { "Green" } else { "Red" })
    Write-Host "Min Latency: $($stats.Minimum) ms" -ForegroundColor White
    Write-Host "Avg Latency: $([math]::Round($stats.Average, 2)) ms" -ForegroundColor White
    Write-Host "Max Latency: $($stats.Maximum) ms" -ForegroundColor White
    Write-Host "Jitter: $([math]::Round($jitter, 2)) ms" -ForegroundColor White
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    if ($OutputPath) {
        $report = @{
            Target = $Target
            StartTime = $startTime.ToString("yyyy-MM-dd HH:mm:ss")
            EndTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            PacketsSent = $measurements.Count
            PacketsReceived = $successfulPings.Count
            PacketLoss = [math]::Round($packetLoss, 2)
            MinLatency = $stats.Minimum
            AvgLatency = [math]::Round($stats.Average, 2)
            MaxLatency = $stats.Maximum
            Jitter = [math]::Round($jitter, 2)
            Measurements = $measurements
        }
        
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "[✔] Report exported to: $OutputPath" -ForegroundColor Green
    }
}
