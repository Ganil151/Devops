# List-UpdateHistory

## Purpose
Retrieves the full history of Windows Update installation attempts (success and failure) using the native Windows Update Agent (COM Object).

## Examples

### Get the last 20 update events
```powershell
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

# Query history: (StartIndex, Count)
$History = $UpdateSearcher.QueryHistory(0, 20)

# Display relevant properties
$History | Select-Object Date, Title, ResultCode, Description
```

### Find failed update attempts
```powershell
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

# Get recent history and filter for ResultCode 0 (Wait) or 1 (InProgress) or 2 (Succeeded), anything else usually indicates failure or cancellation
$UpdateSearcher.QueryHistory(0, 50) | Where-Object { $_.ResultCode -ne 2 } | Select-Object Date, Title
```
