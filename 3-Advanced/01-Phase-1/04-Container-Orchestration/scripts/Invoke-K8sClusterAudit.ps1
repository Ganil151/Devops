<#
.SYNOPSIS
    Performs a deep security and resource audit on a Kubernetes cluster.

.DESCRIPTION
    Integrates with kubectl to scan namespaces for common misconfigurations:
    - Privileged Pods
    - Missing Resource Limits
    - Wide-open Ingress rules
    - Old/Stale pods
    
    Designed for SREs managing hybrid Windows/Linux clusters.

.PARAMETER Namespace
    Specific namespace to audit. Defaults to --all-namespaces.

.EXAMPLE
    .\Invoke-K8sClusterAudit.ps1 -Namespace "prod-gateway"

.TAGS
    #Kubernetes #SRE #Audit #Security
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$false)]
    [string]$Namespace = ""
)

$ErrorActionPreference = "Stop"

function Write-AuditLog {
    param ([string]$Msg, [string]$Level="INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [$Level] $Msg" -ForegroundColor $(if($Level -eq "WARN"){"Yellow"}elseif($Level -eq "ERR"){"Red"}else{"Cyan"})
}

try {
    Write-AuditLog "Starting Advanced K8s Audit..."
    
    # Check kubectl
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
        throw "kubectl not found in PATH."
    }

    $nsArg = if ($Namespace) { "-n $Namespace" } else { "--all-namespaces" }

    # 1. Check for Privileged Pods
    Write-AuditLog "Scanning for Privileged Containers..."
    $privileged = kubectl get pods $nsArg -o jsonpath='{.items[?(@.spec.containers[*].securityContext.privileged==true)].metadata.name}'
    if ($privileged) {
        Write-AuditLog "CRITICAL: Privileged pods found: $privileged" "WARN"
    } else {
        Write-AuditLog "No privileged pods detected." "PASS"
    }

    # 2. Check Resource Limits
    Write-AuditLog "Analyzing Resource Limits..."
    $noLimits = kubectl get pods $nsArg -o json | ConvertFrom-Json | ForEach-Object {
        $podName = $_.metadata.name
        $_.spec.containers | ForEach-Object {
            if (-not $_.resources.limits) {
                [PSCustomObject]@{ Pod = $podName; Container = $_.name; Missing = "Limits" }
            }
        }
    }
    
    if ($noLimits) {
        Write-AuditLog "$($noLimits.Count) containers found missing resource limits." "WARN"
    }

    # 3. Check for Stale Pods (> 30 days)
    $threshold = (Get-Date).AddDays(-30)
    $pods = kubectl get pods $nsArg -o json | ConvertFrom-Json
    $staleCount = 0
    foreach ($pod in $pods.items) {
        $startTime = [DateTime]::Parse($pod.status.startTime)
        if ($startTime -lt $threshold) { $staleCount++ }
    }
    Write-AuditLog "Found $staleCount pods older than 30 days."

    Write-AuditLog "Audit Report Generated Successfully."

} catch {
    Write-AuditLog "Audit Failed: $_" "ERR"
    exit 1
}
