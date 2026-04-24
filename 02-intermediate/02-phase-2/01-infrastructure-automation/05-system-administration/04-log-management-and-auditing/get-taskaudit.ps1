<#
.SYNOPSIS
    Audits Scheduled Tasks, filtering out built-in Microsoft tasks to find custom or 3rd party jobs.
.DESCRIPTION
    Iterates through the Task Scheduler folder structure. Excludes tasks where the TaskPath starts with "\Microsoft\".
.EXAMPLE
    .\Get-TaskAudit.ps1
#>

try {
    Get-ScheduledTask | Where-Object { $_.TaskPath -notlike "\Microsoft\*" } | ForEach-Object {
        [PSCustomObject]@{
            Name      = $_.TaskName
            Path      = $_.TaskPath
            State     = $_.State
            User      = $_.Principal.UserId
            NextRun   = $(Get-ScheduledTaskInfo -TaskName $_.TaskName).NextRunTime
        }
    }
}
catch {
    Write-Error "Failed to enumerate tasks: $_"
}
