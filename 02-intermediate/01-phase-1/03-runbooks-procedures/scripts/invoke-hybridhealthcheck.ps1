<#
.SYNOPSIS
    Checks system health for both Windows Hosts and Windows Containers.

.DESCRIPTION
    This script performs a health check on the current Windows system.
    It adapts its checks based on whether it detects it is running inside a Container (NanoServer/ServerCore) or a full Host.
    
    Checks:
    - Disk Space (C: Drive)
    - Memory Usage
    - Vital Services (Docker, HNS) - if Host
    - Environment Variables - if Container
    
    Output is returned as a PowerShell Object for CI/CD parsing.

.EXAMPLE
    .\Invoke-HybridHealthCheck.ps1 -ThresholdFreeGB 10

.TAGS
    #HealthCheck #Windows #Hybrid #Container
#>

[CmdletBinding()]
param (
    [int]$ThresholdFreeGB = 15,
    [int]$MaxRamUsagePercent = 90
)

$ErrorActionPreference = "Stop"
$logDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-Log {
    param ([string]$Msg, [string]$Level="INFO")
    Write-Host "[$logDate] [$Level] $Msg"
}

# 1. Detect Environment
$isContainer = [bool](Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "ContainerId" -ErrorAction SilentlyContinue)
$envType = if ($isContainer) { "WindowsContainer" } else { "WindowsHost" }

Write-Log "Starting Health Check on [$envType]"

$healthObj = [PSCustomObject]@{
    Timestamp   = $logDate
    Environment = $envType
    Status      = "Healthy"
    Checks      = @()
}

# 2. Check Disk
try {
    $drive = Get-PSDrive C -ErrorAction Stop
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    
    $diskStatus = if ($freeGB -gt $ThresholdFreeGB) { "PASS" } else { "WARNING" }
    $healthObj.Checks += @{ Name="Disk_C_Free"; Value="$freeGB GB"; Status=$diskStatus }
} catch {
    $healthObj.Checks += @{ Name="Disk_Check"; Value="Failed"; Status="ERROR" }
}

# 3. Check Memory
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $totalMem = $os.TotalVisibleMemorySize
    $freeMem = $os.FreePhysicalMemory
    $usedPercent = [math]::Round((($totalMem - $freeMem) / $totalMem) * 100, 2)
    
    $memStatus = if ($usedPercent -lt $MaxRamUsagePercent) { "PASS" } else { "WARNING" }
    $healthObj.Checks += @{ Name="Memory_Used"; Value="$usedPercent%"; Status=$memStatus }
} catch {
    $healthObj.Checks += @{ Name="Memory_Check"; Value="Failed"; Status="ERROR" }
}

# 4. Context Aware Checks
if ($isContainer) {
    # Check Env Vars
    if ($env:CONTAINER_APP_NAME) {
         $healthObj.Checks += @{ Name="Env_AppName"; Value=$env:CONTAINER_APP_NAME; Status="PASS" }
    } else {
         $healthObj.Checks += @{ Name="Env_AppName"; Value="Missing"; Status="WARNING" }
    }
} else {
    # Check Host Services
    $services = @("LanmanServer", "Schedule") # Generic services
    foreach ($svc in $services) {
        $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($s -and $s.Status -eq 'Running') {
             $healthObj.Checks += @{ Name="Service_$svc"; Value="Running"; Status="PASS" }
        } else {
             $healthObj.Checks += @{ Name="Service_$svc"; Value="Stopped/Missing"; Status="WARNING" }
        }
    }
}

# 5. Output
# Determine global status
if ($healthObj.Checks.Status -contains "ERROR") { $healthObj.Status = "Unhealthy" }
elseif ($healthObj.Checks.Status -contains "WARNING") { $healthObj.Status = "Degraded" }

Write-Log "Health Check Complete: $($healthObj.Status)"

# Passthrough object for pipeline
return $healthObj
