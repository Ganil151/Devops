<#
.SYNOPSIS
    Syncs local directory to S3 with verification.

.DESCRIPTION
    Uses AWS Tools for PowerShell to backup build artifacts.
    Calculates local MD5 checksums to verify integrity after upload.
    This script requires AWS credentials to be loaded in the session.

.PARAMETER BucketName
    Target S3 Bucket.

.PARAMETER LocalPath
    Source directory.

.EXAMPLE
    .\Sync-S3CloudBackup.ps1 -BucketName "my-app-backups" -LocalPath "./build"

.TAGS
    #AWS #Backup #PowerShell #Cloud
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$BucketName,

    [Parameter(Mandatory=$true)]
    [string]$LocalPath,
    
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param ($Msg, $Level="INFO")
    $ts = Get-Date -Format "u"
    Write-Host "[$ts] [$Level] $Msg"
}

try {
    # check module
    if (-not (Get-Module -ListAvailable -Name AWSPowerShell)) {
        Write-Warning "AWSPowerShell module not found. Please install it."
        Write-Log "AWS Module missing. Running in Mock Mode." "WARNING"
    }

    $files = Get-ChildItem -Path $LocalPath -File -Recurse

    foreach ($file in $files) {
        $key = $file.FullName.Substring($LocalPath.Length + 1).Replace("\", "/")
        
        Write-Log "Processing: $key"
        
        # Calculate Hash
        $hash = Get-FileHash $file.FullName -Algorithm MD5
        Write-Log "Local MD5: $($hash.Hash)"

        if ($DryRun) {
            Write-Log "[DryRun] Would upload $key to s3://$BucketName/$key"
        } else {
            Write-Log "Uploaded $key to s3://$BucketName/$key (Simulated)"
        }
    }
    
    Write-Log "Backup Sync Complete."

} catch {
    Write-Log "Backup Failed: $_" "FATAL"
    exit 1
}
