# Labs and Challenges: Performance Tuning Mastery

This section provides hands-on labs and real-world challenges to solidify your understanding of Windows performance optimization for DevOps environments.

## 🎯 Learning Objectives

By completing these labs, you will:

- **Diagnose** system bottlenecks using PowerShell and Performance Monitor
- **Apply** targeted optimizations based on metrics and telemetry
- **Measure** performance improvements using quantitative benchmarks
- **Troubleshoot** common performance issues in development environments
- **Implement** enterprise-grade performance tuning strategies

---

## 📚 Available Labs

### [Lab 1: Identifying System Bottlenecks](./Lab-Bottleneck-Resolution.md)

**Difficulty**: Beginner  
**Duration**: 30-45 minutes  
**Focus**: System diagnostics and targeted remediation

Learn to detect resource bottlenecks using PowerShell auditing tools and apply the appropriate optimization scripts.

**Key Skills**:
- Running system audits with `Invoke-SystemAudit.ps1`
- Interpreting disk health and network metrics
- Applying targeted fixes with maintenance scripts
- Measuring performance deltas with `Measure-Command`

---

## 🧪 Challenge Scenarios

### Challenge 1: Docker Build Performance Crisis

**Scenario**: Your CI/CD pipeline is experiencing 3x slower Docker build times on Windows nodes compared to Linux nodes.

**Your Mission**:
1. Identify which subsystem is the bottleneck (CPU, Memory, Disk I/O, or Network)
2. Apply appropriate optimizations from modules 01-05
3. Document the performance improvement with before/after metrics
4. Create a reproducible optimization playbook

**Success Criteria**:
- Build time reduced by at least 40%
- No stability regressions
- Documented optimization steps

**Hints**:
- Check Docker's storage driver configuration
- Review pagefile settings for container workloads
- Examine disk queue lengths during builds
- Consider network stack tuning for registry pulls

---

### Challenge 2: IDE Responsiveness Optimization

**Scenario**: Visual Studio Code becomes unresponsive when running multiple DevOps tools (Docker, WSL2, Node.js, Python).

**Your Mission**:
1. Profile the system using Performance Monitor
2. Identify process priority conflicts
3. Optimize CPU scheduling and memory allocation
4. Tune power profiles to eliminate frequency scaling jitter

**Success Criteria**:
- IDE remains responsive under full DevOps workload
- No thermal throttling during sustained operations
- Consistent frame times in UI rendering

**Tools to Use**:
- `Optimize-SystemPerformance.ps1` (CPU prioritization)
- `Optimize-PowerPlan.ps1` (Power profile tuning)
- Performance Monitor with custom data collector sets

---

### Challenge 3: Network Stack Latency Reduction

**Scenario**: Kubernetes API calls and Docker registry pulls are experiencing high latency (>200ms) despite fast internet connection.

**Your Mission**:
1. Diagnose DNS resolution delays
2. Optimize TCP receive window scaling
3. Configure network adapter offloading
4. Implement DNS caching strategies

**Success Criteria**:
- API call latency reduced to <50ms
- Registry pull speeds match bandwidth capacity
- No packet loss or retransmissions

**Tools to Use**:
- `Optimize-NetworkStack.ps1`
- `Test-NetConnection` for diagnostics
- Wireshark for packet analysis (optional)

---

### Challenge 4: Memory Pressure Under Container Workloads

**Scenario**: Running 10+ Docker containers causes excessive paging and system slowdown.

**Your Mission**:
1. Analyze memory allocation patterns
2. Optimize pagefile configuration
3. Tune Windows memory management
4. Implement container memory limits

**Success Criteria**:
- No hard page faults during normal operations
- Available memory remains above 2GB threshold
- Container startup times reduced by 30%

**Tools to Use**:
- `Invoke-SystemAudit.ps1` (Memory metrics)
- Docker stats and resource constraints
- Performance Monitor memory counters

---

### Challenge 5: Storage I/O Optimization for Databases

**Scenario**: Local PostgreSQL and MongoDB instances are experiencing slow query times due to disk I/O bottlenecks.

