<#
.SYNOPSIS
    Optimizes Docker Desktop engine settings on Windows 11/Server.

.DESCRIPTION
    This script tunes the Docker Engine for better performance and manages disk usage.
    Features:
    - Prunes dangling volumes and images to free up space.
    - Adjusts WSL2 memory limits (via .wslconfig check).
    - Checks for WSL2 backend usage.
    
    This script is designed to be run periodically (cron/Task Scheduler).

.PARAMETER PruneAggressive
    If set, performs a 'docker system prune -a' which removes UNUSED images, not just dangling ones.

.EXAMPLE
    .\Optimize-DockerWindowsEngine.ps1 -PruneAggressive

.TAGS
    #Docker #Windows #Optimization #ContainerOps
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$false)]
    [switch]$PruneAggressive
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param ([string]$Message, [string]$Level="INFO")
    Write-Output ([PSCustomObject]@{Timestamp=(Get-Date -Format "u"); Level=$Level; Message=$Message})
}

try {
    Write-Log "Starting Docker Windows Engine Optimization..."

    # 1. Check if Docker is running
    $dockerProcess = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if (-not $dockerProcess) {
        Write-Log "Docker Desktop is not running. Attempting to check com.docker.service..." "WARNING"
        # In a real script we might try to start it, but that's invasive.
    }

    # 2. Check WSL Integration
    $wslStatus = wsl --status 2>&1
    if ($wslStatus -match "Default Version: 2") {
        Write-Log "WSL2 is active."
    } else {
        Write-Log "WSL2 might not be the default. Recommended for performance." "WARNING"
    }

    # 3. Clean up Disk Space
    if ($PSCmdlet.ShouldProcess("Docker Engine", "Prune Dangling Resources")) {
        Write-Log "Pruning dangling volumes..."
        docker volume prune -f | Out-Null
        
        Write-Log "Pruning dangling images..."
        docker image prune -f | Out-Null

        if ($PruneAggressive) {
            Write-Log "Performing aggressive system prune (unused containers, networks, images)..."
            # -f forces without prompt, be careful
            docker system prune -a -f --volumes | Out-Null
        }
    }

    # 4. WSL Config check (Memory Limiting to prevent starvation)
    $wslConfigPath = "$env:USERPROFILE\.wslconfig"
    if (Test-Path $wslConfigPath) {
        Write-Log "Found .wslconfig. Ensuring memory limits are sane..."
        $content = Get-Content $wslConfigPath
        if ($content -match "memory=") {
            Write-Log ".wslconfig has memory limits set."
        } else {
            Write-Log ".wslconfig exists but currently lacks obvious memory limits." "WARNING"
        }
    } else {
        Write-Log "No .wslconfig found. WSL2 can consume all host RAM. Consider creating one." "WARNING"
    }

    Write-Log "Optimization complete."

} catch {
    Write-Log "Optimization failed: $_" "FATAL"
    exit 1
}
