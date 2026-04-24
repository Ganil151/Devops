<#
.SYNOPSIS
    Automated WSL2 Performance Optimizer for Windows 11 DevOps Workstations.

.DESCRIPTION
    This script prevents WSL2 from consuming excessive host system resources during 
    heavy Docker builds and development workloads. It automatically generates an 
    optimized .wslconfig file with intelligent RAM/CPU limits based on your system's 
    total capacity, preventing the "host starvation" phenomenon.

    Key Features:
    - Dynamic resource allocation (50% RAM, 75% CPU cores by default)
    - Swap file optimization for container workloads
    - Localhost forwarding for seamless networking
    - Automatic backup of existing configurations
    - Idempotent execution (safe to run multiple times)

.PARAMETER MemoryGB
    Maximum RAM allocation for WSL2 in gigabytes. Default: 50% of system RAM.

.PARAMETER ProcessorCount
    Maximum CPU cores for WSL2. Default: 75% of logical processors.

.PARAMETER SwapSizeGB
    Swap file size in GB. Default: 8GB for container workloads.

.PARAMETER DisableSwap
    Completely disable swap file (not recommended for Docker).

.PARAMETER Force
    Overwrite existing .wslconfig without prompting.

.EXAMPLE
    .\Set-WSL2Performance.ps1
    Applies intelligent defaults based on system capacity.

.EXAMPLE
    .\Set-WSL2Performance.ps1 -MemoryGB 16 -ProcessorCount 8
    Manually specify resource limits.

.EXAMPLE
    .\Set-WSL2Performance.ps1 -Force -Verbose
    Force configuration update with detailed logging.

.NOTES
    Author: Senior Windows Systems Engineer
    Version: 1.0 (Golden Standard)
    Target: Windows 11 with WSL2 + Docker Desktop
    Safety: Automatic backup of existing .wslconfig
    Idempotency: Checks existing configuration before modification
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(HelpMessage = "Maximum RAM for WSL2 in GB (default: 50% of system RAM)")]
    [ValidateRange(1, 128)]
    [int]$MemoryGB,

    [Parameter(HelpMessage = "Maximum CPU cores for WSL2 (default: 75% of logical processors)")]
    [ValidateRange(1, 128)]
    [int]$ProcessorCount,

    [Parameter(HelpMessage = "Swap file size in GB (default: 8GB)")]
    [ValidateRange(0, 64)]
    [int]$SwapSizeGB = 8,

    [Parameter(HelpMessage = "Disable swap file entirely")]
    [switch]$DisableSwap,

    [Parameter(HelpMessage = "Force overwrite without prompting")]
    [switch]$Force
)

#Requires -Version 5.1

# ============================================================================
# MAIN FUNCTION: Set-WSL2Configuration
# ============================================================================