**Your Mission**:
1. Measure disk queue lengths and latency
2. Optimize NTFS settings for database workloads
3. Configure SSD TRIM and maintenance schedules
4. Implement write-back caching strategies

**Success Criteria**:
- Disk queue length consistently below 2
- Query response times improved by 50%
- No data corruption or integrity issues

**Tools to Use**:
- `Invoke-SystemMaintenance.ps1`
- `diskspd` for I/O benchmarking
- Database-specific profiling tools

---

## 🏆 Master Challenge: Full Stack Optimization

**Scenario**: You're setting up a new DevOps workstation and need to optimize it from scratch for maximum performance.

**Your Mission**:
Create a comprehensive optimization playbook that:

1. **Audits** the baseline system performance
2. **Applies** optimizations across all 5 subsystems:
   - CPU and Process Prioritization
   - Memory Management
   - Storage I/O
   - Network Stack
   - Power and Thermal Profiles
3. **Validates** improvements with quantitative benchmarks
4. **Documents** the entire process for team replication

**Deliverables**:
- PowerShell automation script that applies all optimizations
- Performance comparison report (before/after)
- Troubleshooting guide for common issues
- Team onboarding documentation

**Success Criteria**:
- All performance counters in "optimal" range
- 50%+ improvement in common DevOps tasks (git, docker, npm)
- Zero stability regressions
- Reproducible on other team machines

---

## 📊 Performance Benchmarking Guide

### Recommended Metrics to Track

| Subsystem | Metric | Optimal Range | Tool |
|-----------|--------|---------------|------|
| **CPU** | % Processor Time | <70% average | Performance Monitor |
| **Memory** | Available MBytes | >2048 MB | Task Manager |
| **Disk** | Avg. Disk Queue Length | <2 | `Get-Counter` |
| **Network** | TCP Retransmissions | <1% | `netstat -s` |
| **Power** | CPU Frequency | Max (no throttling) | HWiNFO64 |

### Benchmarking Commands

```powershell
# Measure Docker build time
Measure-Command { docker build -t test-image . }

# Measure Git operations
Measure-Command { git status }

# Measure npm install
Measure-Command { npm install }

# Measure file copy performance
Measure-Command { Copy-Item -Path .\large-file.bin -Destination .\test\ }
```

---

## 🔧 Troubleshooting Common Issues

### Issue: Optimizations Not Persisting After Reboot

**Solution**: Ensure scripts are run with Administrator privileges and check Task Scheduler for startup tasks.

### Issue: System Instability After Optimization

**Solution**: Revert changes incrementally using System Restore or by re-running scripts with default parameters.

### Issue: Performance Degradation Over Time

**Solution**: Schedule regular maintenance with `Invoke-SystemMaintenance.ps1` and monitor long-term metrics.

---

## 📖 Additional Resources

- [Performance Audit Template](../Boilerplates/Performance-Audit-Template.xml) - Import into Performance Monitor
- [Windows Performance Analyzer](https://docs.microsoft.com/en-us/windows-hardware/test/wpt/windows-performance-analyzer)
- [PowerShell Performance Counters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-counter)

---

## 🎓 Learning Path

1. **Start with Lab 1** to understand the diagnostic workflow
2. **Progress through Challenges 1-5** in order of increasing complexity
3. **Attempt the Master Challenge** once you're comfortable with all subsystems
4. **Share your optimization playbook** with the team

---

## ✅ Knowledge Check

After completing the labs, you should be able to answer:

1. What are the five key subsystems to optimize for DevOps performance?
2. How do you measure the impact of performance optimizations quantitatively?
3. What's the difference between CPU scheduling quantum and process priority?
4. When should you increase pagefile size vs. disable it entirely?
5. How does TCP receive window scaling affect Docker registry pulls?
6. What are the trade-offs of using "High Performance" power plans?

---

**Next Steps**: Apply these optimization techniques to your production DevOps environment and document the results!

---

*Performance Engineering for DevOps Excellence*
