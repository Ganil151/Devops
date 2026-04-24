# Lab: Identifying System Bottlenecks

## Objective
Detect a resource bottleneck using PowerShell and resolve it using the appropriate Golden Script.

## Challenge
1. Run the `Invoke-SystemAudit.ps1` script (found in `02-Memory-Management-and-Swap`).
2. Observe the `Disk_Health` and `TCP_AutoTune` metrics.
3. If `Disk_Health` is not "OK", apply `Invoke-SystemMaintenance.ps1 -Mode Basic`.
4. If `TCP_AutoTune` is not "Normal", apply `Optimize-NetworkStack.ps1`.

## Verification
- Run a `Measure-Command` on a simple `git status` or `docker network ls` call to see the before/after performance delta.
