**Preparing the Script:**  
Before executing the PowerShell script, there are several pieces of information that you need to prepare and input into the script to customize it for your environment:

**Network Variables:**  
$ethipaddress: Static IP address of the server.  
$ethprefixlength: Subnet mask prefix length (in CIDR format, e.g., 24 for 255.255.255.0).  
$ethdefaultgw: Default gateway.  
$ethdns: DNS servers (you can add multiple DNS addresses separated by commas).  
$globalsubnet: Global subnet used for DNS reverse lookup and Active Directory Sites and Services.  
$subnetlocation: Location of the subnet for Active Directory Sites and Services.  
$sitename: New name for Default-First-Site in Active Directory Sites and Services.

**Active Directory Variables:**  
$domainname: Name of your Active Directory domain.

**Remote Desktop Variable:**  
$enablerdp: Option to enable or disable Remote Desktop (yes or no).

**Disable IE Enhanced Security Configuration Variable:**  
$disableiesecconfig: Option to enable or disable Internet Explorer Enhanced Security Configuration (yes or no).

**Hostname Variables:**  
$computername: New server name.

**NTP Variables:**  
$ntpserver1: First NTP server for time synchronization.  
$ntpserver2: Second NTP server for time synchronization.

**DNS Variables:**  
$reversezone: DNS reverse lookup zone.

**Execution and Customization:**  
Review each variable carefully and input accurate values that align with your network configuration and preferences. Customize the script as needed, adjusting parameters to meet your specific requirements.

```powershell
```
#--------------------------------------------------------------------------------------------------------
#- Created by:             Emir Kurtovic                                                                -
#- Version:                2.1                                                                          -
#--------------------------------------------------------------------------------------------------------
#Change Log                                                                                            -
#18th August 2024          Added FQDN prompt for source domain controller when joining existing domain -
#--------------------------------------------------------------------------------------------------------

#-------------
#- Variables -
#-------------

#Network Variables
$ethipaddress = '10.10.100.251' # static IP Address of the server
$ethprefixlength = '24' # subnet mask - 24 = 255.255.255.0
$ethdns = '8.8.8.8','1.1.1.1' # for multiple DNS you can append DNS entries with commas
$ethdefaultgw = '10.10.100.1' # default gateway
$globalsubnet = '10.10.100.0/24' # Global Subnet will be used in DNS Reverse Record and AD Sites and Services Subnet
$subnetlocation = 'Sarajevo'
$sitename = 'Main-Site' # Renames Default-First-Site within AD Sites and Services

#Active Directory Variables
$domainname = 'elab.local' # enter your active directory domain name
$domainNetbiosName = 'ELAB' # NetBIOS name for the domain, typically a short version of the domain name

#Remote Desktop Variable
$enablerdp = 'yes' # to enable RDP, set this variable to yes. to disable RDP, set this variable to no

#Disable IE Enhanced Security Configuration Variable
$disableiesecconfig = 'yes' # to disable IE Enhanced Security Configuration, set this variable to yes. to leave enabled, set this variable to no

#Hostname Variables
$computername = 'srv-dc02' # enter your server name

#NTP Variables
$ntpserver1 = '0.ba.pool.ntp.org'
$ntpserver2 = '1.ba.pool.ntp.org'

#DNS Variables
$reversezone = '100.10.10.in-addr.arpa'

#Timestamp
Function Timestamp {
    $Global:timestamp = Get-Date -Format "dd-MM-yyy_hh:mm:ss"
}

#Log File Location
$logfile = "C:\psscript\Win_2022_AD_Deployment_logs.txt"

#Create Log File
Write-Host "-= Get timestamp =-" -ForegroundColor Green

Timestamp

IF (Test-Path $logfile) {
    Write-Host "-= Logfile Exists =-" -ForegroundColor Yellow
}
ELSE {
    Write-Host "-= Creating Logfile =-" -ForegroundColor Green
    Try {
        New-Item -Path 'C:\psscript' -ItemType Directory
        New-Item -ItemType File -Path $logfile -ErrorAction Stop | Out-Null
        Write-Host "-= The file $($logfile) has been created =-" -ForegroundColor Green
    }
    Catch {
        Write-Warning -Message $("Could not create logfile. Error: " + $_.Exception.Message)
        Break
    }
}

