<#
.SYNOPSIS
    Interactive DevOps Skills Assessment
.DESCRIPTION
    This script tests knowledge on Terraform, Docker, PowerShell, CI/CD, and Cloud.
    It calculates scores per category and provides study resources for weaknesses.
#>

# Define the Question Bank
# Method: Using an Array of HashTables to store structured data (Question, Options, Answer, Metadata)
$questions = @(
    @{
        Question = "In Terraform, which block is used to expose values (like an IP) from a module to the root configuration?"
        Options = @("variable", "resource", "output", "module")
        Answer = "output"
        Category = "Infrastructure as Code (IaC)"
        Link = "https://developer.hashicorp.com/terraform/language/values/outputs"
    },
    @{
        Question = "Which Docker command displays live resource usage statistics (CPU, Memory) for containers?"
        Options = @("docker top", "docker inspect", "docker stats", "docker logs")
        Answer = "docker stats"
        Category = "Containerization"
        Link = "https://docs.docker.com/engine/reference/commandline/stats/"
    },
    @{
        Question = "In PowerShell, which keyword is used in a 'try/catch' block to handle an error?"
        Options = @("catch", "except", "rescue", "trap")
        Answer = "catch"
        Category = "Scripting"
        Link = "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally"
    },
    @{
        Question = "Which file is commonly used to store environment variables in key-value pairs for configuration?"
        Options = @(".config", ".env", ".json", ".xml")
        Answer = ".env"
        Category = "Configuration Management"
        Link = "https://12factor.net/config"
    },
    @{
        Question = "Which AWS service is best suited for serverless functions?"
        Options = @("EC2", "RDS", "Lambda", "S3")
        Answer = "Lambda"
        Category = "Cloud Computing"
        Link = "https://aws.amazon.com/lambda/"
    },
    @{
        Question = "Which network driver is used by default if none is specified?"
        Options = @("host", "overlay", "bridge", "none")
        Answer = "bridge"
        Category = "Docker Networking"
        Link = "https://docs.docker.com/network/drivers/bridge/"
    },
    @{
        Question = "Which command lists all Docker networks?"
        Options = @("docker network show", "docker network list", "docker network ls", "docker ls network")
        Answer = "docker network ls"
        Category = "Docker Networking"
        Link = "https://docs.docker.com/engine/reference/commandline/network_ls/"
    },
    @{
        Question = "How do containers on different hosts communicate in a Swarm?"
        Options = @("macvlan", "overlay", "bridge", "none")
        Answer = "overlay"
        Category = "Docker Networking"
        Link = "https://docs.docker.com/network/drivers/overlay/"
    },
    @{
        Question = "Which flag runs a container on the host's network stack?"
        Options = @("--network host", "--net-stack host", "--expose host", "--driver host")
        Answer = "--network host"
        Category = "Docker Networking"
        Link = "https://docs.docker.com/network/drivers/host/"
    },
    @{
        Question = "What explains why `ping container_name` fails on the default bridge network?"
        Options = @("ICMP is disabled", "Automatic DNS resolution is not supported", "Different subnets", "Port 53 blocked")
        Answer = "Automatic DNS resolution is not supported"
        Category = "Docker Networking"
        Link = "https://docs.docker.com/network/drivers/bridge/#differences-between-user-defined-bridges-and-the-default-bridge"
    }
)

# Initialize Scoring
$scores = @{}
$categories = $questions | Select-Object -ExpandProperty Category -Unique
foreach ($cat in $categories) { $scores[$cat] = @{ Correct = 0; Total = 0 } }

# Function to run the test
function Invoke-Assessment {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   Interactive DevOps Skills Assessment  " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""

    foreach ($q in $questions) {
        $scores[$q.Category].Total++
        
        Write-Host "[$($q.Category)]" -ForegroundColor Yellow
        Write-Host $q.Question
        Write-Host ""
        
        # Display Options
        for ($i = 0; $i -lt $q.Options.Count; $i++) {
            Write-Host "$($i+1). $($q.Options[$i])"
        }
        
        # Get User Input
        do {
            $input = Read-Host "Select an option (1-$($q.Options.Count))"
        } until ($input -match "^[1-$($q.Options.Count)]$")
        
        $selectedIndex = [int]$input - 1
        
        # Check Answer
        if ($q.Options[$selectedIndex] -eq $q.Answer) {
            Write-Host "Correct!" -ForegroundColor Green
            $scores[$q.Category].Correct++
        } else {
            Write-Host "Incorrect." -ForegroundColor Red
            Write-Host "The correct answer was: " -NoNewline
            Write-Host "$($q.Answer)" -ForegroundColor White
        }
        Write-Host ""
        Start-Sleep -Seconds 1
    }
}

# Function to display report
function Show-Report {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "           Assessment Report             " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($cat in $scores.Keys) {
        $catScore = $scores[$cat]
        if ($catScore.Total -gt 0) {
            $percent = [math]::Round(($catScore.Correct / $catScore.Total) * 100)
            
            Write-Host "$($cat): " -NoNewline
            
            if ($percent -ge 80) {
                Write-Host "$percent% (Strength)" -ForegroundColor Green
            } elseif ($percent -ge 50) {
                Write-Host "$percent% (Moderate)" -ForegroundColor Yellow
            } else {
                Write-Host "$percent% (Weakness)" -ForegroundColor Red
                
                # Provide Link for Weakness
                $resource = ($questions | Where-Object { $_.Category -eq $cat } | Select-Object -First 1).Link
                Write-Host "  Recommended Study: $resource" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
    Write-Host "Assessment Complete."
}

# Execution Flow
Invoke-Assessment
Show-Report