function Set-WSL2Configuration {
    [CmdletBinding()]
    param(
        [int]$Memory,
        [int]$Processors,
        [int]$Swap,
        [bool]$NoSwap,
        [bool]$ForceUpdate
    )

    try {
        # --- 1. Environment Validation ---
        Write-Host "`n[🔍] VALIDATING WSL2 ENVIRONMENT" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray

        # Check Windows version (WSL2 requires Windows 10 2004+ or Windows 11)
        $osVersion = [System.Environment]::OSVersion.Version
        if ($osVersion.Build -lt 19041) {
            throw "WSL2 requires Windows 10 build 19041 (2004) or later. Current build: $($osVersion.Build)"
        }
        Write-Verbose "OS Version validated: Build $($osVersion.Build)"

        # Check if WSL2 is installed
        $wslCheck = wsl --status 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "WSL2 is not installed. Run 'wsl --install' to enable WSL2."
        }
        Write-Host "[✔] WSL2 installation detected" -ForegroundColor Green

        # --- 2. System Resource Detection ---
        Write-Host "`n[📊] ANALYZING SYSTEM RESOURCES" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray

        $totalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
        $totalCPU = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors

        Write-Host "Total System RAM: $totalRAM GB" -ForegroundColor White
        Write-Host "Total CPU Cores: $totalCPU" -ForegroundColor White

        # Calculate intelligent defaults if not specified
        if (-not $Memory) {
            $Memory = [math]::Floor($totalRAM * 0.5)  # 50% of system RAM
            Write-Host "[AUTO] WSL2 RAM Limit: $Memory GB (50% of system)" -ForegroundColor Yellow
        } else {
            Write-Host "[MANUAL] WSL2 RAM Limit: $Memory GB" -ForegroundColor Cyan
        }

        if (-not $Processors) {
            $Processors = [math]::Floor($totalCPU * 0.75)  # 75% of CPU cores
            Write-Host "[AUTO] WSL2 CPU Limit: $Processors cores (75% of system)" -ForegroundColor Yellow
        } else {
            Write-Host "[MANUAL] WSL2 CPU Limit: $Processors cores" -ForegroundColor Cyan
        }

        # Validate resource limits don't exceed system capacity
        if ($Memory -gt $totalRAM) {
            throw "Memory limit ($Memory GB) exceeds system RAM ($totalRAM GB)"
        }
        if ($Processors -gt $totalCPU) {
            throw "Processor count ($Processors) exceeds system cores ($totalCPU)"
        }

        # --- 3. Configuration File Management ---
        $wslConfigPath = "$env:USERPROFILE\.wslconfig"
        $backupPath = "$env:USERPROFILE\.wslconfig.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

        Write-Host "`n[📝] CONFIGURATION FILE MANAGEMENT" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        Write-Host "Config Path: $wslConfigPath" -ForegroundColor Gray

        # Backup existing configuration
        if (Test-Path $wslConfigPath) {
            Write-Host "[🛡️] Backing up existing .wslconfig..." -ForegroundColor Yellow
            Copy-Item -Path $wslConfigPath -Destination $backupPath -Force
            Write-Host "[✔] Backup saved: $backupPath" -ForegroundColor Green

            # Check if existing config is identical (idempotency)
            $existingContent = Get-Content $wslConfigPath -Raw
            if ($existingContent -match "memory=$($Memory)GB" -and $existingContent -match "processors=$Processors") {
                Write-Host "`n[✔] Configuration already optimal. No changes needed." -ForegroundColor Green
                if (-not $ForceUpdate) {
                    Write-Host "[INFO] Use -Force to overwrite anyway." -ForegroundColor Gray
                    return
                }
            }
        } else {
            Write-Host "[INFO] No existing .wslconfig found. Creating new configuration." -ForegroundColor Gray
        }

        # --- 4. Generate Optimized Configuration ---
        Write-Host "`n[⚙️] GENERATING WSL2 CONFIGURATION" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray

        $configContent = @"
# WSL2 Performance Configuration
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# Generated by: Set-WSL2Performance.ps1 (Golden Standard)

[wsl2]
# Memory allocation (prevents host RAM starvation)
memory=$($Memory)GB

# CPU allocation (prevents host CPU starvation)
processors=$Processors

# Swap configuration (optimized for Docker workloads)
$(if ($NoSwap) { "swap=0" } else { "swap=$($Swap)GB" })
swapFile=$env:USERPROFILE\AppData\Local\Temp\wsl-swap.vhdx

# Localhost forwarding (seamless networking between Windows and WSL2)
localhostForwarding=true

# Kernel parameters (performance tuning)
kernelCommandLine=cgroup_no_v1=all systemd.unified_cgroup_hierarchy=1

# Nested virtualization (for Docker-in-Docker scenarios)
nestedVirtualization=true

# GUI support (WSLg for graphical applications)
guiApplications=true

# Network mode (NAT for Docker compatibility)
networkingMode=NAT
"@

        # --- 5. Apply Configuration ---
        if ($PSCmdlet.ShouldProcess($wslConfigPath, "Write WSL2 configuration")) {
            $configContent | Out-File -FilePath $wslConfigPath -Encoding UTF8 -Force
            Write-Host "[✔] Configuration written successfully" -ForegroundColor Green
        }

        # --- 6. Display Configuration Summary ---
        Write-Host "`n[📋] CONFIGURATION SUMMARY" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        Write-Host "RAM Limit:       $Memory GB ($(($Memory/$totalRAM*100).ToString('0.0'))% of system)" -ForegroundColor White
        Write-Host "CPU Limit:       $Processors cores ($(($Processors/$totalCPU*100).ToString('0.0'))% of system)" -ForegroundColor White
        Write-Host "Swap:            $(if ($NoSwap) { 'Disabled' } else { "$Swap GB" })" -ForegroundColor White
        Write-Host "Localhost Fwd:   Enabled" -ForegroundColor White
        Write-Host "Nested Virt:     Enabled" -ForegroundColor White

        # --- 7. WSL2 Restart Prompt ---
        Write-Host "`n[⚠️] IMPORTANT: WSL2 RESTART REQUIRED" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Gray
        Write-Host "Changes will take effect after restarting WSL2." -ForegroundColor White
        Write-Host "`nRestart commands:" -ForegroundColor Gray
        Write-Host "  wsl --shutdown" -ForegroundColor Cyan
        Write-Host "  wsl" -ForegroundColor Cyan

        $restart = Read-Host "`nRestart WSL2 now? (Y/N)"
        if ($restart -eq 'Y' -or $restart -eq 'y') {
            Write-Host "`n[🔄] Shutting down WSL2..." -ForegroundColor Cyan
            wsl --shutdown
            Start-Sleep -Seconds 2
            Write-Host "[✔] WSL2 shutdown complete. Start WSL2 to apply new configuration." -ForegroundColor Green
        }

        # --- 8. Success Summary ---
        Write-Host "`n[✅] WSL2 PERFORMANCE OPTIMIZATION COMPLETE" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "Configuration: $wslConfigPath" -ForegroundColor Gray
        if (Test-Path $backupPath) {
            Write-Host "Backup:        $backupPath" -ForegroundColor Gray
        }

    } catch {
        Write-Error "CRITICAL FAILURE: $($_.Exception.Message)"
        Write-Host "`n[❌] Configuration failed. System unchanged." -ForegroundColor Red
        
        # Restore backup if exists
        if (Test-Path $backupPath) {
            Write-Host "[🔄] Restoring backup..." -ForegroundColor Yellow
            Copy-Item -Path $backupPath -Destination $wslConfigPath -Force
            Write-Host "[✔] Backup restored successfully" -ForegroundColor Green
        }
        throw
    }
}

# ============================================================================
# EXECUTION ENTRY POINT
# ============================================================================

Clear-Host
Write-Host "============================================" -ForegroundColor Blue
Write-Host "   WSL2 PERFORMANCE OPTIMIZER v1.0         " -ForegroundColor White
Write-Host "   Windows 11 DevOps Workstation Edition   " -ForegroundColor White
Write-Host "============================================" -ForegroundColor Blue

Set-WSL2Configuration `
    -Memory $MemoryGB `
    -Processors $ProcessorCount `
    -Swap $SwapSizeGB `
    -NoSwap $DisableSwap `
    -ForceUpdate $Force
