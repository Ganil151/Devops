<#
.SYNOPSIS
    Maven Multi-Module Generator
.DESCRIPTION
    Scaffolds a Maven multi-module project structure.
#>

param(
    [string]$GroupId = "com.example",
    [string]$ArtifactId = "my-app",
    [string[]]$Modules = @("core", "service", "web")
)

Write-Host "Generating Maven Multi-Module Project..." -ForegroundColor Cyan

# Root
mvn archetype:generate -DgroupId=$GroupId -DartifactId=$ArtifactId -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
Set-Location $ArtifactId

# Remove src from root (parent POM only)
Remove-Item -Recurse -Force src

# Update POM packaging to pom
$pomContent = Get-Content pom.xml
$pomContent = $pomContent -replace "<packaging>jar</packaging>", "<packaging>pom</packaging>"
$pomContent | Set-Content pom.xml

# Generate Modules
foreach ($mod in $Modules) {
    Write-Host "Adding Module: $mod"
    mvn archetype:generate -DgroupId=$GroupId -DartifactId=$mod -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
}

Write-Host "Done. Project created in $ArtifactId" -ForegroundColor Green