#Define the Disable-IEESC function
function Disable-IEESC {
    # Disable IE ESC for Administrators
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A5AB5C05-5B50-421F-95D7-1F08E602371E}' -Name "IsInstalled" -Value 0 -ErrorAction SilentlyContinue

    # Disable IE ESC for Users
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A5AB5C05-5B50-421F-95D7-1F08E602371F}' -Name "IsInstalled" -Value 0 -ErrorAction SilentlyContinue

    Write-Host "-= IE Enhanced Security Configuration successfully disabled for Admin and User =-" -ForegroundColor Green
}

#Check Script Progress via Logfile
$firstcheck = Select-String -Path $logfile -Pattern "1-Basic-Server-Config-Complete"

IF (!$firstcheck) {
    Write-Host "-= 1-Basic-Server-Config-Complete, does not exist =-" -ForegroundColor Yellow
    Timestamp
    Add-Content $logfile "$($Timestamp) - Starting Active Directory Script"

    ## 1-Basic-Server-Config ##
    #------------
    #- Settings -
    #------------

    # Set Network
    Timestamp
    Try {
        New-NetIPAddress -IPAddress $ethipaddress -PrefixLength $ethprefixlength -DefaultGateway $ethdefaultgw -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ErrorAction Stop | Out-Null
        Set-DNSClientServerAddress -ServerAddresses $ethdns -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ErrorAction Stop
        Write-Host "-= IP Address successfully set to $($ethipaddress), subnet $($ethprefixlength), default gateway $($ethdefaultgw) and DNS Server $($ethdns) =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - IP Address successfully set to $($ethipaddress), subnet $($ethprefixlength), default gateway $($ethdefaultgw) and DNS Server $($ethdns)"
    }
    Catch {
        Write-Warning -Message $("Failed to apply network settings. Error: " + $_.Exception.Message)
        Break
    }

    # Set RDP
    Timestamp
    Try {
        IF ($enablerdp -eq "yes") {
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0 -ErrorAction Stop
            Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop
            Write-Host "-= RDP Successfully enabled =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - RDP Successfully enabled"
        }
    }
    Catch {
        Write-Warning -Message $("Failed to enable RDP. Error: " + $_.Exception.Message)
        Break
    }

    IF ($enablerdp -ne "yes") {
        Write-Host "-= RDP remains disabled =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - RDP remains disabled"
    }

    # Disable IE Enhanced Security Configuration
    Timestamp
    Try {
        IF ($disableiesecconfig -eq "yes") {
            Disable-IEESC
            Add-Content $logfile "$($Timestamp) - IE Enhanced Security Configuration successfully disabled for Admin and User"
        }
    }
    Catch {
        Write-Warning -Message $("Failed to disable IE Security Configuration. Error: " + $_.Exception.Message)
        Break
    }

    If ($disableiesecconfig -ne "yes") {
        Write-Host "-= IE Enhanced Security Configuration remains enabled =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - IE Enhanced Security Configuration remains enabled"
    }

    # Set Hostname
    Timestamp
    Try {
        Rename-Computer -ComputerName $env:computername -NewName $computername -ErrorAction Stop | Out-Null
        Write-Host "-= Computer name set to $($computername) =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - Computer name set to $($computername)"
    }
    Catch {
        Write-Warning -Message $("Failed to set new computer name. Error: " + $_.Exception.Message)
        Break
    }

    # Enable cryptography algorithms compatible with Windows NT 4.0
    Timestamp
    Try {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy' -Name 'EnableNT4Cryptography' -Value 1 -ErrorAction Stop
        Write-Host "-= Enabled NT4-compatible cryptography algorithms =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - Enabled NT4-compatible cryptography algorithms"
    }
    Catch {
        Write-Warning -Message $("Failed to enable NT4-compatible cryptography algorithms. Error: " + $_.Exception.Message)
        Break
    }

    # Add first script complete to logfile
    Timestamp
    Add-Content $logfile "$($Timestamp) - 1-Basic-Server-Config-Complete, starting script 2 =-"

    # Enable FIPS-compliant algorithms
    Timestamp
    Try {
        Write-Host "-= Enabling FIPS-compliant algorithms =-" -ForegroundColor Yellow
        $fipsPolicyValue = "Enabled"
        $fipsPolicyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy"
        Set-ItemProperty -Path $fipsPolicyPath -Name "Enabled" -Value $fipsPolicyValue -ErrorAction Stop
        Write-Host "-= FIPS-compliant algorithms enabled successfully =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - FIPS-compliant algorithms enabled successfully"
    }
    Catch {
        Write-Warning -Message $("Failed to enable FIPS-compliant algorithms. Error: " + $_.Exception.Message)
        Break
    }

    # Reboot Computer to apply settings
    Timestamp
    Write-Host "-= Save all your work, computer rebooting in 30 seconds =-" -ForegroundColor White -BackgroundColor Red
    Sleep 30

    Try {
        Restart-Computer -ComputerName $env:computername -ErrorAction Stop
        Write-Host "-= Rebooting Now!! =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - Rebooting Now!!"
        Break
    }
    Catch {
        Write-Warning -Message $("Failed to restart computer $($env:computername). Error: " + $_.Exception.Message)
        Break
    }

} # Close 'IF (!$firstcheck)'

