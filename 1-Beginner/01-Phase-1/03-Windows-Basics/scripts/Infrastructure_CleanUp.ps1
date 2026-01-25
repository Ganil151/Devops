# --- Administrator Authorization ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "!!! Advanced Cleanup requires Admin privileges !!!"
    Pause; Exit
}

function Show-DevOpsMenu {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Blue
    Write-Host "      ADVANCED DEVOPS INFRASTRUCTURE CLEANUP         " -ForegroundColor White
    Write-Host "=====================================================" -ForegroundColor Blue
    Write-Host " [1] DOCKER: Deep BuildKit & Volume Purge            "
    Write-Host " [2] K8S: Clear Minikube/Kind Cache & Logs           "
    Write-Host " [3] LANGUAGES: Clear NPM, Go, and Cargo Caches      "
    Write-Host " [4] TERRAFORM: Clean .terraform folders (Recursive) "
    Write-Host " [5] HELM: Clear Local Repo & Chart Cache            "
    Write-Host " [6] ALL-IN-ONE: Run All Infrastructure Tasks        "
    Write-Host " [7] EXIT                                            "
    Write-Host "=====================================================" -ForegroundColor Blue
}

# --- Actions ---

function Clean-DockerDeep {
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Write-Host "[+] Deep Purging Docker BuildKit & Builder Cache..." -ForegroundColor Gray
        # builder prune -a removes the build cache which can grow into tens of gigabytes
        docker builder prune -a -f
        docker volume prune -f
        Write-Host "[✔] Docker BuildKit storage reclaimed." -ForegroundColor Green
    }
}

function Clean-K8s {
    Write-Host "[+] Cleaning Local Kubernetes Caches..." -ForegroundColor Gray
    # Targets Minikube and Kind temporary data and logs
    $K8sPaths = @("$HOME\.minikube\cache", "$HOME\.minikube\logs")
    foreach ($path in $K8sPaths) {
        if (Test-Path $path) { Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Write-Host "[✔] K8s local logs and cache cleared." -ForegroundColor Green
}

function Clean-LanguageCaches {
    Write-Host "[+] Cleaning Package Manager Caches (NPM/Go/Cargo)..." -ForegroundColor Gray
    if (Get-Command npm -ErrorAction SilentlyContinue) { npm cache clean --force }
    if (Get-Command go -ErrorAction SilentlyContinue) { go clean -modcache }
    if (Get-Command cargo -ErrorAction SilentlyContinue) { cargo clean }
    Write-Host "[✔] Language-specific build caches purged." -ForegroundColor Green
}

function Clean-Terraform {
    $RootPath = Read-Host "Enter Root directory to scan for .terraform folders (e.g., C:\Projects)"
    if (Test-Path $RootPath) {
        Write-Host "[+] Recursively deleting .terraform directories in $RootPath..." -ForegroundColor Yellow
        Get-ChildItem -Path $RootPath -Include ".terraform", ".terragrunt-cache" -Recurse -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
        Write-Host "[✔] Terraform provider caches cleared." -ForegroundColor Green
    } else {
        Write-Warning "Invalid Path."
    }
}

function Clean-Helm {
    if (Get-Command helm -ErrorAction SilentlyContinue) {
        Write-Host "[+] Clearing Helm Chart Repository Cache..." -ForegroundColor Gray
        # Helm cache is stored in LocalAppData
        $HelmCache = "$env:LOCALAPPDATA\helm"
        if (Test-Path $HelmCache) { Remove-Item "$HelmCache\*" -Recurse -Force }
        Write-Host "[✔] Helm cache cleared." -ForegroundColor Green
    }
}

# --- Main Logic ---
while ($true) {
    Show-DevOpsMenu
    $choice = Read-Host "Select an Option"

    switch ($choice) {
        "1" { Clean-DockerDeep }
        "2" { Clean-K8s }
        "3" { Clean-LanguageCaches }
        "4" { Clean-Terraform }
        "5" { Clean-Helm }
        "6" { 
            Clean-DockerDeep; Clean-K8s; Clean-LanguageCaches; Clean-Helm 
            Write-Host "Note: Recursive Terraform clean skipped in All-In-One to avoid path errors." -ForegroundColor Cyan
        }
        "7" { Exit }
        Default { Write-Host "Invalid Selection." -ForegroundColor Red; Continue }
    }
    Pause
}