# Test-NetConnection

## Purpose
Checks network connectivity to a specific computer, port, or service, providing diagnostic information like ping latency and TCP handshake success.

## Examples

### Ping a remote host (default behavior)
```powershell
Test-NetConnection -ComputerName "google.com"
```

### Test TCP connectivity to a specific port
```powershell
Test-NetConnection -ComputerName "192.168.1.10" -Port 80
```

### Perform a traceroute to diagnose routing issues
```powershell
Test-NetConnection -ComputerName "example.com" -TraceRoute
```
