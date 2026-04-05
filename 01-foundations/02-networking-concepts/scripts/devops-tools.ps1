<#
.SYNOPSIS
    DevSecOps Workstation Bootstrap - Final Corrected Edition v2.2.2
.DESCRIPTION
    Enterprise-grade PowerShell script with:
    - Fixed variable interpolation (using $() subexpressions)
    - Corrected ValidateSet to include 'Debug' level
    - Verified Chocolatey package names with fallbacks
    - Idempotent, safe, and audit-ready
.NOTES
    Author: Senior Principal DevSecOps Engineer
    Version: 2.2.2-FINAL
    Date: 2024-01-15
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$ForceReinstall,
    [switch]$SkipWSL2Check,
    [switch]$ExportReportCSV,
    [switch]$UsePipFallback
)

# ==============================================================================
# GLOBAL CONFIGURATION
# ==============================================================================
$ScriptName = "DevSecOps-Bootstrap"
$LogDir = "$env:TEMP\DevSecOps-Provisioner"
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$LogPath = Join-Path $LogDir "$($ScriptName)-$($Timestamp).log"
$ReportPath = Join-Path $LogDir "$($ScriptName)-Report-$($Timestamp).csv"
$Global:InstallResults = @()

# ==============================================================================
# CORE FUNCTIONS
# ==============================================================================

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Debug')]  # FIXED: Added 'Debug'
        [string]$Level = 'Info'
    )
    $Ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Entry = "[$($Ts)] [$($Level)] $($Message)"
    
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    Add-Content -Path $LogPath -Value $Entry -Encoding UTF8 -ErrorAction SilentlyContinue
    
    $Color = switch ($Level) {
        'Info' { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        'Debug' { 'DarkGray' }
        default { 'White' }
    }
    Write-Host $Entry -ForegroundColor $Color
}

