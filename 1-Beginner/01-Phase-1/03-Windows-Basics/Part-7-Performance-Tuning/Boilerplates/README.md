# Performance Tuning Boilerplates

This directory contains reusable templates and configuration files for Windows performance monitoring and optimization.

## 📋 Available Templates

### [Performance-Audit-Template.xml](./Performance-Audit-Template.xml)

**Purpose**: Pre-configured Performance Monitor Data Collector Set for DevOps workstation auditing.

**What It Monitors**:
- **CPU**: `\Processor(_Total)\% Processor Time` - Overall CPU utilization
- **Memory**: `\Memory\Available MBytes` - Free RAM available
- **Disk I/O**: `\PhysicalDisk(_Total)\Avg. Disk Queue Length` - Storage bottleneck indicator
- **Network**: `\Network Interface(*)\Bytes Total/sec` - Network throughput
- **Processes**: `\Process(*)\Handle Count` - Resource leak detection

**Configuration**:
- **Duration**: 3600 seconds (1 hour)
- **Sample Interval**: 15 seconds
- **Output Format**: Binary (.blg) for analysis in Performance Monitor

---

## 🚀 How to Use

### Method 1: Import via Performance Monitor GUI

1. Open **Performance Monitor** (`perfmon.exe`)
2. Navigate to **Data Collector Sets** → **User Defined**
3. Right-click and select **New** → **Data Collector Set**
4. Choose **Create from a template** and browse to `Performance-Audit-Template.xml`
5. Click **Start** to begin data collection

### Method 2: Import via PowerShell

```powershell
# Import the data collector set
logman import -name "DevOps-Performance-Audit" -xml ".\Performance-Audit-Template.xml"

# Start data collection
logman start "DevOps-Performance-Audit"

# Stop data collection after your workload
logman stop "DevOps-Performance-Audit"

# View the collected data
perfmon /sys
```

### Method 3: Automated Baseline Collection

```powershell
# Run during normal DevOps workload to establish baseline
$templatePath = "C:\Users\Ganil\Documents\Devops\1-Beginner\01-Phase-1\03-Windows-Basics\Part-7-Performance-Tuning\Boilerplates\Performance-Audit-Template.xml"

# Import and start
logman import -name "Baseline-Audit" -xml $templatePath
logman start "Baseline-Audit"

Write-Host "Collecting baseline metrics for 1 hour..."
Write-Host "Perform your typical DevOps tasks (Docker builds, Git operations, IDE work)"

# Wait for collection to complete (or stop manually)
Start-Sleep -Seconds 3600
logman stop "Baseline-Audit"

Write-Host "Baseline collection complete. Review data in Performance Monitor."
```

---

## 📊 Analyzing the Results

### Opening the Performance Log

1. Open **Performance Monitor** (`perfmon.exe`)
2. Click **Performance Monitor** in the left pane
3. Click the **View Log Data** button (folder icon)
4. Browse to `C:\PerfLogs\Admin\DevOps-Performance-Audit\`
5. Select the `.blg` file and click **OK**

### Key Metrics to Review

| Counter | Healthy Range | Warning Threshold | Action Required |
|---------|---------------|-------------------|-----------------|
| **% Processor Time** | <70% average | >80% sustained | Review CPU optimization (Module 01) |
| **Available MBytes** | >2048 MB | <1024 MB | Optimize memory/pagefile (Module 02) |
| **Avg. Disk Queue Length** | <2 | >5 | Apply storage I/O tuning (Module 03) |
| **Bytes Total/sec** | Varies | Spikes with errors | Network stack optimization (Module 04) |
| **Handle Count** | Stable | Increasing trend | Memory leak investigation |

### Exporting Data for Analysis

```powershell
# Export to CSV for Excel/Python analysis
relog "C:\PerfLogs\Admin\DevOps-Performance-Audit\DataCollector01.blg" -f CSV -o "performance-report.csv"