#Check Script Progress via Logfile
$secondcheck1 = Get-Content $logfile | Where-Object { $_.Contains("1-Basic-Server-Config-Complete") }

IF ($secondcheck1) {
    $secondcheck2 = Get-Content $logfile | Where-Object { $_.Contains("2-Build-Active-Directory-Complete") }

    IF (!$secondcheck2) {

        ## 2-Build-Active-Directory ##

        # Domain Operation Variable
        $domainAction = Read-Host "Enter 'new' to create a new domain or 'join' to add this server to an existing domain"

        # Prompt for the DSRM password
        $dsrmpassword = Read-Host "Enter Directory Services Restore Password" -AsSecureString

        # If joining an existing domain, prompt for the IP address of the primary AD and credentials
        $primaryADIP = $null
        $sourceDomainControllerFQDN = $null
        $domainCreds = $null
        IF ($domainAction -eq "join") {
            $primaryADIP = Read-Host "Enter the IP address of the primary AD domain controller"
            $sourceDomainControllerFQDN = Read-Host "Enter the fully qualified DNS name (FQDN) of the source domain controller"

            # Set DNS to point to the primary AD controller
            Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses $primaryADIP

            # Test connectivity to the primary AD
            IF (-not (Test-Connection -ComputerName $primaryADIP -Count 2 -Quiet)) {
                Write-Host "Unable to reach the primary AD domain controller at $primaryADIP" -ForegroundColor Red
                Break
            }

            # Prompt for domain admin credentials
            $domainCreds = Get-Credential -Message "Enter the credentials for a domain account with permissions to add a domain controller"
        }

        Timestamp
        Try {
            Write-Host "-= Active Directory Domain Services installing =-" -ForegroundColor Yellow
            Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
            Write-Host "-= Active Directory Domain Services installed successfully =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Active Directory Domain Services installed successfully"
        }
        Catch {
            Write-Warning -Message $("Failed to install Active Directory Domain Services. Error: " + $_.Exception.Message)
            Break
        }

        # Configure Active Directory Domain Services
        Timestamp
        Try {
            IF ($domainAction -eq "new") {
                Write-Host "-= Creating new domain =-" -ForegroundColor Yellow
                Install-ADDSForest -DomainName $domainname -DomainNetbiosName $domainNetbiosName -InstallDNS -SafeModeAdministratorPassword $dsrmpassword -Confirm:$false | Out-Null
                Write-Host "-= New domain created successfully =-" -ForegroundColor Green
                Add-Content $logfile "$($Timestamp) - New domain created successfully"
            }
            ELSEIF ($domainAction -eq "join") {
                Write-Host "-= Joining existing domain =-" -ForegroundColor Yellow
                Install-ADDSDomainController -DomainName $domainname -InstallDNS -SafeModeAdministratorPassword $dsrmpassword -Credential $domainCreds -Confirm:$false -ReplicationSourceDC $sourceDomainControllerFQDN | Out-Null
                Write-Host "-= Server added to existing domain successfully =-" -ForegroundColor Green
                Add-Content $logfile "$($Timestamp) - Server added to existing domain successfully"
            }
            ELSE {
                Write-Host "-= Invalid option selected. Exiting... =-" -ForegroundColor Red
                Break
            }
        }
        Catch {
            Write-Warning -Message $("Failed to configure Active Directory Domain Services. Error: " + $_.Exception.Message)
            Break
        }

        # Add second script complete to logfile
        Timestamp
        Add-Content $logfile "$($Timestamp) - 2-Build-Active-Directory-Complete, starting script 3 =-"

        # Reboot Computer to apply settings
        Write-Host "-= Save all your work, computer rebooting in 30 seconds =-" -ForegroundColor White -BackgroundColor Red
        Sleep 30

        Try {
            Restart-Computer -ComputerName $env:computername -ErrorAction Stop
            Write-Host "Rebooting Now!!" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Rebooting Now!!"
        }
        Catch {
            Write-Warning -Message $("Failed to restart computer $($env:computername). Error: " + $_.Exception.Message)
            Break
        }

    } # Close 'IF (!$secondcheck2)'
} # Close 'IF ($secondcheck1)'

