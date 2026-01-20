<#
.SYNOPSIS
    Audits Windows Update history to determine patch compliance.
.DESCRIPTION
    Uses the Microsoft.Update.Session COM object to query the local update history.
    Calculates "Age of Last Patch" to flag neglected systems.
.EXAMPLE
    .\Get-PatchCompliance.ps1
#>

try {
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()
    # Get last 10 history items
    $History = $Searcher.QueryHistory(0, 10) | Select-Object Date, Title, ResultCode

    $LastSuccess = $History | Where-Object { $_.ResultCode -eq 2 } | Select-Object -First 1
    
    $DaysMetrics = "N/A"
    if ($LastSuccess) {
        $DaysMetrics = ((Get-Date) - $LastSuccess.Date).Days
    }

    [PSCustomObject]@{
        "Last Successful Patch" = $LastSuccess.Date
        "Days Since Patch"      = $DaysMetrics
        "Last Patch Title"      = $LastSuccess.Title
        "Compliance Status"     = if ($DaysMetrics -lt 30) { "Healthy" } else { "At Risk" }
    }
}
catch {
    Write-Error "Failed to query Update Agent: $_"
}
