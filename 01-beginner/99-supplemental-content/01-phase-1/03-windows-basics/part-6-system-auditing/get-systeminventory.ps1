<#
.SYNOPSIS
    Retrieves a comprehensive inventory of the local system's hardware and OS.
.DESCRIPTION
    Uses CIM classes (Win32_OperatingSystem, Win32_ComputerSystem, Win32_Processor) to build a system profile.
    Output is returning as a custom PowerShell object for easy export to CSV/JSON.
.EXAMPLE
    .\Get-SystemInventory.ps1 | ConvertTo-Json
#>

try {
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
    $Comp = Get-CimInstance -ClassName Win32_ComputerSystem
    $CPU = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

    [PSCustomObject]@{
        ComputerName = $OS.CSName
        OSName       = $OS.Caption
        Version      = $OS.Version
        Manufacturer = $Comp.Manufacturer
        Model        = $Comp.Model
        RAM_GB       = [math]::Round($Comp.TotalPhysicalMemory / 1GB, 2)
        CPU          = $CPU.Name
        Cores        = $CPU.NumberOfCores
        LastBoot     = $OS.LastBootUpTime
    }
}
catch {
    Write-Error "Failed to retrieve inventory: $_"
}
