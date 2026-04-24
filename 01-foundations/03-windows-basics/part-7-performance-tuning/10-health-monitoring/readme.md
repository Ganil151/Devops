# Health Monitoring & Telemetry

![Monitoring](https://img.shields.io/badge/Monitoring-Enabled-FF6B6B?style=for-the-badge&logo=grafana&logoColor=white)
![Integration](https://img.shields.io/badge/Integration-Grafana|Jenkins|Prometheus-4A90E2?style=for-the-badge)

## 🎯 Overview

This module provides **comprehensive system health monitoring** with multi-format output for integration with observability platforms like Grafana, Prometheus, Jenkins, and Azure Monitor. Perfect for fleet-wide health tracking and automated alerting.

## 📊 Metrics Collected

### [Get-SystemHealthScore.ps1](./get-systemhealthscore.ps1)

**Purpose**: System health monitoring with JSON/CSV/InfluxDB export for automation platforms.

**Metrics Categories**:

| Category | Metrics | Purpose |
|----------|---------|---------|
| **CPU** | Utilization %, core count, clock speed | Performance monitoring |
| **Memory** | Total, used, free, page file usage | Capacity planning |
| **Disk** | Free space, queue length, usage % | Storage monitoring |
| **Network** | Throughput, packet errors, TCP connections | Network health |
| **System** | Uptime, process count, handle count | Stability tracking |
| **Services** | Critical service status | Availability monitoring |
| **Docker** | Container count, running/stopped | Container orchestration |

## 🎯 Health Scoring Algorithm

The script calculates a **0-100 health score** based on:

| Condition | Penalty | Threshold |
|-----------|---------|-----------|
| **CPU >80%** | -20 points | Critical load |
| **CPU >60%** | -10 points | High load |
| **Memory >90%** | -25 points | Memory pressure |
| **Memory >75%** | -15 points | Elevated usage |
| **Disk >90%** | -20 points/disk | Critical space |
| **Disk >80%** | -10 points/disk | Low space |
| **Disk Queue >5** | -15 points | I/O bottleneck |
| **Disk Queue >2** | -5 points | Elevated I/O |
| **Stopped Service** | -10 points/service | Service failure |

**Health Status**:
- **100-70**: HEALTHY (Green)
- **69-50**: WARNING (Yellow)
- **49-0**: CRITICAL (Red)

## 🚀 Usage

### Console Output (Human-Readable)

```powershell
.\Get-SystemHealthScore.ps1
```

Displays formatted health report in console.

### JSON Export for Grafana

```powershell
.\Get-SystemHealthScore.ps1 -OutputFormat JSON -OutputPath "C:\Metrics\health.json"
```

Exports metrics to JSON file for Grafana consumption.

### InfluxDB Line Protocol

```powershell
.\Get-SystemHealthScore.ps1 -OutputFormat InfluxDB -OutputPath "C:\Metrics\influx.txt"
```

Generates InfluxDB line protocol for Telegraf ingestion.

### CSV Export for Excel

```powershell
.\Get-SystemHealthScore.ps1 -OutputFormat CSV -OutputPath "C:\Metrics\health.csv"
```

Exports flattened metrics to CSV for spreadsheet analysis.

### Include Service Status

```powershell
.\Get-SystemHealthScore.ps1 -IncludeServices
```

Adds critical service status to health report.

### Include Docker Metrics

```powershell
.\Get-SystemHealthScore.ps1 -IncludeDocker
```

Adds Docker container metrics (if Docker is installed).

## 📈 Integration Examples

### Grafana Dashboard

**Step 1**: Export JSON metrics

```powershell
.\Get-SystemHealthScore.ps1 -OutputFormat JSON -OutputPath "C:\inetpub\wwwroot\metrics\health.json"
```

**Step 2**: Configure Grafana JSON data source

```json
{
  "type": "simplejson",
  "url": "http://your-server/metrics/health.json"
}
```

**Step 3**: Create dashboard panels for:
- Health Score (Gauge)
- CPU Utilization (Time Series)
- Memory Usage (Bar Chart)
- Disk Space (Table)

### Jenkins Pipeline Integration

```groovy
pipeline {
    agent any
    
    stages {
        stage('Health Check') {
            steps {
                powershell '''
                    $health = & C:\\Scripts\\Get-SystemHealthScore.ps1 -OutputFormat JSON | ConvertFrom-Json
                    
                    if ($health.HealthScore -lt 50) {
                        error("CRITICAL: System health score is $($health.HealthScore)")
                    } elseif ($health.HealthScore -lt 70) {
                        echo "WARNING: System health score is $($health.HealthScore)"
                    } else {
                        echo "HEALTHY: System health score is $($health.HealthScore)"
                    }
                '''
            }
        }
    }
}
```

### Prometheus/Telegraf Integration

**Step 1**: Generate InfluxDB metrics

```powershell
.\Get-SystemHealthScore.ps1 -OutputFormat InfluxDB -OutputPath "C:\Metrics\system.txt"
```

**Step 2**: Configure Telegraf to read the file

```toml
[[inputs.file]]
  files = ["C:/Metrics/system.txt"]
  data_format = "influx"
```

### PowerShell Scheduled Task

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Get-SystemHealthScore.ps1 -OutputFormat JSON -OutputPath C:\Metrics\health.json"

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "System Health Monitoring" `
    -Action $action -Trigger $trigger -Principal $principal `
    -Description "Collect system health metrics every 5 minutes"
```

## 📊 Sample Output

### Console Format

```
========================================
   SYSTEM HEALTH REPORT
========================================
Hostname:       BUILD-SERVER-01
Timestamp:      2026-01-25 21:45:00
Health Score:   85/100
Status:         HEALTHY

[CPU]
  Utilization:  45.2%
  Cores:        8 (16 logical)
  Clock Speed:  3600 MHz

[Memory]
  Total:        32.00 GB
  Used:         18.45 GB (57.66%)
  Free:         13.55 GB

[Disk]
  Drive C:    125.34 GB free / 500.00 GB (74.93% used)
  Drive D:    850.12 GB free / 1000.00 GB (14.99% used)

[System]
  OS:           Microsoft Windows Server 2022 Datacenter
  Uptime:       12.45 days
  Processes:    245

[Docker]
  Containers:   15 total (12 running)

========================================
```

### JSON Format

```json
{
  "Timestamp": "2026-01-25 21:45:00",
  "Hostname": "BUILD-SERVER-01",
  "HealthScore": 85,
  "Status": "HEALTHY",
  "CPU": {
    "Utilization": 45.2,
    "Cores": 8,
    "LogicalProcessors": 16
  },
  "Memory": {
    "TotalGB": 32.0,
    "UsedGB": 18.45,
    "FreeGB": 13.55,
    "UsagePercent": 57.66
  },
  "Disk": [
    {
      "Drive": "C",
      "TotalGB": 500.0,
      "FreeGB": 125.34,
      "UsagePercent": 74.93
    }
  ]
}
```

### InfluxDB Line Protocol

```
system_health,host=BUILD-SERVER-01 score=85,cpu=45.2,memory=57.66 1737853500000000000
```

## 🎓 Best Practices

### Monitoring Frequency

| Environment | Frequency | Retention |
|-------------|-----------|-----------|
| **Production Servers** | Every 1-5 minutes | 30 days |
| **Development Workstations** | Every 15 minutes | 7 days |
| **CI/CD Nodes** | Every 5 minutes | 14 days |

### Alerting Thresholds

**Recommended Alert Rules**:

```yaml
# Grafana Alert Rules
- alert: SystemHealthCritical
  expr: health_score < 50
  for: 5m
  annotations:
    summary: "System health is CRITICAL"

- alert: SystemHealthWarning
  expr: health_score < 70
  for: 15m
  annotations:
    summary: "System health is WARNING"
```

### Storage Considerations

**JSON File Size**: ~2-5 KB per snapshot  
**Daily Storage** (5-min interval): ~600 KB  
**Monthly Storage**: ~18 MB

## 🔧 Customization

### Add Custom Metrics

Edit the script to include additional metrics:

```powershell
# Add GPU metrics
$metrics.GPU = @{
    Name = (Get-WmiObject Win32_VideoController).Name
    DriverVersion = (Get-WmiObject Win32_VideoController).DriverVersion
}
```

### Adjust Health Scoring

Modify the `Calculate-HealthScore` function to change penalty weights.

## 📚 Related Resources

- [Grafana JSON Data Source](https://grafana.com/grafana/plugins/simpod-json-datasource/)
- [InfluxDB Line Protocol](https://docs.influxdata.com/influxdb/v2.0/reference/syntax/line-protocol/)
- [Prometheus Exporters](https://prometheus.io/docs/instrumenting/exporters/)

---

**Next Steps**: Set up automated monitoring and integrate with your observability platform!

---

*Comprehensive Health Monitoring for DevOps Infrastructure*
