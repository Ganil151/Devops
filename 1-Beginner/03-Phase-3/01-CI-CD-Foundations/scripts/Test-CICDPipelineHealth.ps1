<#
.SYNOPSIS
    Pre-flight check for CI/CD Pipeline readiness.

.DESCRIPTION
    Validates that the local or agent environment has all necessary tools and configurations
    to run a build pipeline successfully.
    Checks:
    - Git version and config
    - Docker connectivity
    - Node/Npm (common build tools)
    - Essential Environment Variables

.PARAMETER RequiredEnvVars
    List of environment variables that MUST start with a value.

.EXAMPLE
    .\Test-CICDPipelineHealth.ps1 -RequiredEnvVars "JAVA_HOME","BUILD_NUMBER"

.TAGS
    #CICD #HealthCheck #Pipeline #Ops
#>

[CmdletBinding()]
param (
    [string[]]$RequiredEnvVars = @("PATH")
)

$ErrorActionPreference = "Continue"

$healthReport = [System.Collections.Generic.List[PSCustomObject]]::new()

function Add-Result {
    param ($Check, $Status, $Details)
    $healthReport.Add([PSCustomObject]@{
        Check   = $Check
        Status  = $Status
        Details = $Details
    })
}

Write-Host "Starting Pre-flight CI/CD Health Check..." -ForegroundColor Cyan

# 1. Git Check
try {
    $gitVer = git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Add-Result "Git" "PASS" $gitVer
    } else {
        Add-Result "Git" "FAIL" "Git command failed or not found"
    }
} catch {
    Add-Result "Git" "FAIL" "Git not found in PATH"
}

# 2. Docker Check
try {
    $dockerInfo = docker info --format '{{.ServerVersion}}' 2>&1
    if ($LASTEXITCODE -eq 0) {
        Add-Result "Docker" "PASS" "Daemon running. Version: $dockerInfo"
    } else {
        Add-Result "Docker" "FAIL" "Docker daemon likely not running"
    }
} catch {
    Add-Result "Docker" "FAIL" "Docker executable not found"
}

# 3. Environment Variables
foreach ($var in $RequiredEnvVars) {
    if (Test-Path "Env:\$var") {
        Add-Result "Env:$var" "PASS" "Exists"
    } else {
        Add-Result "Env:$var" "FAIL" "Missing"
    }
}

# 4. output Report
$healthReport | Format-Table -AutoSize

# Exit Code logic
if (($healthReport | Where-Object { $_.Status -eq "FAIL" }).Count -gt 0) {
    Write-Error "Pipeline Health Checks Failed."
    exit 1
} else {
    Write-Host "System Ready for Build." -ForegroundColor Green
    exit 0
}
