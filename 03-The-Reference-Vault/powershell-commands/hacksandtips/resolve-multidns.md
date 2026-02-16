# Resolve-MultiDns

> Queries multiple DNS servers simultaneously to compare resolution results for a single domain name.

```powershell
$Domain = "microsoft.com"
$Servers = @("8.8.8.8", "1.1.1.1") # Google, Cloudflare

foreach ($Server in $Servers) {
    try {
        $Result = Resolve-DnsName -Name $Domain -Server $Server -ErrorAction Stop | Select-Object -First 1
        [PSCustomObject]@{
            Server = $Server
            ResolvedAddress = $Result.IPAddress
            NameHost = $Result.NameHost
        }
    }
    catch {
        Write-Warning "Failed to resolve against $Server"
    }
}
```

## Permissions
*   **Required:** Standard User

## Rollback
N/A (Read-only operation)
