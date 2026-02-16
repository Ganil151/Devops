<#
.SYNOPSIS
    Batch TCP Port Connectivity Testing Tool.

.DESCRIPTION
    Tests TCP port connectivity to multiple hosts and ports in parallel for fast
    firewall validation and network troubleshooting. Supports CSV input for bulk testing.

.PARAMETER Targets
    Array of targets in format "host:port" or CSV file path.

.PARAMETER Timeout
    Timeout in seconds per port test (default: 3).

.PARAMETER Parallel
    Enable parallel testing for faster execution.

.PARAMETER OutputFormat
    Output format: Console, JSON, or CSV.

.EXAMPLE
    .\Test-PortConnectivity.ps1 -Targets "github.com:443","google.com:80"
    Test specific host:port combinations.

.EXAMPLE
    .\Test-PortConnectivity.ps1 -Targets "C:\targets.csv" -Parallel -OutputFormat JSON
    Bulk test from CSV file with parallel execution.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, HelpMessage = "Targets (host:port or CSV file)")]
    [string[]]$Targets,

    [Parameter(HelpMessage = "Timeout in seconds")]
    [ValidateRange(1, 60)]
    [int]$Timeout = 3,

    [Parameter(HelpMessage = "Enable parallel testing")]
    [switch]$Parallel,

    [Parameter(HelpMessage = "Output format")]
    [ValidateSet("Console", "JSON", "CSV")]
    [string]$OutputFormat = "Console"
)

#Requires -Version 5.1

function Test-Port {
    param([string]$Host, [int]$Port, [int]$TimeoutSec)
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($Host, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne($TimeoutSec * 1000, $false)
        
        if ($wait) {
            try {
                $tcpClient.EndConnect($connect)
                $status = "Open"
            } catch {
                $status = "Filtered"
            }
        } else {
            $status = "Closed"
        }
        
        $tcpClient.Close()
        
        return @{
            Host = $Host
            Port = $Port
            Status = $status
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    } catch {
        return @{
            Host = $Host
            Port = $Port
            Status = "Error"
            Error = $_.Exception.Message
        }
    }
}

# Parse targets
$targetList = @()

if ($Targets.Count -eq 1 -and (Test-Path $Targets[0])) {
    # CSV file
    $targetList = Import-Csv -Path $Targets[0] | ForEach-Object { "$($_.Host):$($_.Port)" }
} else {
    $targetList = $Targets
}

# Test ports
$results = @()

if ($Parallel) {
    $results = $targetList | ForEach-Object -Parallel {
        $parts = $_ -split ':'
        Test-Port -Host $parts[0] -Port $parts[1] -TimeoutSec $using:Timeout
    } -ThrottleLimit 10
} else {
    foreach ($target in $targetList) {
        $parts = $target -split ':'
        $results += Test-Port -Host $parts[0] -Port $parts[1] -TimeoutSec $Timeout
    }
}

# Output
switch ($OutputFormat) {
    "JSON" { $results | ConvertTo-Json -Depth 5 }
    "CSV" { $results | Export-Csv -Path "port-test-results.csv" -NoTypeInformation; Write-Host "[✔] Results saved to port-test-results.csv" }
    "Console" {
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "   PORT CONNECTIVITY TEST RESULTS" -ForegroundColor White
        Write-Host "========================================" -ForegroundColor Cyan
        
        foreach ($result in $results) {
            $color = switch ($result.Status) {
                "Open" { "Green" }
                "Closed" { "Yellow" }
                default { "Red" }
            }
            Write-Host "$($result.Host):$($result.Port) - " -NoNewline
            Write-Host $result.Status -ForegroundColor $color
        }
        
        $openCount = ($results | Where-Object { $_.Status -eq "Open" }).Count
        Write-Host "`nOpen Ports: $openCount/$($results.Count)" -ForegroundColor White
        Write-Host "========================================`n" -ForegroundColor Cyan
    }
}
