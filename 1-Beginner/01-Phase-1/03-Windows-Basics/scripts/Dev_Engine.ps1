# --- Administrator Authorization ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! CRITICAL: DevOps Tweaks require Administrator privileges !!!"
    Pause; Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Blue
    Write-Host "        WINDOWS 11 DEVOPS ENGINEER MASTER SUITE         " -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Blue
    Write-Host " [1] AUDIT    : Smart Check & Install DevOps Toolchain   "
    Write-Host " [2] VIRTUAL  : Enable WSL2 Mirrored Mode & Network Fix  "
    Write-Host " [3] CONTEXT  : Switch AWS Profile / Kubernetes Context  "
    Write-Host " [4] BOOTSTRAP: Scaffold New DevOps Project Structure    "
    Write-Host " [5] SSH      : Secure ED25519 Key Gen & SSH-Agent       "
    Write-Host " [6] EXIT                                                "
    Write-Host "=========================================================" -ForegroundColor Blue
}

# --- Module 1: Smart Tool Audit & Install ---
function Audit-Toolchain {
    Write-Host "[+] Auditing DevOps Toolchain..." -ForegroundColor Cyan
    $tools = @{
        "terraform" = "Hashicorp.Terraform"
        "aws"       = "Amazon.AWSCLI"
        "az"        = "Microsoft.AzureCLI"
        "kubectl"   = "Kubernetes.kubectl"
        "helm"      = "Helm.Helm"
        "k9s"       = "K9s.K9s"
        "gh"        = "GitHub.cli"
    }

    foreach ($cmd in $tools.Keys) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            Write-Host "  [FOUND] $cmd is already installed." -ForegroundColor Gray
        } else {
            Write-Host "  [MISSING] Installing $($tools[$cmd])..." -ForegroundColor Yellow
            winget install $($tools[$cmd]) -e --accept-source-agreements | Out-Null
            Write-Host "  [✔] Installed $cmd." -ForegroundColor Green
        }
    }
}

# --- Module 2: WSL2 Network Fix ---
function Fix-WSLNetwork {
    Write-Host "[+] Enabling WSL2 Mirrored Networking..." -ForegroundColor Green
    $wslConfigPath = "$env:USERPROFILE\.wslconfig"
    $config = "[wsl2]`nnetworkingMode=mirrored`ndnsTunneling=true`nfirewall=true`nautoProxy=true"
    $config | Out-File $wslConfigPath -Encoding ascii
    wsl --shutdown
    Write-Host "[✔] WSL2 Networking Optimized. Restart WSL to apply." -ForegroundColor Green
}

# --- Module 3: Context Switcher ---
function Switch-Context {
    Write-Host "`n[1] AWS Profile | [2] K8s Context" -ForegroundColor Yellow
    $type = Read-Host "Select Type"
    if ($type -eq "1") {
        $profiles = git config --file "$env:USERPROFILE\.aws\config" --get-regexp "profile" | ForEach-Object { ($_ -split "\.")[1] -split " " | Select-Object -First 1 }
        if (!$profiles) { return }
        for ($i=0; $i -lt $profiles.Count; $i++) { Write-Host "[$i] $($profiles[$i])" }
        $idx = Read-Host "Select Index"
        $env:AWS_PROFILE = $profiles[$idx]
        Write-Host "Active AWS Profile: $env:AWS_PROFILE" -ForegroundColor Green
    } elseif ($type -eq "2") {
        $contexts = kubectl config get-contexts -o name
        for ($i=0; $i -lt $contexts.Count; $i++) { Write-Host "[$i] $($contexts[$i])" }
        $idx = Read-Host "Select Index"
        kubectl config use-context $contexts[$idx]
    }
}

# --- Module 4: Project Bootstrapper ---
function Bootstrap-Project {
    $projectName = Read-Host "Enter New Project Name"
    $basePath = "C:\Projects\$projectName"
    
    Write-Host "[+] Scaffolding $projectName..." -ForegroundColor Cyan
    
    $dirs = @(
        "terraform/environments/dev",
        "terraform/environments/prod",
        "terraform/modules",
        "kubernetes/overlays/dev",
        "kubernetes/overlays/prod",
        "kubernetes/base",
        "scripts",
        ".github/workflows"
    )

    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Path (Join-Path $basePath $dir) -Force | Out-Null
    }

    # Create dummy README and basic .gitignore
    "Project: $projectName`nCreated: $(Get-Date)" | Out-File (Join-Path $basePath "README.md")
    "terraform.tfstate*`n.terraform/`n*.exe`n.env" | Out-File (Join-Path $basePath ".gitignore")
    
    Write-Host "[✔] Project Scaffolding Complete at $basePath" -ForegroundColor Green
}

# --- Module 5: Secure SSH ---
function Setup-SSH {
    Write-Host "[+] Setting up Secure SSH..." -ForegroundColor Cyan
    if (!(Test-Path "$env:USERPROFILE\.ssh\id_ed25519")) {
        ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519" -N '""'
    }
    Set-Service -Name ssh-agent -StartupType Automatic
    Start-Service ssh-agent
    ssh-add "$env:USERPROFILE\.ssh\id_ed25519"
    Write-Host "[✔] SSH-Agent running with ED25519 key." -ForegroundColor Green
}

# --- Main Logic ---
while ($true) {
    Show-Menu
    $choice = Read-Host "Select Module"
    switch ($choice) {
        "1" { Audit-Toolchain }
        "2" { Fix-WSLNetwork }
        "3" { Switch-Context }
        "4" { Bootstrap-Project }
        "5" { Setup-SSH }
        "6" { Exit }
    }
    Pause
}