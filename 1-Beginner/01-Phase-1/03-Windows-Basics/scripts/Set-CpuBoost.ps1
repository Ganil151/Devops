# --- Administrative Check ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    Pause
    Exit
}

# --- Initialization ---
$BoostGuid = "be337238-0d82-4146-a960-4f3749d470c7"
$SubProcessor = "SUB_PROCESSOR"

# Ensure the setting is visible in the UI
powercfg -attributes $SubProcessor $BoostGuid -ATTRIB_HIDE

# Clear screen and show menu
Clear-Host
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "    PROCESSOR PERFORMANCE BOOST MANAGER       " -ForegroundColor White
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " 0 = Disabled (Best for temps/battery)        "
Write-Host " 1 = Enabled (Windows default)                "
Write-Host " 2 = Aggressive (Max speed for compiling)     "
Write-Host " 3 = Efficient Enabled                        "
Write-Host " 4 = Efficient Aggressive                     "
Write-Host "==============================================" -ForegroundColor Cyan

$choice = Read-Host "Select a mode (0-4)"

# Validate input
if ($choice -notmatch "^[0-4]$") {
    Write-Error "Invalid selection. Please run the script again."
    Pause
    Exit
}

# Get Active Power Scheme
$activeScheme = (powercfg -getactivescheme).Split(' ')[3]

# Apply the settings
Write-Host "`nApplying changes to active scheme: $activeScheme..." -ForegroundColor Yellow

# Set AC (Plugged in) and DC (Battery)
powercfg -setacvalueindex $activeScheme $SubProcessor $BoostGuid $choice
powercfg -setdcvalueindex $activeScheme $SubProcessor $BoostGuid $choice

# Commit changes
powercfg -setactive $activeScheme

Write-Host "Success! Mode set to $choice." -ForegroundColor Green
Write-Host "Note: You can verify this in Advanced Power Options > Processor Power Management." -ForegroundColor Gray
Pause