#Add second script complete to logfile

#Check Script Progress via Logfile
$thirdcheck = Get-Content $logfile | Where-Object { $_.Contains("2-Build-Active-Directory-Complete") }

## 3-Build-Active-Directory ##

#------------
#- Settings -
#------------

#Add DNS Reverse Record
Timestamp
Try {
    Add-DnsServerPrimaryZone -NetworkId $globalsubnet -DynamicUpdate Secure -ReplicationScope Domain -ErrorAction Stop
    Write-Host "-= Successfully added in $($globalsubnet) as a reverse lookup within DNS =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully added $($globalsubnet) as a reverse lookup within DNS"
}
Catch {
    Write-Warning -Message $("Failed to create reverse DNS lookups zone for network $($globalsubnet). Error: "+ $_.Exception.Message)
    Break
}

#Add DNS Scavenging
Write-Host "-= Set DNS Scavenging =-" -ForegroundColor Yellow

Timestamp
Try {
    Set-DnsServerScavenging -ScavengingState $true -ScavengingInterval 7.00:00:00 -Verbose -ErrorAction Stop
    Set-DnsServerZoneAging $domainname -Aging $true -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00 -Verbose -ErrorAction Stop
    Set-DnsServerZoneAging $reversezone -Aging $true -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00 -Verbose -ErrorAction Stop
    Add-Content $logfile "$($Timestamp) - DNS Scavenging Complete"
}
Catch {
    Write-Warning -Message $("Failed to DNS Scavenging. Error: "+ $_.Exception.Message)
    Break
}

Get-DnsServerScavenging

Write-Host "-= DNS Scavenging Complete =-" -ForegroundColor Green

#Create Active Directory Sites and Services
Timestamp
Try {
    New-ADReplicationSubnet -Name $globalsubnet -Site "Default-First-Site-Name" -Location $subnetlocation -ErrorAction Stop
    Write-Host "-= Successfully added Subnet $($globalsubnet) with location $($subnetlocation) in AD Sites and Services =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully added Subnet $($globalsubnet) with location $($subnetlocation) in AD Sites and Services"
}
Catch {
    Write-Warning -Message $("Failed to create Subnet $($globalsubnet) in AD Sites and Services. Error: "+ $_.Exception.Message)
    Break
}

#Rename Active Directory Site
Timestamp
Try {
    Get-ADReplicationSite Default-First-Site-Name | Rename-ADObject -NewName $sitename -ErrorAction Stop
    Write-Host "-= Successfully renamed Default-First-Site-Name to $sitename in AD Sites and Services =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully renamed Default-First-Site-Name to $sitename in AD Sites and Services"
}
Catch {
    Write-Warning -Message $("Failed to rename site in AD Sites and Services. Error: "+ $_.Exception.Message)
    Break
}

#Add NTP settings to PDC

Timestamp

$serverpdc = Get-AdDomainController -Filter * | Where-Object {$_.OperationMasterRoles -contains "PDCEmulator"}

If ($serverpdc) {
    Try {
        Start-Process -FilePath "C:\Windows\System32\w32tm.exe" -ArgumentList "/config /manualpeerlist:$($ntpserver1),$($ntpserver2) /syncfromflags:MANUAL /reliable:yes /update" -ErrorAction Stop
        Stop-Service w32time -ErrorAction Stop
        sleep 2
        Start-Service w32time -ErrorAction Stop
        Write-Host "-= Successfully set NTP Servers: $($ntpserver1) and $($ntpserver2) =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - Successfully set NTP Servers: $($ntpserver1) and $($ntpserver2)"
    }
    Catch {
        Write-Warning -Message $("Failed to set NTP Servers. Error: "+ $_.Exception.Message)
    }
}
```
```