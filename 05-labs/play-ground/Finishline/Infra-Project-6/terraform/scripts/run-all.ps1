#============================================================
#  Run All Dev Environment Modules (PowerShell)
#============================================================
# This script runs all Terragrunt modules in the correct
# dependency order for the dev environment.
#
# Usage:
#   .\run-all.ps1 [-Action apply]
#
# Examples:
#   .\run-all.ps1 -Action plan    # Plan all changes
#   .\run-all.ps1 -Action apply   # Apply all changes
#   .\run-all.ps1 -Action destroy # Destroy all resources
#============================================================

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("plan", "apply", "destroy")]
    [string]$Action = "apply"
)

#============================================================
# Configuration
#============================================================
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = Split-Path -Parent $ScriptDir
$DevDir = Join-Path -Path $TerraformDir -ChildPath "environments/dev"
$FailedModules = @()
$StartTime = Get-Date

#============================================================
# Helper Functions
#============================================================

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Print-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Cleanup {
    param([int]$ExitCode)
    
    $EndTime = Get-Date
    $Duration = New-TimeSpan -Start $StartTime -End $EndTime
    
    if ($ExitCode -ne 0) {
        Print-Header "Script Failed!"
        Write-Error-Custom "Script terminated after $($Duration.TotalSeconds) seconds"
        if ($FailedModules.Count -gt 0) {
            Write-Error-Custom "Failed modules:"
            foreach ($module in $FailedModules) {
                Write-Error-Custom "  - $module"
            }
        }
        Write-Error-Custom "Exit code: $ExitCode"
    }
    else {
        Print-Header "All Dev Environment modules completed successfully!"
        Write-Info "Total execution time: $($Duration.TotalSeconds) seconds"
    }
    
    # Return to original directory
    Set-Location $ScriptDir -ErrorAction SilentlyContinue
    
    return $ExitCode
}

function Check-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Check if terragrunt is installed
    if (-not (Get-Command terragrunt -ErrorAction SilentlyContinue)) {
        Write-Error-Custom "Terragrunt is not installed or not in PATH"
        Write-Error-Custom "Install terragrunt: https://terragrunt.gruntwork.io/docs/getting-started/install/"
        exit 1
    }
    
    # Check if terraform is installed
    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Error-Custom "Terraform is not installed or not in PATH"
        Write-Error-Custom "Install terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli"
        exit 1
    }
    
    # Check if AWS CLI is installed
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
        Write-Error-Custom "AWS CLI is not installed or not in PATH"
        Write-Error-Custom "Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    }
    
    # Check AWS credentials
    try {
        $awsIdentity = aws sts get-caller-identity 2>$null
        if (-not $awsIdentity) {
            throw "AWS credentials not configured"
        }
        $awsAccount = ($awsIdentity | ConvertFrom-Json).Account
        Write-Info "AWS Account: $awsAccount"
    }
    catch {
        Write-Error-Custom "AWS credentials not configured or invalid"
        Write-Error-Custom "Run 'aws configure' or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
        exit 1
    }
    
    # Check if dev directory exists
    if (-not (Test-Path $DevDir)) {
        Write-Error-Custom "Dev environment directory not found: $DevDir"
        exit 1
    }
    
    Write-Info "All prerequisites checked successfully"
    Write-Info "Action: $Action"
}

function Run-Terragrunt {
    param(
        [string]$Dir,
        [string]$Module,
        [string]$Step
    )
    
    Write-Host ""
    Write-Info "Step $Step`: Running $Module..."
    Write-Host ">>> Module path: $Dir"
    
    # Check if directory exists
    if (-not (Test-Path $Dir)) {
        Write-Error-Custom "Module directory not found: $Dir"
        $script:FailedModules += $Module
        return $false
    }
    
    # Check if terragrunt.hcl exists
    if (-not (Test-Path (Join-Path $Dir "terragrunt.hcl"))) {
        Write-Error-Custom "terragrunt.hcl not found in: $Dir"
        $script:FailedModules += $Module
        return $false
    }
    
    Set-Location $Dir
    
    # Run terragrunt with error capture
    try {
        & terragrunt $Action --terragrunt-non-interactive
        Write-Info "✓ $Module completed successfully"
        Set-Location $DevDir
        return $true
    }
    catch {
        Write-Error-Custom "✗ $Module failed"
        $script:FailedModules += $Module
        Set-Location $DevDir
        return $false
    }
}

#============================================================
# Main Execution
#============================================================

try {
    Print-Header "Running Terragrunt $Action for Dev Environment"
    
    # Check prerequisites
    Check-Prerequisites
    
    # Return to dev dir
    Set-Location $DevDir
    
    #-----------------------------
    # Deployment Order:
    #-----------------------------
    # 1. IAM (creates roles needed by EKS)
    # 2. Key Pair (creates SSH key for jumphost)
    # 3. KMS (creates encryption keys for EKS)
    # 4. VPC (creates networking foundation)
    # 5. Security Groups (depends on VPC)
    # 6. ALB (depends on VPC and SG)
    # 7. EKS (depends on IAM, VPC, SG, KMS)
    # 8. Jumphost (depends on VPC, SG, Key Pair, IAM)
    #-----------------------------
    
    $null = Run-Terragrunt -Dir "$DevDir\security\iam" -Module "IAM Module" -Step "1/8"
    $null = Run-Terragrunt -Dir "$DevDir\security\key_pair" -Module "Key Pair Module" -Step "2/8"
    $null = Run-Terragrunt -Dir "$DevDir\security\kms" -Module "KMS Module" -Step "3/8"
    $null = Run-Terragrunt -Dir "$DevDir\networking\vpc" -Module "VPC Module" -Step "4/8"
    $null = Run-Terragrunt -Dir "$DevDir\networking\sg" -Module "Security Groups Module" -Step "5/8"
    $null = Run-Terragrunt -Dir "$DevDir\networking\alb" -Module "ALB Module" -Step "6/8"
    $null = Run-Terragrunt -Dir "$DevDir\compute\eks" -Module "EKS Module" -Step "7/8"
    $null = Run-Terragrunt -Dir "$DevDir\compute\jumphost" -Module "Jumphost Module" -Step "8/8"
    
    # Check if any modules failed
    if ($FailedModules.Count -gt 0) {
        Write-Warn "Some modules failed. See errors above."
        $exitCode = Cleanup -ExitCode 1
        exit $exitCode
    }
    
    $exitCode = Cleanup -ExitCode 0
    exit $exitCode
}
catch {
    Write-Error-Custom "Unexpected error: $_"
    $exitCode = Cleanup -ExitCode 1
    exit $exitCode
}
