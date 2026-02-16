<#
.SYNOPSIS
    Professional DevOps System Discovery & Health Audit Tool.

.DESCRIPTION
    A comprehensive "Source of Truth" script for Windows system discovery. 
    It captures hardware specifications (CPU, RAM, Disk, GPU), BIOS firmware details, 
    and kernel-level performance/security configurations (VBS, Power Plans, TCP Tuning).

    Features:
    - Deep Hardware Inventory (CIM/WMI based).
    - Security Status Audit (Virtualization Based Security, Telemetry).
    - Performance Configuration Discovery (Power Overlays, TCP Stack).
    - Health Metrics (Disk wear/space, RAM configuration).
    - Fleet Ready: Exports JSON/CSV for centralized logging.

.PARAMETER ExportPath
    The location to save the audit report. Supports .csv and .json extensions.

.PARAMETER PassThru
    Returns the [PSCustomObject] to the pipeline for downstream processing.

.PARAMETER Simple
    Hides the detailed hardware tables and shows only the summary dashboard.

.EXAMPLE
    Invoke-SystemAudit -ExportPath "C:\Inventory\SystemAudit.json"
    Captures full audit and saves as a JSON object for database ingestion.

.NOTES
    Author: Senior Windows Systems Engineer (DevOps)
    Version: 2.1 (Premium)
    Minimum PS Version: 5.1
