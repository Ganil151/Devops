<#
.SYNOPSIS
    Maps active TCP/IP listening ports to their owning process and service name.
.DESCRIPTION
    Correlates Get-NetTCPConnection output with Get-Process to identify "What is listening on Port X?".
    This is critical for validation of firewall rules and system hardening.
.EXAMPLE
    .\Audit-NetworkServices.ps1
#>

try {
    $Listeners = Get-NetTCPConnection -State Listen
    
    foreach ($L in $Listeners) {
        $Process = Get-Process -Id $L.OwningProcess -ErrorAction SilentlyContinue
        
        [PSCustomObject]@{
            LocalPort    = $L.LocalPort
            LocalAddress = $L.LocalAddress
            Protocol     = "TCP"
            PID          = $L.OwningProcess
            ProcessName  = $Process.ProcessName
            Path         = $Process.Path
        }
    }
}
catch {
    Write-Warning "Some processes could not be resolved. Ensure you are running as Administrator."
}
