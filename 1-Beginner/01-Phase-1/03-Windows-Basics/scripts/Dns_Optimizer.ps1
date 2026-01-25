# --- Run as Admin Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! Administrator privileges are required to change DNS settings !!!"
    Pause; Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "    WIN 11 SMART DNS & ADAPTER TOOL          " -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host " 1. SET: Cloudflare DNS (1.1.1.1)             "
    Write-Host " 2. SET: Google DNS (8.8.8.8)                 "
    Write-Host " 3. RESET: Back to Automatic (DHCP)          "
    Write-Host " 4. SHOW: My Current DNS Settings             "
    Write-Host " 5. Exit                                     "
    Write-Host "==============================================" -ForegroundColor Green
}

Show-Menu
$choice = Read-Host "Select an option [1-5]"

# Get all Ethernet and Wi-Fi adapters that are currently up/active
$adapters = Get-NetAdapter | Where-Object { ($_.Name -match "Ethernet" -or $_.Name -match "Wi-Fi") -and $_.Status -eq "Up" }

if ($null -eq $adapters) {
    Write-Warning "No active Ethernet or Wi-Fi adapters found."
    Pause; Exit
}

switch ($choice) {
    "1" {
        $DNS = @("1.1.1.1", "1.0.0.1")
        Write-Host "Setting DNS to Cloudflare..." -ForegroundColor Cyan
    }
    "2" {
        $DNS = @("8.8.8.8", "8.8.4.4")
        Write-Host "Setting DNS to Google..." -ForegroundColor Cyan
    }
    "3" {
        Write-Host "Resetting to Automatic (DHCP)..." -ForegroundColor Yellow
        foreach ($adapter in $adapters) {
            Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
        }
        Write-Host "DNS reset complete." -ForegroundColor Green
        Pause; return
    }
    "4" {
        Get-DnsClientServerAddress | Where-Object { $_.InterfaceAlias -match "Ethernet|Wi-Fi" } | Select-Object InterfaceAlias, ServerAddresses
        Pause; return
    }
    "5" { Exit }
    default { Write-Warning "Invalid selection"; Pause; return }
}

# Apply the DNS to all detected active adapters
foreach ($adapter in $adapters) {
    try {
        Write-Host "Applying to: $($adapter.Name)" -ForegroundColor Gray
        Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses $DNS
        Write-Host "Successfully updated $($adapter.Name)!" -ForegroundColor Green
    } catch {
        Write-Error "Failed to update $($adapter.Name). Error: $_"
    }
}

Write-Host "`nAll active adapters updated." -ForegroundColor Green
Pause