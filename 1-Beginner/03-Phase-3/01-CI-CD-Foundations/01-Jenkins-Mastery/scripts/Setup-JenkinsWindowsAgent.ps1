<#
.SYNOPSIS
    Automates the configuration of a Windows node as a Jenkins Agent.

.DESCRIPTION
    This script prepares a Windows machine to serve as a Jenkins build agent.
    It handles:
    - Validation of Java installation (required for Jenkins Remoting).
    - Creation of the Jenkins workspace directory.
    - Configuration of Windows Firewall rules to allow inbound traffic (if using JNLP/SSH).
    - Service configuration placeholders (winsw) advice.
    
    This script is idempotent; it checks state before applying changes.

.PARAMETER WorkspacePath
    The path where Jenkins will store build data. Default is 'C:\Jenkins\Workspace'.

.PARAMETER JavaHome
    Optional path to valid Java installation if not in PATH.

.EXAMPLE
    .\Setup-JenkinsWindowsAgent.ps1 -WorkspacePath "D:\Builds" -RemoteUrl "http://jenkins-master:8080"

.TAGS
    #Jenkins #WindowsOps #AgentAutomation #CI
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$false)]
    [string]$WorkspacePath = "C:\Jenkins\Workspace",

    [Parameter(Mandatory=$false)]
    [string]$JavaVersionRequirement = "11"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logObject = [PSCustomObject]@{
        Timestamp = $timestamp
        Level     = $Level
        Message   = $Message
    }
    Write-Output $logObject
}

try {
    Write-Log -Message "Starting Jenkins Windows Agent Setup..."
    
    # 1. Check for Java
    Write-Log -Message "Checking for Java installation..."
    try {
        $javaVer = java -version 2>&1
        if ($javaVer) {
            Write-Log -Message "Java found."
        } else {
            throw "Java executable not found in PATH."
        }
    } catch {
        Write-Warning "Java is required for Jenkins Agent. Please install OpenJDK $JavaVersionRequirement."
        # In a real scenario, we might trigger an install here via winget
        # winget install Microsoft.OpenJDK.17
        Write-Log -Message "Java check failed." -Level "ERROR"
    }

    # 2. Create Workspace
    if (-not (Test-Path -Path $WorkspacePath)) {
        if ($PSCmdlet.ShouldProcess($WorkspacePath, "Create Directory")) {
            New-Item -Path $WorkspacePath -ItemType Directory -Force | Out-Null
            Write-Log -Message "Created workspace at $WorkspacePath"
        }
    } else {
        Write-Log -Message "Workspace already exists at $WorkspacePath"
    }

    # 3. Configure Firewall (Idempotent)
    $ruleName = "Jenkins-Agent-Inbound"
    $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    
    if (-not $existingRule) {
        if ($PSCmdlet.ShouldProcess($ruleName, "Create Firewall Rule")) {
            New-NetFirewallRule -DisplayName $ruleName `
                -Direction Inbound `
                -Action Allow `
                -Protocol TCP `
                -LocalPort 50000 `
                -Description "Allow Jenkins JNLP traffic" | Out-Null
            Write-Log -Message "Created Firewall rule: $ruleName"
        }
    } else {
        Write-Log -Message "Firewall rule '$ruleName' already exists."
    }

    # 4. Permissions (Basic Check)
    # Ensure current user has write access to workspace
    try {
        $testFile = Join-Path -Path $WorkspacePath -ChildPath "write_test.tmp"
        "test" | Out-File -FilePath $testFile
        Remove-Item -Path $testFile
        Write-Log -Message "Write permission verified on $WorkspacePath"
    } catch {
        Write-Log -Message "Warning: Write permission check failed on $WorkspacePath" -Level "WARNING"
    }

    Write-Log -Message "Jenkins Agent Setup Complete. Ready to connect to Controller."

} catch {
    Write-Log -Message "Script failed: $_" -Level "FATAL"
    exit 1
}
