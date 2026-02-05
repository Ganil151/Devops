# PowerShell Script to Organize Root Directory Artifacts
# Moves maintenance scripts and audit reports to appropriate subdirectories

$Root = "C:\Users\Ganil\Documents\Devops"
$ScriptDest = "$Root\00-Resources\01-Scripts-Code\Maintenance"
$DocDest = "$Root\00-Resources\06-Docs\Migration-Audit"

# Ensure destinations exist
if (-not (Test-Path -Path $ScriptDest)) {
    New-Item -ItemType Directory -Force -Path $ScriptDest | Out-Null
    Write-Host "Created directory: $ScriptDest" -ForegroundColor Cyan
}
if (-not (Test-Path -Path $DocDest)) {
    New-Item -ItemType Directory -Force -Path $DocDest | Out-Null
    Write-Host "Created directory: $DocDest" -ForegroundColor Cyan
}

# Define file lists
$Scripts = @(
    "00_preflight_check.sh",
    "01_create_backup.sh",
    "02_create_migration_plan.py",
    "audit_directory.py",
    "final_readme_fix.py",
    "link_fixer.py",
    "link_scanner.py",
    "reorganize_phase2.py",
    "reorganize_windows_basics.py",
    "verify_phase2.py"
)

$Docs = @(
    "audit_report.json",
    "audit_report.md",
    "broken_links_report.json",
    "MICROSERVICES_ACTION_PLAN.md",
    "MICROSERVICES_AUDIT_REPORT.md",
    "MICROSERVICES_CONSISTENCY_MATRIX.md",
    "MIGRATION_MANIFEST.json",
    "MIGRATION_MANIFEST.md",
    "NEXT_STEPS.md",
    "REORGANIZATION_EXECUTIVE_SUMMARY.md",
    "REORGANIZATION_PLAN.md",
    "unfixable_links.json"
)

# Function to move files
function Move-Files ($FileList, $Destination) {
    foreach ($File in $FileList) {
        $SourcePath = "$Root\$File"
        if (Test-Path $SourcePath) {
            Move-Item -Path $SourcePath -Destination $Destination -Force
            Write-Host "Moved $File -> $Destination" -ForegroundColor Green
        } else {
            Write-Warning "File not found (skipped): $File"
        }
    }
}

# Execute Moves
Write-Host "--- Moving Scripts ---" -ForegroundColor Yellow
Move-Files -FileList $Scripts -Destination $ScriptDest

Write-Host "`n--- Moving Documentation & Reports ---" -ForegroundColor Yellow
Move-Files -FileList $Docs -Destination $DocDest

Write-Host "`nOrganization Complete." -ForegroundColor Cyan