<#
.SYNOPSIS
    Audits local logical disks for total size and free space.
.DESCRIPTION
    Uses Win32_LogicalDisk to report on drive usage. Useful for verifying basic storage health.
.EXAMPLE
    .\Get-DiskUsage.ps1
#>

try {
    Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object DriveType -eq 3 | ForEach-Object {
        [PSCustomObject]@{
            Drive        = $_.DeviceID
            Label        = $_.VolumeName
            SizeGB       = [math]::Round($_.Size / 1GB, 2)
            FreeGB       = [math]::Round($_.FreeSpace / 1GB, 2)
            PercentFree  = [math]::Round(($_.FreeSpace / $_.Size) * 100, 1)
        }
    }
}
catch {
    Write-Error "Failed to audit disks: $_"
}
