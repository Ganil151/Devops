<#
.SYNOPSIS
    System Health Monitoring Script with JSON Export for Grafana/Jenkins Integration.

.DESCRIPTION
    This script collects comprehensive system health metrics (CPU, RAM, Disk, Network)
    and exports them in JSON format for consumption by monitoring platforms like
    Grafana, Prometheus, Jenkins, or custom dashboards. Designed for unattended
    execution via scheduled tasks or CI/CD pipeline health checks.

    Metrics Collected:
    - CPU: Utilization %, core count, frequency
    - Memory: Total, used, available, page file usage
    - Disk: Free space, queue length, IOPS, latency
    - Network: Throughput, packet errors, TCP connections
    - System: Uptime, process count, handle count
    - Services: Critical service status (optional)
    - Docker: Container count and status (if installed)

    Output Formats:
    - JSON (default): For API consumption
    - Console: Human-readable summary
    - CSV: For Excel/spreadsheet analysis
    - InfluxDB Line Protocol: For direct Telegraf ingestion

.PARAMETER OutputFormat
    Output format: JSON, Console, CSV, or InfluxDB.

.PARAMETER OutputPath
    File path for JSON/CSV output (default: console output).

.PARAMETER IncludeServices
    Include critical service status in health report.

.PARAMETER IncludeDocker
    Include Docker container metrics (if Docker is installed).

.PARAMETER ThresholdWarning
    Health score threshold for WARNING status (default: 70).

.PARAMETER ThresholdCritical
    Health score threshold for CRITICAL status (default: 50).

.EXAMPLE
    .\Get-SystemHealthScore.ps1
    Display health metrics in console (human-readable).

.EXAMPLE
    .\Get-SystemHealthScore.ps1 -OutputFormat JSON -OutputPath "C:\Metrics\health.json"
    Export metrics to JSON file for Grafana consumption.

.EXAMPLE
    .\Get-SystemHealthScore.ps1 -OutputFormat InfluxDB -IncludeDocker
    Generate InfluxDB line protocol with Docker metrics.

.EXAMPLE
    .\Get-SystemHealthScore.ps1 -IncludeServices -Verbose
    Display detailed health report with service status.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard)
    Target: All Windows environments (Server + Workstation)
    Safety: Read-only operation (no system changes)
    Idempotency: N/A (monitoring script)
    Integration: Grafana, Prometheus, Jenkins, Azure Monitor
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Output format for metrics")]
    [ValidateSet("JSON", "Console", "CSV", "InfluxDB")]
    [string]$OutputFormat = "Console",

    [Parameter(HelpMessage = "Output file path (for JSON/CSV)")]
    [string]$OutputPath,

    [Parameter(HelpMessage = "Include critical service status")]
    [switch]$IncludeServices,

    [Parameter(HelpMessage = "Include Docker container metrics")]
    [switch]$IncludeDocker,

    [Parameter(HelpMessage = "Warning threshold (0-100)")]
    [ValidateRange(0, 100)]
    [int]$ThresholdWarning = 70,

    [Parameter(HelpMessage = "Critical threshold (0-100)")]
    [ValidateRange(0, 100)]
    [int]$ThresholdCritical = 50
)

#Requires -Version 5.1

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Get-CPUMetrics {
    try {
        $cpu = Get-CimInstance Win32_Processor
        $perfCPU = Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue
        
        return @{
            Name = $cpu.Name
            Cores = $cpu.NumberOfCores
            LogicalProcessors = $cpu.NumberOfLogicalProcessors
            CurrentClockSpeed = $cpu.CurrentClockSpeed
            MaxClockSpeed = $cpu.MaxClockSpeed
            Utilization = [math]::Round($perfCPU.CounterSamples[0].CookedValue, 2)
            LoadPercentage = $cpu.LoadPercentage
        }
    } catch {
        Write-Warning "Failed to collect CPU metrics: $($_.Exception.Message)"
        return $null
    }
}

function Get-MemoryMetrics {
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $usedRAM = $totalRAM - $freeRAM
        
        $pageFile = Get-CimInstance Win32_PageFileUsage
        
        return @{
            TotalGB = $totalRAM
            UsedGB = $usedRAM
            FreeGB = $freeRAM
            UsagePercent = [math]::Round(($usedRAM / $totalRAM) * 100, 2)
            PageFileTotalMB = if ($pageFile) { $pageFile.AllocatedBaseSize } else { 0 }
            PageFileUsedMB = if ($pageFile) { $pageFile.CurrentUsage } else { 0 }
        }
    } catch {
        Write-Warning "Failed to collect memory metrics: $($_.Exception.Message)"
        return $null
    }
}

