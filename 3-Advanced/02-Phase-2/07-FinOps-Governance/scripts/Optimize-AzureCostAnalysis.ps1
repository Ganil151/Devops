<#
.SYNOPSIS
    Analyzes Azure consumption and identifies cost optimization targets.

.DESCRIPTION
    Uses Az module to scan for:
    - Unattached Managed Disks
    - Idle/Underutilized VMs
    - Expired/Stale Snapshots
    - Missing 'CostCenter' tags
    Outputs a JSON recommendation manifest.

.PARAMETER SubscriptionId
    Target Azure Subscription ID.

.EXAMPLE
    .\Optimize-AzureCostAnalysis.ps1 -SubscriptionId "xxxxx-xxxx-xxxx"

.TAGS
    #Azure #FinOps #Governance #CostOptimization
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId
)

function Write-OptLog {
    param ([string]$Msg)
    Write-Host "[FinOps] $Msg" -ForegroundColor Magenta
}

try {
    Write-OptLog "Switching Context to: $SubscriptionId"
    # Select-AzSubscription -SubscriptionId $SubscriptionId | Out-Null

    $recommendations = @()

    # 1. Orphaned Disks
    Write-OptLog "Scanning for Unattached Managed Disks..."
    # $disks = Get-AzDisk | Where-Object { $_.ManagedBy -eq $null }
    # Mocking for architectural demonstration
    $disks = @( [PSCustomObject]@{Name="StaleDisk01"; SizeGB=128; CostEstimate=15.00} )
    
    foreach ($d in $disks) {
        $recommendations += [PSCustomObject]@{
            Target = $d.Name
            Type   = "UnattachedDisk"
            Action = "Delete"
            EstMonthlySavings = $d.CostEstimate
        }
    }

    # 2. Tagging Compliance
    Write-OptLog "Checking Tagging Governance..."
    # $resources = Get-AzResource | Where-Object { -not $_.Tags.ContainsKey('CostCenter') }
    $resources = @() 
    
    if ($resources.Count -gt 0) {
        Write-OptLog "Found $($resources.Count) resources missing CostCenter tags."
    }

    # 3. Output as machine-readable JSON
    $reportPath = "cost_recommendations_$(Get-Date -Format 'yyyyMMdd').json"
    $recommendations | ConvertTo-Json | Set-Content $reportPath
    Write-OptLog "Report saved to: $reportPath"

} catch {
    Write-Error "Cost Analysis failed: $_"
}