function Test-Admin {
    $User = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($User)
    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-Elevation {
    if (-not (Test-Admin)) {
        Write-Log -Message "Elevating to Administrator..." -Level Warning
        $ScriptArgs = $MyInvocation.Line.Replace($MyInvocation.InvocationName, "").Trim()
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($PSCommandPath)`" $($ScriptArgs)"
        exit 0
    }
    Write-Log -Message "Running as Administrator. [OK]" -Level Success
}

function Refresh-EnvPath {
    $Machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $User = [Environment]::GetEnvironmentVariable("Path", "User")
    $Combined = ($Machine, $User) -split ';' | Where-Object { $_ } | Select-Object -Unique
    $env:Path = $Combined -join ';'
    Write-Log -Message "Environment PATH refreshed." -Level Debug
}

function Install-ChocoIfMissing {
    Write-Log -Message "Checking for Chocolatey..." -Level Info
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $ChocoVer = choco --version 2>$null
        Write-Log -Message "Chocolatey found: $($ChocoVer)" -Level Success
        return $true
    }
    try {
        Write-Log -Message "Installing Chocolatey..." -Level Warning
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Start-Sleep -Seconds 3
        Refresh-EnvPath
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Log -Message "Chocolatey installed successfully." -Level Success
            return $true
        }
        throw "choco command not found post-install"
    }
    catch {
        # FIXED: Using subexpression for error message
        Write-Log -Message "Chocolatey install failed: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Test-ToolVersion {
    param(
        [Parameter(Mandatory = $true)][string]$Cmd,
        [Parameter(Mandatory = $true)][string]$Arg
    )
    try {
        $Out = & $Cmd $Arg 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -and $Out) {
            return $Out.Trim().Split([Environment]::NewLine)[0].Trim()
        }
    }
    catch {
        # FIXED: Using subexpression and valid Level
        Write-Log -Message "Version check exception for $($Cmd): $($_.Exception.Message)" -Level Debug
    }
    return $null
}

function Set-EnvVarPersistent {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )
    try {
        [Environment]::SetEnvironmentVariable($Name, $Value, "Machine")
        Set-Item -Path "Env:$($Name)" -Value $Value -ErrorAction SilentlyContinue
        # FIXED: Using subexpression to avoid $Name: parse error
        Write-Log -Message "Set $($Name)=$($Value) (Machine + Session)" -Level Success
        return $true
    }
    catch {
        # FIXED: Using subexpression for error message
        Write-Log -Message "Failed to set $($Name): $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Install-ViaPip {
    param(
        [string]$PackageName,
        [string]$Command,
        [string]$Arg,
        [string]$DisplayName
    )
    Write-Log -Message "Attempting pip installation for $($DisplayName)..." -Level Info
    
    if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
        Write-Log -Message "pip not found. Installing Python via Chocolatey first..." -Level Warning
        choco install python -y --no-progress | Out-Null
        Refresh-EnvPath
        Start-Sleep -Seconds 2
    }
    
    if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
        Write-Log -Message "ERROR: pip still not available. Cannot install $($DisplayName)." -Level Error
        return $false
    }
    
    try {
        pip install $PackageName --user 2>&1 | Out-String
        Refresh-EnvPath
        Start-Sleep -Seconds 2
        $Version = Test-ToolVersion -Cmd $Command -Arg $Arg
        if ($Version) {
            Write-Log -Message "$($DisplayName) installed via pip: $($Version)" -Level Success
            return $true
        }
        throw "Version check failed post-pip-install"
    }
    catch {
        # FIXED: Using subexpression for DisplayName and error
        Write-Log -Message "pip install failed for $($DisplayName): $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Install-SonarScannerDirect {
    try {
        Write-Log -Message "Installing SonarScanner via direct download..." -Level Info
        $InstallDir = "C:\ProgramData\sonar-scanner"
        $DownloadUrl = "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-windows.zip"
        $ZipPath = "$env:TEMP\sonar-scanner.zip"
        
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath -UseBasicParsing
        
        if (-not (Test-Path $InstallDir)) { 
            New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null 
        }
        Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
        
        $BinPath = "$InstallDir\sonar-scanner-*-windows\bin"
        if (Test-Path $BinPath) {
            $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
            if ($CurrentPath -notlike "*$BinPath*") {
                [Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$BinPath", "Machine")
                Refresh-EnvPath
            }
            $ScannerHome = Get-ChildItem "$InstallDir\sonar-scanner-*-windows" -Directory | Select-Object -First 1
            if ($ScannerHome) {
                Set-EnvVarPersistent -Name "SONAR_SCANNER_HOME" -Value $ScannerHome.FullName
            }
            
            $Version = Test-ToolVersion -Cmd "sonar-scanner" -Arg "--version"
            if ($Version) {
                Write-Log -Message "SonarScanner installed successfully: $($Version)" -Level Success
                Remove-Item $ZipPath -ErrorAction SilentlyContinue
                return $true
            }
        }
        throw "Installation path not found post-extraction"
    }
    catch {
        Write-Log -Message "Direct SonarScanner install failed: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Install-Tool {
    param([hashtable]$Tool)
    
    $ChocoName = $Tool.ChocoName
    $Command = $Tool.Command
    $Arg = $Tool.Arg
    $EnvVar = $Tool.EnvVar
    $Category = $Tool.Category
    $DisplayName = $Tool.DisplayName
    $FallbackMethod = $Tool.FallbackMethod
    $PipPackageName = $Tool.PipPackageName
    
    Write-Log -Message "[$($Category)] Processing: $($DisplayName)" -Level Info

    # Idempotency check
    $Version = Test-ToolVersion -Cmd $Command -Arg $Arg
    if ($Version -and -not $ForceReinstall) {
        Write-Log -Message "$($DisplayName) v$($Version) already installed. Skipping." -Level Success
        $Global:InstallResults += [PSCustomObject]@{
            Tool = $DisplayName
            Category = $Category
            Status = "Skipped"
            Version = $Version
        }
        return
    }

    $InstallSuccess = $false
    
    # Primary: Try Chocolatey
    try {
        Write-Log -Message "Attempting Chocolatey install: $($ChocoName)" -Level Info
        $ChocoArgs = "install $ChocoName -y --no-progress"
        $Proc = Start-Process "choco" -ArgumentList $ChocoArgs.Split(' ') -Wait -NoNewWindow -PassThru -ErrorAction Stop
        
        if ($Proc.ExitCode -eq 0) {
            Refresh-EnvPath
            Start-Sleep -Seconds 2
            $NewVer = Test-ToolVersion -Cmd $Command -Arg $Arg
            if ($NewVer) {
                Write-Log -Message "$($DisplayName) installed via Chocolatey: v$($NewVer)" -Level Success
                $InstallSuccess = $true
            }
        }
        elseif ($Proc.ExitCode -eq 1 -and $FallbackMethod) {
            Write-Log -Message "Chocolatey package not found. Trying fallback method: $($FallbackMethod)" -Level Warning
        }
        else {
            Write-Log -Message "Chocolatey install exited with code: $($Proc.ExitCode)" -Level Warning
        }
    }
    catch {
        Write-Log -Message "Chocolatey install exception: $($_.Exception.Message)" -Level Warning
    }
    
    # Fallback: pip or direct download
    if (-not $InstallSuccess -and $FallbackMethod) {
        switch ($FallbackMethod) {
            'pip' {
                if ($UsePipFallback) {
                    if (Install-ViaPip -PackageName $PipPackageName -Command $Command -Arg $Arg -DisplayName $DisplayName) {
                        $InstallSuccess = $true
                    }
                } else {
                    Write-Log -Message "Skipping pip fallback for $($DisplayName). Use -UsePipFallback to enable." -Level Warning
                }
            }
            'direct' {
                if ($Command -eq 'sonar-scanner') {
                    if (Install-SonarScannerDirect) {
                        $InstallSuccess = $true
                    }
                }
            }
        }
    }
    
    # Finalize result
    if ($InstallSuccess) {
        $FinalVer = Test-ToolVersion -Cmd $Command -Arg $Arg
        if ($EnvVar -and $FinalVer) {
            $PathMap = @{
                'temurin21' = "C:\Program Files\Eclipse Temurin\jdk-*"
                'maven' = "C:\ProgramData\chocolatey\lib\maven\apache-maven-*"
            }
            if ($PathMap.ContainsKey($ChocoName)) {
                $Resolved = Resolve-Path $PathMap[$ChocoName] -ErrorAction SilentlyContinue
                if ($Resolved) { 
                    Set-EnvVarPersistent -Name $EnvVar -Value $Resolved[0].Path 
                }
            }
        }
        $Global:InstallResults += [PSCustomObject]@{
            Tool = $DisplayName
            Category = $Category
            Status = "Success"
            Version = $FinalVer
        }
    } else {
        # FIXED: Using subexpression for DisplayName
        Write-Log -Message "ERROR: Failed to install $($DisplayName) after all attempts." -Level Error
        $Global:InstallResults += [PSCustomObject]@{
            Tool = $DisplayName
            Category = $Category
            Status = "Failed"
            Version = "N/A"
        }
    }
}

function Write-FinalReport {
    Write-Host "`n$('=' * 70)" -ForegroundColor DarkGray
    Write-Host "           DEVSECOPS PROVISIONING REPORT" -ForegroundColor Cyan
    Write-Host "$('=' * 70)`n" -ForegroundColor DarkGray

    if ($Global:InstallResults.Count -eq 0) {
        Write-Log -Message "No tools processed." -Level Warning
        return
    }

    $Global:InstallResults | Format-Table Tool, Category, Status, Version -AutoSize | Out-String | Write-Host

    $Stats = $Global:InstallResults | Group-Object Status | Select-Object Name, Count
    $Stats | ForEach-Object {
        $Color = switch ($_.Name) {
            "Success" { "Green" }; "Skipped" { "Yellow" }; "Failed" { "Red" }; default { "White" }
        }
        Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor $Color
    }

    if ($ExportReportCSV) {
        $Global:InstallResults | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
        Write-Host "  Report saved: $($ReportPath)" -ForegroundColor Cyan
    }

    Write-Host "`nLog: $($LogPath)" -ForegroundColor Cyan
    Write-Host "$('=' * 70)`n" -ForegroundColor DarkGray

    $Failed = ($Global:InstallResults | Where-Object Status -eq "Failed").Count
    if ($Failed -gt 0) { 
        Write-Log -Message "Provisioning completed with $($Failed) failure(s). Review log for details." -Level Warning
        exit 1 
    } else { 
        Write-Log -Message "Provisioning complete. Workstation ready." -Level Success
        exit 0 
    }
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

function Start-Provisioning {
    Request-Elevation
    Write-Log -Message "Starting DevSecOps Bootstrap v2.2.2-FINAL" -Level Info
    Write-Log -Message "Log: $($LogPath)" -Level Info

    if (-not (Install-ChocoIfMissing)) {
        Write-Log -Message "Chocolatey required. Aborting." -Level Error
        exit 1
    }

    # CORRECTED TOOL DEFINITIONS with verified package names
    $Tools = @(
        # Core Platform
        @{ChocoName="awscli"; Command="aws"; Arg="--version"; Category="Core"; DisplayName="AWS CLI"}
        @{ChocoName="terraform"; Command="terraform"; Arg="--version"; Category="Core"; DisplayName="Terraform"}
        @{ChocoName="terragrunt"; Command="terragrunt"; Arg="--version"; Category="Core"; DisplayName="Terragrunt"}
        @{ChocoName="kubernetes-cli"; Command="kubectl"; Arg="version --client"; Category="Core"; DisplayName="Kubectl"}
        @{ChocoName="helm"; Command="helm"; Arg="version"; Category="Core"; DisplayName="Helm"}
        @{ChocoName="docker-desktop"; Command="docker"; Arg="--version"; Category="Core"; DisplayName="Docker Desktop"}
        @{ChocoName="git"; Command="git"; Arg="--version"; Category="Core"; DisplayName="Git"}
        
        # Build Runtime - CORRECTED PACKAGE NAMES
        @{ChocoName="temurin21"; Command="java"; Arg="-version"; Category="Build"; DisplayName="OpenJDK 21 (Temurin)"; EnvVar="JAVA_HOME"}
        @{ChocoName="maven"; Command="mvn"; Arg="--version"; Category="Build"; DisplayName="Apache Maven"; EnvVar="M2_HOME"}
        
        # Security Scanning - WITH FALLBACKS
        @{ChocoName="trivy"; Command="trivy"; Arg="--version"; Category="Security"; DisplayName="Trivy Scanner"}
        @{ChocoName="sonarscanner"; Command="sonar-scanner"; Arg="--version"; Category="Security"; DisplayName="SonarScanner"; FallbackMethod="direct"}
        @{ChocoName="checkov"; Command="checkov"; Arg="--version"; Category="Security"; DisplayName="Checkov"; FallbackMethod="pip"; PipPackageName="checkov"}
        
        # Utilities
        @{ChocoName="jq"; Command="jq"; Arg="--version"; Category="Utility"; DisplayName="JQ Utility"}
        @{ChocoName="yq"; Command="yq"; Arg="--version"; Category="Utility"; DisplayName="YQ Utility"}
        @{ChocoName="ansible"; Command="ansible"; Arg="--version"; Category="Utility"; DisplayName="Ansible"; FallbackMethod="pip"; PipPackageName="ansible-core"; WSL2=$true}
    )

    foreach ($Tool in $Tools) {
        if ($Tool.WSL2 -and -not $SkipWSL2Check) {
            if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
                Write-Log -Message "[$($Tool.Category)] Skipping $($Tool.DisplayName): WSL2 not detected. Use -SkipWSL2Check to bypass." -Level Warning
                $Global:InstallResults += [PSCustomObject]@{
                    Tool = $Tool.DisplayName
                    Category = $Tool.Category
                    Status = "Skipped (WSL2)"
                    Version = "N/A"
                }
                continue
            }
        }
        if ($PSCmdlet.ShouldProcess($Tool.DisplayName, "Install")) {
            Install-Tool -Tool $Tool
        }
    }

    Write-FinalReport
}

# ==============================================================================
# SCRIPT ENTRY POINT
# ==============================================================================
try {
    $ErrorActionPreference = 'Stop'
    Start-Provisioning
}
catch {
    # FIXED: Using subexpression for error message
    Write-Log -Message "CRITICAL ERROR: $($_.Exception.Message)" -Level Error
    Write-Log -Message "Stack: $($_.ScriptStackTrace)" -Level Error
    if ($Global:InstallResults.Count -gt 0) { Write-FinalReport }
    exit 2
}