function Get-DiskMetrics {
    try {
        $disks = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null }
        $diskMetrics = @()
        
        foreach ($disk in $disks) {
            $totalGB = [math]::Round(($disk.Used + $disk.Free) / 1GB, 2)
            $usedGB = [math]::Round($disk.Used / 1GB, 2)
            $freeGB = [math]::Round($disk.Free / 1GB, 2)
            
            # Get disk queue length
            $queueLength = 0
            try {
                $perfDisk = Get-Counter "\PhysicalDisk(*)\Avg. Disk Queue Length" -ErrorAction SilentlyContinue
                $queueLength = [math]::Round(($perfDisk.CounterSamples | Measure-Object -Property CookedValue -Average).Average, 2)
            } catch { }
            
            $diskMetrics += @{
                Drive = $disk.Name
                TotalGB = $totalGB
                UsedGB = $usedGB
                FreeGB = $freeGB
                UsagePercent = [math]::Round(($usedGB / $totalGB) * 100, 2)
                QueueLength = $queueLength
            }
        }
        
        return $diskMetrics
    } catch {
        Write-Warning "Failed to collect disk metrics: $($_.Exception.Message)"
        return $null
    }
}

function Get-NetworkMetrics {
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        $networkMetrics = @()
        
        foreach ($adapter in $adapters) {
            try {
                $stats = Get-NetAdapterStatistics -Name $adapter.Name -ErrorAction SilentlyContinue
                
                $networkMetrics += @{
                    Name = $adapter.Name
                    LinkSpeed = $adapter.LinkSpeed
                    ReceivedBytes = $stats.ReceivedBytes
                    SentBytes = $stats.SentBytes
                    ReceivedPackets = $stats.ReceivedUnicastPackets
                    SentPackets = $stats.SentUnicastPackets
                }
            } catch { }
        }
        
        # TCP connection count
        $tcpConnections = (Get-NetTCPConnection -ErrorAction SilentlyContinue | Measure-Object).Count
        
        return @{
            Adapters = $networkMetrics
            TCPConnections = $tcpConnections
        }
    } catch {
        Write-Warning "Failed to collect network metrics: $($_.Exception.Message)"
        return $null
    }
}

function Get-SystemMetrics {
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $uptime = (Get-Date) - $os.LastBootUpTime
        
        $processes = Get-Process
        $processCount = ($processes | Measure-Object).Count
        $handleCount = ($processes | Measure-Object -Property HandleCount -Sum).Sum
        
        return @{
            OSName = $os.Caption
            OSVersion = $os.Version
            OSBuild = $os.BuildNumber
            UptimeDays = [math]::Round($uptime.TotalDays, 2)
            UptimeHours = [math]::Round($uptime.TotalHours, 2)
            ProcessCount = $processCount
            HandleCount = $handleCount
            LastBootTime = $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm:ss")
        }
    } catch {
        Write-Warning "Failed to collect system metrics: $($_.Exception.Message)"
        return $null
    }
}

function Get-ServiceMetrics {
    try {
        $criticalServices = @(
            "wuauserv",      # Windows Update
            "W32Time",       # Windows Time
            "Dnscache",      # DNS Client
            "EventLog",      # Event Log
            "RpcSs",         # RPC
            "LanmanServer",  # Server
            "LanmanWorkstation" # Workstation
        )
        
        $serviceStatus = @()
        
        foreach ($svcName in $criticalServices) {
            $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
            if ($svc) {
                $serviceStatus += @{
                    Name = $svc.Name
                    DisplayName = $svc.DisplayName
                    Status = $svc.Status.ToString()
                    StartType = $svc.StartType.ToString()
                }
            }
        }
        
        return $serviceStatus
    } catch {
        Write-Warning "Failed to collect service metrics: $($_.Exception.Message)"
        return $null
    }
}

