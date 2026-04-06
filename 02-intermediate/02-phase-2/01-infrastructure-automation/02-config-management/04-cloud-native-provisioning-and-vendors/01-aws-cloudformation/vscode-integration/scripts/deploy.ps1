#Requires -Version 5.1
<#
.SYNOPSIS
    Deploy AWS CloudFormation stack
.DESCRIPTION
    Validates and deploys a CloudFormation template to AWS
.PARAMETER StackName
    Name of the CloudFormation stack
.PARAMETER TemplateFile
    Path to the CloudFormation template file (default: template.yaml)
.PARAMETER Environment
    Deployment environment (default: dev)
.EXAMPLE
    .\deploy.ps1 -StackName my-stack -TemplateFile template.yaml -Environment prod
.EXAMPLE
    .\deploy.ps1 my-stack
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$StackName,
    
    [Parameter(Mandatory=$false, Position=1)]
    [string]$TemplateFile = "template.yaml",
    
    [Parameter(Mandatory=$false, Position=2)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev"
)

# Color output helper
function Write-Status {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CloudFormation Deployment" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Stack Name:    $StackName" -ForegroundColor Yellow
Write-Host "Template:      $TemplateFile" -ForegroundColor Yellow
Write-Host "Environment:   $Environment" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

# Check if template file exists
if (-not (Test-Path $TemplateFile)) {
    Write-Status "❌ Error: Template file '$TemplateFile' not found!" "Red"
    exit 1
}

# Validate template
Write-Host ""
Write-Status "📋 Step 1: Validating template..." "Yellow"
$validateResult = aws cloudformation validate-template --template-body file://$TemplateFile 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Status "✅ Template is valid" "Green"
} else {
    Write-Status "❌ Template validation failed! Aborting deployment." "Red"
    Write-Host $validateResult -ForegroundColor Red
    exit 1
}

# Deploy stack
Write-Host ""
Write-Status "🚀 Step 2: Deploying stack..." "Yellow"
aws cloudformation deploy `
  --template-file $TemplateFile `
  --stack-name $StackName `
  --parameter-overrides Environment=$Environment `
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM `
  --no-fail-on-empty-changeset `
  --output text

if ($LASTEXITCODE -eq 0) {
    Write-Status "✅ Stack deployed successfully!" "Green"
} else {
    Write-Status "❌ Stack deployment failed!" "Red"
    exit 1
}

# Show stack outputs
Write-Host ""
Write-Status "📊 Step 3: Stack Outputs" "Yellow"
Write-Host "==========================================" -ForegroundColor Cyan
aws cloudformation describe-stacks `
  --stack-name $StackName `
  --query 'Stacks[0].Outputs' `
  --output table

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Status "✅ Deployment Complete!" "Green"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Stack Name: $StackName" -ForegroundColor Yellow
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host ""
Write-Host "To delete this stack, run:" -ForegroundColor Gray
Write-Host "  aws cloudformation delete-stack --stack-name $StackName" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan
