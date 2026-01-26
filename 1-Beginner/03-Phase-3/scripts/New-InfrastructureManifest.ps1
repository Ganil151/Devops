<#
.SYNOPSIS
    Scaffolds a new infrastructure environment/project directory.

.DESCRIPTION
    Enforces the "100/100 Health Pattern" by creating a standardized directory structure
    for new infrastructure projects.
    Creates:
    - /manifests (k8s/docker)
    - /scripts (automation)
    - /tests (pester)
    - README.md (documentation standard)
    - .gitignore (standard ops patterns)

.PARAMETER ProjectName
    Name of the new project folder.

.PARAMETER BasePath
    Where to create the project. Default is current directory.

.EXAMPLE
    .\New-InfrastructureManifest.ps1 -ProjectName "PaymentService-Infra"

.TAGS
    #Scaffolding #Standardization #IaC
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [string]$BasePath = "."
)

$ErrorActionPreference = "Stop"

function New-Dir {
    param ($Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Host "Created: $Path" -ForegroundColor Green
    }
}

function New-File {
    param ($Path, $Content)
    if (-not (Test-Path $Path)) {
        Set-Content -Path $Path -Value $Content
        Write-Host "Created File: $Path" -ForegroundColor Green
    }
}

$projectRoot = Join-Path -Path $BasePath -ChildPath $ProjectName

Write-Host "Scaffolding new Infra Project: $ProjectName" -ForegroundColor Cyan

if ($PSCmdlet.ShouldProcess($projectRoot, "Create Infrastructure Scaffold")) {
    
    # 1. Directories
    New-Dir $projectRoot
    New-Dir (Join-Path $projectRoot "manifests")
    New-Dir (Join-Path $projectRoot "scripts")
    New-Dir (Join-Path $projectRoot "tests")
    New-Dir (Join-Path $projectRoot "docs")

    # 2. README.md
    $readmeContent = @"
# $ProjectName
## Infrastructure Overview

### 🏗️ Architecture
Add architecture diagram here.

### 🚀 Quick Start
1. Run `./scripts/init.ps1`
2. Apply manifests

### 📋 Prerequisites
- PowerShell 7+
- Kubernetes CLI / Docker

### 🧪 Testing
Run `Invoke-Pester ./tests`
"@
    New-File (Join-Path $projectRoot "README.md") $readmeContent

    # 3. .gitignore
    $gitIgnore = @"
*.log
.terraform/
.env
secret.json
tmp/
"@
    New-File (Join-Path $projectRoot ".gitignore") $gitIgnore

    # 4. Init Script Stub
    $initScript = @"
Write-Host 'Initializing $ProjectName...'
# Add setup logic here
"@
    New-File (Join-Path $projectRoot "scripts/init.ps1") $initScript
}

Write-Host "Scaffolding Complete. Ready for code." -ForegroundColor Cyan