function Get-DockerMetrics {
    try {
        if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
            return $null
        }
        
        $containers = docker ps -a --format "{{.ID}}|{{.Names}}|{{.Status}}|{{.State}}" 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            return $null
        }
        
        $containerMetrics = @()
        $runningCount = 0
        $stoppedCount = 0
        
        foreach ($line in $containers) {
            $parts = $line -split '\|'
            if ($parts.Count -ge 4) {
                $state = $parts[3]
                if ($state -eq "running") { $runningCount++ }
                else { $stoppedCount++ }
                
                $containerMetrics += @{
                    ID = $parts[0]
                    Name = $parts[1]
                    Status = $parts[2]
                    State = $state
                }
            }
        }
        
        return @{
            TotalContainers = $containerMetrics.Count
            RunningContainers = $runningCount
            StoppedContainers = $stoppedCount
            Containers = $containerMetrics
        }
    } catch {
        Write-Warning "Failed to collect Docker metrics: $($_.Exception.Message)"
        return $null
    }
}

function Calculate-HealthScore {
    param($Metrics)
    
    $score = 100
    
    # CPU penalty (>80% = -20 points)
    if ($Metrics.CPU.Utilization -gt 80) { $score -= 20 }
    elseif ($Metrics.CPU.Utilization -gt 60) { $score -= 10 }
    
    # Memory penalty (>90% = -25 points)
    if ($Metrics.Memory.UsagePercent -gt 90) { $score -= 25 }
    elseif ($Metrics.Memory.UsagePercent -gt 75) { $score -= 15 }
    
    # Disk penalty (>90% = -20 points per disk)
    foreach ($disk in $Metrics.Disk) {
        if ($disk.UsagePercent -gt 90) { $score -= 20 }
        elseif ($disk.UsagePercent -gt 80) { $score -= 10 }
    }
    
    # Disk queue penalty (>5 = -15 points)
    foreach ($disk in $Metrics.Disk) {
        if ($disk.QueueLength -gt 5) { $score -= 15 }
        elseif ($disk.QueueLength -gt 2) { $score -= 5 }
    }
    
    # Service penalty (stopped critical service = -10 points each)
    if ($Metrics.Services) {
        foreach ($svc in $Metrics.Services) {
            if ($svc.Status -ne "Running" -and $svc.StartType -eq "Automatic") {
                $score -= 10
            }
        }
    }
    
    return [math]::Max($score, 0)
}

# ============================================================================
# MAIN FUNCTION: Get-HealthReport
# ============================================================================

