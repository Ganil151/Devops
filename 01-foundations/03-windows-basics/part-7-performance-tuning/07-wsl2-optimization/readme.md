# WSL2 Performance Optimization

![WSL2](https://img.shields.io/badge/WSL2-Optimized-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows_11-Required-00A4EF?style=for-the-badge&logo=windows11&logoColor=white)

## 🎯 Overview

This module addresses the **"host starvation" problem** that occurs when WSL2 (Windows Subsystem for Linux 2) consumes excessive system resources during heavy Docker builds and development workloads. Without proper configuration, WSL2 can monopolize RAM and CPU, leaving the Windows host unresponsive.

## 🚨 The Problem

**Symptom**: Windows becomes sluggish or unresponsive when running Docker Desktop or intensive WSL2 workloads.

**Root Cause**: WSL2 dynamically allocates system resources without limits, potentially consuming:
- Up to 80% of system RAM
- All available CPU cores
- Excessive disk I/O for swap operations

## ✅ The Solution

The `Set-WSL2Performance.ps1` script automatically generates an optimized `.wslconfig` file with intelligent resource limits based on your system's capacity.

### [Set-WSL2Performance.ps1](./set-wsl2performance.ps1)

**Purpose**: Automated WSL2 resource limiter for Windows 11 DevOps workstations.

**Key Features**:
- **Dynamic Resource Allocation**: Automatically allocates 50% RAM and 75% CPU by default
- **Idempotent Execution**: Safe to run multiple times without side effects
- **Automatic Backups**: Preserves existing `.wslconfig` before modifications
- **Validation**: Ensures resource limits don't exceed system capacity
- **WSL2 Restart Integration**: Optionally restarts WSL2 to apply changes

## 📊 Configuration Strategy

### Default Resource Allocation

| Resource | Allocation | Reasoning |
|----------|------------|-----------|
| **RAM** | 50% of system | Leaves sufficient memory for Windows host |
| **CPU** | 75% of cores | Maintains host responsiveness while maximizing WSL2 performance |
| **Swap** | 8 GB | Optimal for Docker container workloads |
| **Localhost Forwarding** | Enabled | Seamless networking between Windows and WSL2 |

### Example Configurations

**16 GB RAM System**:
- WSL2 Limit: 8 GB
- Windows Host: 8 GB available

**32 GB RAM System**:
- WSL2 Limit: 16 GB
- Windows Host: 16 GB available

**8-Core CPU**:
- WSL2 Limit: 6 cores
- Windows Host: 2 cores reserved

## 🚀 Usage

### Basic Usage (Recommended)

```powershell
.\Set-WSL2Performance.ps1
```

Applies intelligent defaults based on system capacity.

### Custom Resource Limits

```powershell
.\Set-WSL2Performance.ps1 -MemoryGB 12 -ProcessorCount 6
```

Manually specify WSL2 resource limits.

### Force Update

```powershell
.\Set-WSL2Performance.ps1 -Force
```

Overwrite existing configuration without prompting.

### Disable Swap (Advanced)

```powershell
.\Set-WSL2Performance.ps1 -DisableSwap
```

Disable swap file (not recommended for Docker workloads).

## 📝 Generated .wslconfig File

The script creates `%USERPROFILE%\.wslconfig` with the following structure:

```ini
[wsl2]
memory=8GB
processors=6
swap=8GB
swapFile=C:\Users\YourName\AppData\Local\Temp\wsl-swap.vhdx
localhostForwarding=true
kernelCommandLine=cgroup_no_v1=all systemd.unified_cgroup_hierarchy=1
nestedVirtualization=true
guiApplications=true
networkingMode=NAT
```

## 🔄 Applying Changes

After running the script, **restart WSL2** to apply the new configuration:

```powershell
wsl --shutdown
wsl
```

The script will prompt you to restart WSL2 automatically.

## ✅ Verification

### Check WSL2 Resource Usage

```powershell
# View WSL2 memory usage
wsl -d Ubuntu -- free -h

# View WSL2 CPU allocation
wsl -d Ubuntu -- nproc
```

### Monitor Windows Host Performance

```powershell
# Check available RAM
Get-CimInstance Win32_OperatingSystem | Select-Object FreePhysicalMemory

# Check CPU usage
Get-Counter '\Processor(_Total)\% Processor Time'
```

## 🎓 Best Practices

1. **Start with Defaults**: Let the script calculate optimal limits
2. **Monitor Performance**: Observe both WSL2 and Windows host performance
3. **Adjust as Needed**: Fine-tune limits based on your workload
4. **Regular Reviews**: Re-run the script when upgrading hardware

## 🔧 Troubleshooting

### WSL2 Still Consuming Too Much RAM

**Solution**: Reduce the `-MemoryGB` parameter:

```powershell
.\Set-WSL2Performance.ps1 -MemoryGB 6
```

### Docker Containers Running Slowly

**Solution**: Increase WSL2 resource allocation:

```powershell
.\Set-WSL2Performance.ps1 -MemoryGB 12 -ProcessorCount 8
```

### Configuration Not Applied

**Solution**: Ensure WSL2 was restarted:

```powershell
wsl --shutdown
wsl
```

## 📖 Related Resources

- [Microsoft WSL2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Docker Desktop WSL2 Backend](https://docs.docker.com/desktop/windows/wsl/)
- [WSL2 Advanced Settings](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)

---

**Next Steps**: Run the script and monitor your system's performance improvement!

---

*Windows 11 DevOps Workstation Optimization*