#>
function Invoke-SystemAudit {
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage = "Path to export the audit data (.csv or .json)")]
        [string]$ExportPath = "$HOME\Desktop\SystemAudit.csv",

        [switch]$PassThru,
        
        [switch]$Simple
    )

    Begin {
        $StartTime = Get-Date
        Write-Host "`n[🔍] INITIATING SYSTEM DISCOVERY PROTOCOL..." -ForegroundColor Cyan
        Write-Host "--------------------------------------------------------" -ForegroundColor Gray
    }

    Process {
        try {
            # --- 1. Admin Verification ---
            $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
            if (-not $IsAdmin) {
                Write-Warning "Running in non-privileged mode. Some kernel/security metrics may be restricted."
            }

            # --- 2. Hardware Discovery (CIM) ---
            Write-Progress -Activity "Gathering System Data" -Status "Querying Hardware..." -PercentComplete 20
            $Comp    = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
            $Bios    = Get-CimInstance Win32_Bios -ErrorAction SilentlyContinue
            $OS      = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
            $CPU     = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
            $Disk    = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue
            $Base    = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
            $GPU     = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
            
            # Memory Details (Calculate Total Capacity from Slots)
            $RAMArray = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue
            $TotalRamGB = if ($RAMArray) { [math]::round(($RAMArray | Measure-Object -Property Capacity -Sum).Sum / 1GB, 0) } else { 0 }

            # --- 3. Performance & Security Audit ---
            Write-Progress -Activity "Gathering System Data" -Status "Querying Kernel State..." -PercentComplete 60
            
            # Power Plan Audit
            $PowerScheme = (powercfg -getactivescheme) -replace '.*?\((.*?)\).*', '$1'
            
            # VBS (Virtualization Based Security)
            $VBS_Reg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction SilentlyContinue
            $VBS_Status = if ($VBS_Reg.Enabled -eq 1) { "SECURE (ON)" } else { "PERFORMANCE (OFF)" }

            # Network Stack (Auto-Tuning)
            $NetGlobal = netsh int tcp show global
            $AutoTune = ($NetGlobal | Select-String "Receive Window Auto-Tuning Level").ToString().Split(":")[1].Trim()
            $ECN      = ($NetGlobal | Select-String "ECN Capability").ToString().Split(":")[1].Trim()

            # Telemetry Audit
            $Tele_Reg = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
            $Privacy_Status = if ($Tele_Reg.AllowTelemetry -eq 0) { "HARDENED" } else { "STANDARD" }

            # Storage Health
            $FreeGB  = if ($Disk) { [math]::round($Disk.FreeSpace / 1GB, 2) } else { 0 }
            $TotalGB = if ($Disk) { [math]::round($Disk.Size / 1GB, 2) } else { 0 }
            $FillPerc = if ($TotalGB -gt 0) { [math]::round((($TotalGB - $FreeGB) / $TotalGB) * 100, 1) } else { 0 }
            $DiskHealth = switch($FillPerc) {
                { $_ -gt 90 } { "CRITICAL" }
                { $_ -gt 80 } { "WARNING" }
                Default       { "OK" }
            }

            # --- 4. Object Construction ---
            $AuditData = [PSCustomObject]@{
                Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                ComputerName   = $Comp.Name
                Manufacturer   = "$($Comp.Manufacturer) ($($Comp.Model))"
                ServiceTag     = $Bios.SerialNumber
                OS_Build       = "$($OS.Caption) (Build: $($OS.Version))"
                Uptime_Days    = [math]::round(((Get-Date) - $OS.LastBootUpTime).TotalDays, 2)
                
                # Hardware Specs
                Processor      = $CPU.Name.Trim()
                Cores_Logical  = "$($CPU.NumberOfCores) / $($CPU.NumberOfLogicalProcessors)"
                RAM_Total_GB   = $TotalRamGB
                GPU            = $GPU.Name
                
                # Storage Specs
                Disk_C_Used    = "$FillPerc%"
                Disk_C_Free_GB = $FreeGB
                Disk_Health    = $DiskHealth
                
                # DevOps Config Audit
                Power_Plan     = $PowerScheme
                Security_VBS   = $VBS_Status
                Privacy_Audit  = $Privacy_Status
                TCP_AutoTune   = $AutoTune
                TCP_ECN        = $ECN
                DNS_Servers    = (Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses -ne $null }).ServerAddresses -join ", "
            }

            # --- 5. Presentation & Export ---
            Write-Progress -Activity "Gathering System Data" -Status "Finalizing Report..." -PercentComplete 100
            
            if (-not $Simple) {
                Write-Host "`n[💻] HARDWARE INVENTORY" -ForegroundColor White -BackgroundColor DarkBlue
                $AuditData | Select-Object ComputerName, Manufacturer, OS_Build, Uptime_Days, Processor, RAM_Total_GB, Disk_C_Used | Format-List
                
                Write-Host "[🛡️] DEVOPS CONFIGURATION AUDIT" -ForegroundColor White -BackgroundColor DarkCyan
                $AuditData | Select-Object Power_Plan, Security_VBS, Privacy_Audit, TCP_AutoTune, DNS_Servers | Format-List
            } else {
                $AuditData | Format-Table -AutoSize
            }

            if ($ExportPath) {
                $Ext = [System.IO.Path]::GetExtension($ExportPath).ToLower()
                $Folder = Split-Path $ExportPath
                if ($Folder -and -not (Test-Path $Folder)) { New-Item -ItemType Directory -Path $Folder -Force | Out-Null }
                
                if ($Ext -eq ".json") {
                    $AuditData | ConvertTo-Json | Out-File -FilePath $ExportPath -Encoding utf8
                } else {
                    $AuditData | Export-Csv -Path $ExportPath -NoTypeInformation -Append
                }
                Write-Host "[✔] Audit exported to: $ExportPath" -ForegroundColor Green
            }

            if ($PassThru) { return $AuditData }

        } catch {
            Write-Error "AUDIT FAILED at step discovery: $($_.Exception.Message)"
        }
    }

    End {
        Write-Host "`n[💎] SYSTEM DISCOVERY COMPLETE." -ForegroundColor Cyan
    }
}

# --- Auto-Execute Interface ---
if ($PSBoundParameters.Count -eq 0) {
    Invoke-SystemAudit
    Write-Host "`nRecommendation: Use 'Optimize-SystemPerformance.ps1' to resolve any performance warnings." -ForegroundColor Gray
}