function Get-HealthReport {
    [CmdletBinding()]
    param(
        [string]$Format,
        [string]$Path,
        [bool]$Services,
        [bool]$Docker,
        [int]$WarnThreshold,
        [int]$CritThreshold
    )

    try {
        Write-Verbose "Collecting system health metrics..."
        
        # Collect all metrics
        $metrics = @{
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            Hostname = $env:COMPUTERNAME
            CPU = Get-CPUMetrics
            Memory = Get-MemoryMetrics
            Disk = Get-DiskMetrics
            Network = Get-NetworkMetrics
            System = Get-SystemMetrics
        }
        
        if ($Services) {
            $metrics.Services = Get-ServiceMetrics
        }
        
        if ($Docker) {
            $dockerMetrics = Get-DockerMetrics
            if ($dockerMetrics) {
                $metrics.Docker = $dockerMetrics
            }
        }
        
        # Calculate health score
        $healthScore = Calculate-HealthScore -Metrics $metrics
        $metrics.HealthScore = $healthScore
        
        # Determine status
        if ($healthScore -ge $WarnThreshold) {
            $metrics.Status = "HEALTHY"
        } elseif ($healthScore -ge $CritThreshold) {
            $metrics.Status = "WARNING"
        } else {
            $metrics.Status = "CRITICAL"
        }
        
        # Output based on format
        switch ($Format) {
            "JSON" {
                $json = $metrics | ConvertTo-Json -Depth 10
                
                if ($Path) {
                    $json | Out-File -FilePath $Path -Encoding UTF8 -Force
                    Write-Host "[✔] Health metrics exported to: $Path" -ForegroundColor Green
                } else {
                    Write-Output $json
                }
            }
            
            "CSV" {
                # Flatten metrics for CSV
                $csvData = [PSCustomObject]@{
                    Timestamp = $metrics.Timestamp
                    Hostname = $metrics.Hostname
                    HealthScore = $metrics.HealthScore
                    Status = $metrics.Status
                    CPUUtilization = $metrics.CPU.Utilization
                    MemoryUsagePercent = $metrics.Memory.UsagePercent
                    MemoryFreeGB = $metrics.Memory.FreeGB
                    DiskCFreeGB = ($metrics.Disk | Where-Object { $_.Drive -eq 'C' }).FreeGB
                    DiskCUsagePercent = ($metrics.Disk | Where-Object { $_.Drive -eq 'C' }).UsagePercent
                    UptimeDays = $metrics.System.UptimeDays
                    ProcessCount = $metrics.System.ProcessCount
                }
                
                if ($Path) {
                    $csvData | Export-Csv -Path $Path -NoTypeInformation -Force
                    Write-Host "[✔] Health metrics exported to: $Path" -ForegroundColor Green
                } else {
                    $csvData | ConvertTo-Csv -NoTypeInformation | Write-Output
                }
            }
            
            "InfluxDB" {
                # Generate InfluxDB line protocol
                $timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds() * 1000000
                
                $lines = @(
                    "system_health,host=$($metrics.Hostname) score=$($metrics.HealthScore),cpu=$($metrics.CPU.Utilization),memory=$($metrics.Memory.UsagePercent) $timestamp"
                )
                
                if ($Path) {
                    $lines | Out-File -FilePath $Path -Encoding UTF8 -Force
                    Write-Host "[✔] InfluxDB metrics exported to: $Path" -ForegroundColor Green
                } else {
                    $lines | Write-Output
                }
            }
            
            "Console" {
                # Human-readable console output
                $statusColor = switch ($metrics.Status) {
                    "HEALTHY" { "Green" }
                    "WARNING" { "Yellow" }
                    "CRITICAL" { "Red" }
                }
                
                Write-Host "`n========================================" -ForegroundColor Cyan
                Write-Host "   SYSTEM HEALTH REPORT" -ForegroundColor White
                Write-Host "========================================" -ForegroundColor Cyan
                Write-Host "Hostname:       $($metrics.Hostname)" -ForegroundColor White
                Write-Host "Timestamp:      $($metrics.Timestamp)" -ForegroundColor White
                Write-Host "Health Score:   $($metrics.HealthScore)/100" -ForegroundColor $statusColor
                Write-Host "Status:         $($metrics.Status)" -ForegroundColor $statusColor
                
                Write-Host "`n[CPU]" -ForegroundColor Cyan
                Write-Host "  Utilization:  $($metrics.CPU.Utilization)%" -ForegroundColor White
                Write-Host "  Cores:        $($metrics.CPU.Cores) ($($metrics.CPU.LogicalProcessors) logical)" -ForegroundColor White
                Write-Host "  Clock Speed:  $($metrics.CPU.CurrentClockSpeed) MHz" -ForegroundColor White
                
                Write-Host "`n[Memory]" -ForegroundColor Cyan
                Write-Host "  Total:        $($metrics.Memory.TotalGB) GB" -ForegroundColor White
                Write-Host "  Used:         $($metrics.Memory.UsedGB) GB ($($metrics.Memory.UsagePercent)%)" -ForegroundColor White
                Write-Host "  Free:         $($metrics.Memory.FreeGB) GB" -ForegroundColor White
                
                Write-Host "`n[Disk]" -ForegroundColor Cyan
                foreach ($disk in $metrics.Disk) {
                    $diskColor = if ($disk.UsagePercent -gt 90) { "Red" } elseif ($disk.UsagePercent -gt 80) { "Yellow" } else { "White" }
                    Write-Host "  Drive $($disk.Drive):    $($disk.FreeGB) GB free / $($disk.TotalGB) GB ($($disk.UsagePercent)% used)" -ForegroundColor $diskColor
                }
                
                Write-Host "`n[System]" -ForegroundColor Cyan
                Write-Host "  OS:           $($metrics.System.OSName)" -ForegroundColor White
                Write-Host "  Uptime:       $($metrics.System.UptimeDays) days" -ForegroundColor White
                Write-Host "  Processes:    $($metrics.System.ProcessCount)" -ForegroundColor White
                
                if ($metrics.Docker) {
                    Write-Host "`n[Docker]" -ForegroundColor Cyan
                    Write-Host "  Containers:   $($metrics.Docker.TotalContainers) total ($($metrics.Docker.RunningContainers) running)" -ForegroundColor White
                }
                
                Write-Host "`n========================================`n" -ForegroundColor Cyan
            }
        }
        
        return $metrics
        
    } catch {
        Write-Error "Failed to generate health report: $($_.Exception.Message)"
        throw
    }
}

# ============================================================================
# EXECUTION ENTRY POINT
# ============================================================================

Get-HealthReport `
    -Format $OutputFormat `
    -Path $OutputPath `
    -Services $IncludeServices `
    -Docker $IncludeDocker `
    -WarnThreshold $ThresholdWarning `
    -CritThreshold $ThresholdCritical
