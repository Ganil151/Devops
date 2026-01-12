# List active network connections with process names
Write-Host "Active Network Connections:"
Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } | ForEach-Object {
    $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        LocalAddress  = $_.LocalAddress
        LocalPort     = $_.LocalPort
        RemoteAddress = $_.RemoteAddress
        RemotePort    = $_.RemotePort
        ProcessName   = $proc.ProcessName
        PID           = $_.OwningProcess
    }
} | Format-Table -AutoSize

# List services listening on network ports
Write-Host "`nServices Listening on Network Ports:"
Get-NetTCPConnection -State Listen | ForEach-Object {
    $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        LocalAddress = $_.LocalAddress
        LocalPort    = $_.LocalPort
        ProcessName  = $proc.ProcessName
        PID          = $_.OwningProcess
    }
} | Sort-Object LocalPort | Format-Table -AutoSize

# Check Windows Firewall status
Write-Host "`nWindows Firewall Status:"
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize