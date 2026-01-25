# --- Administrative Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges!"
    Pause; Exit
}

Clear-Host
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   PROCESSOR SETTINGS VISIBILITY MANAGER      " -ForegroundColor White
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " 1 = UNHIDE (Show all hidden CPU settings)    "
Write-Host " 2 = HIDE   (Simplify the CPU menu)           "
Write-Host "==============================================" -ForegroundColor Cyan

$choice = Read-Host "Select an option (1-2)"

# The GUID for the entire Processor Subgroup
$SubProcessor = "SUB_PROCESSOR"

# List of the most useful specific hidden GUIDs to toggle
$TargetGUIDs = @(
    "be337238-0d82-4146-a960-4f3749d470c7", # Boost Mode
    "0cc5b647-c1df-4637-891a-dec35c318583", # Core Parking Min Cores
    "ea062307-7e22-4425-99d9-1da5f462a2bb", # Core Parking Max Cores
    "bc5038f7-23e0-4960-96da-33abaf5935ec", # Max Processor State
    "8934337c-58d4-4971-97f3-d6b9118c208f"  # Min Processor State
)

if ($choice -eq "1") {
    Write-Host "Unlocking hidden settings..." -ForegroundColor Green
    # Unlock the main group
    powercfg -attributes $SubProcessor -ATTRIB_HIDE
    # Unlock specific key features
    foreach ($guid in $TargetGUIDs) {
        powercfg -attributes $SubProcessor $guid -ATTRIB_HIDE
    }
} elseif ($choice -eq "2") {
    Write-Host "Hiding advanced settings..." -ForegroundColor Yellow
    # Hide the main group
    powercfg -attributes $SubProcessor +ATTRIB_HIDE
    # Hide specific key features
    foreach ($guid in $TargetGUIDs) {
        powercfg -attributes $SubProcessor $guid +ATTRIB_HIDE
    }
} else {
    Write-Error "Invalid selection."
    Pause; Exit
}

Write-Host "`nOperation complete. Open 'Advanced Power Settings' to see changes." -ForegroundColor Cyan
Pause