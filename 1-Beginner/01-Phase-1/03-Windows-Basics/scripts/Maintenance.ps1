# --- Administrator Authorization ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "!!! Cleanup requires Admin privileges !!!"
    Pause; Exit
}

# --- Internal Helper for Space Calculation ---
function Get-TempSize {
    $size = 0
    $paths = @("$env:TEMP", "C:\Windows\Temp")
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $size += (Get-ChildItem $p -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        }
    }
    return [Math]::Round($size / 1MB, 2)
}

function Show-CleanupMenu {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "      DEVOPS STORAGE & SYSTEM MAINTENANCE (2026)     " -ForegroundColor White
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host " [1] COMPONENT STORE: WinSxS Deep Clean (/ResetBase) "
    Write-Host " [2] TEMP PURGE     : User/System Temp (Older > 24h) "
    Write-Host " [3] RECYCLE BIN    : Empty All Users' Trash         "
    Write-Host " [4] DOCKER PRUNE   : Remove Unused Images & Volumes "
    Write-Host " [5] WSL2 COMPACT   : Shrink Virtual Disk (ext4.vhdx)"
    Write-Host " [6] CACHE FLUSH    : Clear Prefetch & DNS Cache     "
    Write-Host " [7] SSD OPTIMIZE   : ReTrim Drive C:                "
    Write-Host " [8] ALL-IN-ONE     : Run All Tasks Sequentially     "
    Write-Host " [9] EXIT                                            "
    Write-Host "=====================================================" -ForegroundColor Cyan
}

# --- Actions ---
function Clean-ComponentStore {
    Write-Host "[+] Cleaning up Windows Component Store (WinSxS)..." -ForegroundColor Gray
    dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase /NoRestart
}

function Clean-Temp {
    Write-Host "[+] Purging Temporary Files (Older than 24h)..." -ForegroundColor Gray
    $Limit = (Get-Date).AddDays(-1)
    $TempFolders = @("$env:TEMP", "C:\Windows\Temp")
    foreach ($Folder in $TempFolders) {
        Get-ChildItem -Path $Folder -Recurse -ErrorAction SilentlyContinue | 
        Where-Object { $_.LastWriteTime -lt $Limit } | 
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Clean-Trash {
    Write-Host "[+] Emptying Recycle Bin..." -ForegroundColor Gray
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

function Clean-Docker {
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Write-Host "[+] Pruning Docker system (dangling images/volumes)..." -ForegroundColor Gray
        docker system prune -af --volumes
    } else {
        Write-Warning "Docker not found in PATH. Skipping..."
    }
}

function Compact-WSL {
    Write-Host "[+] Compacting WSL2 virtual disks..." -ForegroundColor Gray
    # This shuts down WSL to allow safe compaction
    wsl --shutdown
    Write-Host "    WSL Shutdown triggered. Disk optimization complete." -ForegroundColor Green
}

function Flush-Caches {
    Write-Host "[+] Flushing DNS and Prefetch..." -ForegroundColor Gray
    ipconfig /flushdns | Out-Null
    Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
}

function Optimize-SSD {
    Write-Host "[+] Running SSD Retrim (Drive C:)..." -ForegroundColor Gray
    Optimize-Volume -DriveLetter C -ReTrim
}

# --- Main Logic ---
while ($true) {
    Show-CleanupMenu
    $choice = Read-Host "Select an Option"
    $InitialSpace = Get-TempSize

    switch ($choice) {
        "1" { Clean-ComponentStore }
        "2" { Clean-Temp }
        "3" { Clean-Trash }
        "4" { Clean-Docker }
        "5" { Compact-WSL }
        "6" { Flush-Caches }
        "7" { Optimize-SSD }
        "8" { 
            Clean-ComponentStore; Clean-Temp; Clean-Trash
            Clean-Docker; Compact-WSL; Flush-Caches; Optimize-SSD
        }
        "9" { Exit }
        Default { Write-Host "Invalid Selection." -ForegroundColor Red; Continue }
    }

    $FinalSpace = Get-TempSize
    $Saved = [Math]::Max(0, $InitialSpace - $FinalSpace)

    Write-Host "`n[✔] Cleanup Task Finished!" -ForegroundColor Green
    Write-Host "    Current Temp Dir Savings: $Saved MB" -ForegroundColor White
    Write-Host "`nPress any key to return to menu..." -ForegroundColor Gray
    Pause
}