# View summary statistics
typeperf -qx | Select-String "Processor|Memory|Disk|Network"
```

---

## 🔧 Customizing the Template

### Adding Additional Counters

Edit the XML file to include more performance counters:

```xml
<Counter>\System\Context Switches/sec</Counter>
<Counter>\TCPv4\Connections Established</Counter>
<Counter>\Paging File(_Total)\% Usage</Counter>
```

### Common Counters for DevOps Workloads

**Docker/Container Monitoring**:
```xml
<Counter>\Process(dockerd)\% Processor Time</Counter>
<Counter>\Process(dockerd)\Working Set</Counter>
<Counter>\Process(com.docker.backend)\Handle Count</Counter>
```

**Git Operations**:
```xml
<Counter>\Process(git)\% Processor Time</Counter>
<Counter>\Process(git)\IO Data Bytes/sec</Counter>
```

**IDE Performance (VS Code)**:
```xml
<Counter>\Process(Code)\% Processor Time</Counter>
<Counter>\Process(Code)\Working Set</Counter>
<Counter>\Process(Code)\Thread Count</Counter>
```

**Build Tools (npm, Maven, Gradle)**:
```xml
<Counter>\Process(node)\% Processor Time</Counter>
<Counter>\Process(java)\Working Set</Counter>
```

---

## 📈 Best Practices

### When to Run Performance Audits

1. **Baseline Establishment**: When setting up a new DevOps workstation
2. **Before Optimization**: To identify bottlenecks before applying fixes
3. **After Optimization**: To validate improvements and measure ROI
4. **Troubleshooting**: When experiencing unexplained slowdowns
5. **Capacity Planning**: Before upgrading hardware or scaling workloads

### Recommended Collection Duration

- **Quick Check**: 5-10 minutes during active workload
- **Standard Audit**: 1 hour (default template setting)
- **Long-term Monitoring**: 24 hours for intermittent issues
- **Baseline**: 1 week with scheduled collection during work hours

### Sample Interval Guidelines

- **Real-time Troubleshooting**: 1-5 seconds (high overhead)
- **Standard Monitoring**: 15 seconds (template default)
- **Long-term Trends**: 60 seconds (minimal overhead)

---

## 🎯 Integration with Optimization Scripts

### Workflow: Audit → Optimize → Validate

```powershell
# Step 1: Collect baseline metrics
logman import -name "Pre-Optimization" -xml ".\Performance-Audit-Template.xml"
logman start "Pre-Optimization"
Start-Sleep -Seconds 600  # 10-minute baseline
logman stop "Pre-Optimization"

# Step 2: Apply optimizations
..\01-CPU-and-Process-Prioritization\Optimize-SystemPerformance.ps1
..\02-Memory-Management-and-Swap\Invoke-SystemAudit.ps1
..\03-Storage-I-O-Optimization\Invoke-SystemMaintenance.ps1 -Mode Basic
..\04-Network-Stack-Tuning\Optimize-NetworkStack.ps1
..\05-Power-and-Thermal-Profiles\Optimize-PowerPlan.ps1

# Step 3: Collect post-optimization metrics
logman import -name "Post-Optimization" -xml ".\Performance-Audit-Template.xml"
logman start "Post-Optimization"
Start-Sleep -Seconds 600  # 10-minute validation
logman stop "Post-Optimization"

# Step 4: Compare results
Write-Host "Review both logs in Performance Monitor to measure improvement"
```

---

## 📚 Additional Resources

- [Performance Monitor Documentation](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/perfmon)
- [Data Collector Sets Guide](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc749337(v=ws.11))
- [Performance Counter Reference](https://docs.microsoft.com/en-us/windows/win32/perfctrs/performance-counters-portal)

---

## 🔄 Related Modules

- [01-CPU and Process Prioritization](../01-CPU-and-Process-Prioritization) - Optimize based on CPU metrics
- [02-Memory Management](../02-Memory-Management-and-Swap) - Address memory bottlenecks
- [03-Storage I/O](../03-Storage-I-O-Optimization) - Fix disk queue issues
- [04-Network Stack](../04-Network-Stack-Tuning) - Improve network performance
- [05-Power Profiles](../05-Power-and-Thermal-Profiles) - Eliminate thermal throttling

---

*Measure First, Optimize Second, Validate Always*
