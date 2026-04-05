# Test-TcpPort

> Tests TCP connectivity to a specific port on a remote host, providing boolean success/fail logic suitable for scripts.

```powershell
$Computer = "google.com"
$Port = 443

try {
    $Test = Test-NetConnection -ComputerName $Computer -Port $Port -InformationLevel Quiet
    if ($Test) {
        Write-Host "Connection to $Computer : $Port - SUCCESS" -ForegroundColor Green
    }
    else {
        Write-Host "Connection to $Computer : $Port - FAILED" -ForegroundColor Red
    }
}
catch {
    Write-Error "Network test failed to execute: $_"
}
```

## Permissions
*   **Required:** Standard User

## Rollback
N/A (Read-only operation)
