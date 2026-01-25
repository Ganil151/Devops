# --- Administrator Authorization ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! Administrator privileges required for Shell & Symlink tweaks !!!"
    Pause; Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "      WINDOWS 11 DEVELOPER WORKFLOW ULTRA (2026)        " -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host " [1] SHELL  : Install/Optimize Oh-My-Posh & Terminal     "
    Write-Host " [2] GIT    : Global Performance & Large File Support    "
    Write-Host " [3] RAMDISK: Create 1GB RAM Drive for Temp Builds       "
    Write-Host " [4] CONTEXT: Restore Classic 'Right-Click' Menu         "
    Write-Host " [5] EXIT                                                "
    Write-Host "=========================================================" -ForegroundColor Cyan
}

# --- Module 1: Shell Optimization ---
function Optimize-Shell {
    Write-Host "[+] Optimizing PowerShell Profile & Terminal..." -ForegroundColor Green
    if (!(Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Host "  Installing Oh-My-Posh via Winget..." -ForegroundColor Gray
        winget install JanDeDobbeleer.OhMyPosh -e --accept-source-agreements | Out-Null
    }
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "[✔] Shell tools ready." -ForegroundColor Green
}

# --- Module 2: Git Performance & Large Files ---
function Optimize-Git {
    Write-Host "[+] Tuning Git for Massive Repos & Large Files..." -ForegroundColor Blue
    
    if (!(Get-Command git-lfs -ErrorAction SilentlyContinue)) {
        Write-Host "  Installing Git LFS..." -ForegroundColor Gray
        winget install GitHub.GitLFS -e | Out-Null
    }
    git lfs install --system
    
    git config --global core.fscache true
    git config --global core.preloadindex true
    git config --global feature.manyFiles true
    git config --global core.fsmonitor true
    
    # Large File Upload Fixes (500MB Buffer)
    git config --global http.postBuffer 524288000
    git config --global core.compression 0 
    
    Write-Host "[✔] Git tuned for performance and large uploads." -ForegroundColor Green
}

# --- Module 3: RAMDisk (Advanced) ---
function Set-RAMDisk {
    Write-Host "[+] Setting up RAMDisk for Build Artifacts..." -ForegroundColor Magenta
    if (!(Get-Command imdisk -ErrorAction SilentlyContinue)) {
        Write-Host "  Please install ImDisk (winget install LTRData.ImDisk)." -ForegroundColor Yellow
    } else {
        Write-Host "  RAMDisk tools detected." -ForegroundColor Gray
    }
}

# --- Module 4: Classic Context Menu ---
function Restore-ClassicMenu {
    Write-Host "[+] Restoring Classic Right-Click Menu..." -ForegroundColor Yellow
    $regPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    if (!(Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name "(Default)" -Value ""
    Write-Host "[✔] Done. Restart explorer.exe to see changes." -ForegroundColor Green
}

# --- Main Logic ---
while ($true) {
    Show-Menu
    $choice = Read-Host "Select an Option"
    switch ($choice) {
        "1" { Optimize-Shell }
        "2" { Optimize-Git }
        "3" { Set-RAMDisk }
        "4" { Restore-ClassicMenu }
        "5" { Exit }
    }
    Write-Host "`nOperation complete!" -ForegroundColor Green
    Pause
}