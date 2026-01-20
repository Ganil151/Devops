# Add-HostsEntry

> Idempotently adds an entry to the Windows Hosts file, ensuring no duplicates are created.

```powershell
$HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$IP = "127.0.0.1"
$Hostname = "dev.local"
$Entry = "$IP       $Hostname"

try {
    if (-not (Test-Path $HostsPath)) { throw "Hosts file not found at $HostsPath" }
    
    $Content = Get-Content $HostsPath
    if ($Content -match [regex]::Escape($Hostname)) {
        Write-Warning "Entry for $Hostname already exists. Skipping."
    }
    else {
        Add-Content -Path $HostsPath -Value $Entry -Encoding UTF8 -ErrorAction Stop
        Write-Host "Added $Hostname -> $IP to Hosts file." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to modify Hosts file: $_"
}
```

## Permissions
*   **Required:** Administrator (Elevated)

## Rollback
```powershell
$HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$Hostname = "dev.local"
(Get-Content $HostsPath) | Where-Object { $_ -notmatch [regex]::Escape($Hostname) } | Set-Content $HostsPath
Write-Host "Removed $Hostname from Hosts file."
```
