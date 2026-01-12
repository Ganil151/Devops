## <font color="#00b050">   Access Control List</font>
### Get-ACL 
The `Get-ACL` cmdlet in PowerShell retrieves the access control list (ACL) for a file, folder, or other resource. The ACL contains information about the permissions assigned to users and groups for that resource.
#### Key Points
- `Get-ACL` shows who can read, write, or modify a file or folder.
- Useful for auditing and managing permissions.
- Can be combined with other cmdlets to modify permissions.
**Viewing File Permissions**
```powershell
# Get the ACL (permissions) for a specific file
Get-ACL -Path "C:\Users\ganil\Documents\example.txt"

# Get the ACL for a folder
Get-ACL -Path "C:\Users\ganil\Documents"
```
This will display the permissions for the specified file or folder, showing which users and groups have access and what type of access they have.

---
### Set-ACL
The `Set-ACL` cmdlet in PowerShell is used to apply changes to the access control list (ACL) of a file, folder, or other resource. It allows you to modify permissions by setting a new ACL object on the specified resource.
#### Key Points
- `Set-ACL` updates permissions for files or folders.
- You typically use `Get-ACL` to retrieve the current ACL, modify it, and then use `Set-ACL` to apply the changes.
- Useful for automating permission changes in scripts Granting a User **Modify Permission**
```powershell
# Get the current ACL for the file
$acl = Get-ACL -Path "C:\Users\ganil\Documents\example.txt"

# Create a new FileSystemAccessRule
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Username","Modify","Allow")

# Add the new rule to the ACL
$acl.AddAccessRule($rule)

# Apply the updated ACL to the file
Set-ACL -Path "C:\Users\ganil\Documents\example.txt" -AclObject $acl
```

----
## <font color="#00b050">Active Directory</font>

### Active Directory Cmdlets
PowerShell provides a set of cmdlets for managing Active Directory (AD) environments. These cmdlets are available when you install the **Active Directory module** for Windows PowerShell.
#### Key Points
- You must have the Active Directory module installed (`Import-Module ActiveDirectory`).
- Useful for managing users, groups, computers, and other AD objects.
- Commonly used in enterprise environments for automation and administration.
 **Importing the Active Directory Module**
```powershell
# Import the Active Directory module
Import-Module ActiveDirectory
```
 **Finding a User in Active Directory**
```powershell
# Find a user by username
Get-ADUser -Identity "username"
```
**Listing All Users in an Organizational Unit (OU)**
```powershell
# List all users in a specific OU
Get-ADUser -Filter * -SearchBase "OU=Sales,DC=example,DC=com"
```
**Creating a New User**
```powershell
# Create a new AD user
New-ADUser -Name "John Doe" -SamAccountName "jdoe" -AccountPassword (Read-Host -AsSecureString "Enter Password") -Enabled $true
```
> **Note:** You need appropriate permissions to run these commands and may need to run PowerShell as an administrator.

___
### Backup-GPO
The `Backup-GPO` cmdlet in PowerShell creates a backup of one or more **Group Policy Objects** (GPOs) in Active Directory. This is useful for safeguarding GPO configurations, enabling easy restoration or migration.
#### Key Points
- Backs up specified GPOs or all GPOs in a domain.
- Stores backups in a specified file system location.
- Useful for disaster recovery, auditing, or migrating GPOs between environments.
- Requires the Group Policy module (part of RSAT).
**Backing Up a Specific GPO**
```powershell
# Backup a specific GPO by name to a folder
Backup-GPO -Name "Default Domain Policy" -Path "C:\GPO-Backups"
```
**Backing Up All GPOs**
```powershell
# Backup all GPOs in the domain to a folder
Backup-GPO -All -Path "C:\GPO-Backups"
```
This cmdlet helps administrators protect and manage Group Policy configurations efficiently.

___
## <font color="#00b050">Alias</font>
### Get-Alias
The `Get-Alias` cmdlet in PowerShell displays the aliases defined in the current session. An alias is an alternate name or shortcut for a cmdlet or command, making it quicker to type common commands.
#### Key Points
- Shows all aliases or a specific alias if you provide a name.
- Useful for discovering shortcuts for common cmdlets.
- You can create your own aliases using `Set-Alias`.
**Viewing Aliase**
```powershell
# List all aliases in the current session
Get-Alias

# Find the alias for the Get-ChildItem cmdlet
Get-Alias -Definition Get-ChildItem

# Find what command 'ls' is an alias for
Get-Alias ls
```
___
### Export-Alias
The `Export-Alias` cmdlet in PowerShell exports the currently defined aliases to a file. This is useful for saving your custom aliases or sharing them with others.
#### Key Points
- Exports all or selected aliases to a file.
- The exported file can be imported later using `Import-Alias`.
- Commonly used for backup or migration of alias settings.
**Exporting Aliases to a File**
```powershell
# Export all aliases to a file named aliases.txt
Export-Alias -Path "C:\Users\ganil\Documents\aliases.txt"
```
**Exporting a Specific Alias**
```powershell
# Export only the 'ls' alias to a file
Export-Alias -Name ls -Path "C:\Users\ganil\Documents\ls-alias.txt"
```
This allows you to save your alias definitions and restore them when needed.
___
### Import-Alias
The `Import-Alias` cmdlet in PowerShell imports alias definitions from a file into the current session. This is useful for restoring previously saved aliases or sharing alias configurations between systems.
#### Key Points
- Imports aliases from a file created by `Export-Alias`.
- Useful for restoring custom or shared alias setups.
- Can overwrite existing aliases if names conflict.
 **Importing Aliases from a File**
```powershell
# Import aliases from a file named aliases.txt
Import-Alias -Path "C:\Users\ganil\Documents\aliases.txt"
```
This command loads the aliases from the specified file into your current PowerShell session.
___
### New-Alias
The `New-Alias` cmdlet in PowerShell creates a new alias for a cmdlet or command. This allows you to define shortcuts for frequently used commands, making them quicker to type.
#### Key Points
- Creates a new alias in the current session.
- Useful for customizing your PowerShell environment.
- Aliases created with `New-Alias` are temporary and last only for the session unless added to your profile.
**Creating a New Alias**
```powershell
# Create a new alias 'nal' for the New-Alias cmdlet
New-Alias -Name nal -Value New-Alias

# Example: Create an alias 'll' for Get-ChildItem
New-Alias -Name ll -Value Get-ChildItem
```
This lets you use `nal` instead of `New-Alias` or `ll` instead of `Get-ChildItem` in your session.
___
### Set-Alias
The `Set-Alias` cmdlet in PowerShell defines a new alias or updates an existing alias for a cmdlet or command. An alias is a shortcut or alternative name that you can use in place of a longer command. `Set-Alias` is especially useful for customizing your PowerShell environment, making frequently used commands quicker and easier to type.
#### Key Points
- Creates a new alias or updates an existing one.
- Helps personalize and streamline your PowerShell workflow.
- Aliases set with `Set-Alias` are temporary and last only for the current session unless added to your PowerShell profile script.
- You can use aliases in scripts to make code more concise, but be cautious as it may reduce readability for others.
**Creating or Changing an Alias**
```powershell
# Create a new alias 'sal' for the Set-Alias cmdlet
Set-Alias -Name sal -Value Set-Alias

# Example: Change or create an alias 'rm' for Remove-Item
Set-Alias -Name rm -Value Remove-Item
```
This allows you to use `sal` instead of `Set-Alias` or `rm` instead of `Remove-Item` in your session.

**Automation Script Example: Setting Multiple Aliases at Once**
```powershell
# Define a list of aliases and their corresponding commands
$aliases = @{
    ll = 'Get-ChildItem'
    cat = 'Get-Content'
    cp = 'Copy-Item'
    mv = 'Move-Item'
    rm = 'Remove-Item'
}

# Loop through the list and set each alias
foreach ($alias in $aliases.Keys) {
    Set-Alias -Name $alias -Value $aliases[$alias]
}
```
This script sets up several common aliases automatically, making your PowerShell session more efficient.
- **Persisting Aliases Across Sessions**
To make your aliases available in every PowerShell session, add your `Set-Alias` commands to your PowerShell profile script:
```powershell
# Open your profile script in Notepad
notepad $PROFILE

# Add your Set-Alias commands to the file and save it
```
This ensures your custom aliases are loaded every time you start PowerShell.
___
<center><font color="#00b050">APPxPACKAGE</font></center>
### Get-AppvClientPackage
The `Get-AppvClientPackage` cmdlet in PowerShell retrieves information about Microsoft Application Virtualization (App-V) client packages that are currently published to the user or computer. This is useful for administrators managing virtualized applications on Windows systems.
#### Key Points
- Returns a list of App-V packages available on the client.
- Useful for auditing, troubleshooting, or managing App-V deployments.
- Can be filtered to show specific packages or details.
**Viewing All App-V Client Packages**
```powershell
# List all App-V client packages on the system
Get-AppvClientPackage
```
**Viewing Details for a Specific Package**
```powershell
# Get details for a specific App-V package by name
Get-AppvClientPackage -Name "PackageName"
```
This helps administrators monitor and manage virtual applications on client machines.
___
### Get-AppxPackage
The `Get-AppxPackage` cmdlet in PowerShell lists the app packages (Windows Store apps) installed in a user profile. This is useful for viewing, auditing, or troubleshooting app installations on Windows 10/11 systems.
#### Key Points
- Lists all installed app packages for the current user by default.
- Can be used to query app packages for other users or filter by name.
- Useful for managing and troubleshooting Windows Store apps.
**Viewing All Installed App Packages**
```powershell
# List all app packages installed for the current user
Get-AppxPackage
```
**Filtering by App Name**
```powershell
# List all app packages with 'Microsoft' in the name
Get-AppxPackage -Name "*Microsoft*"
```

**Viewing App Packages for a Specific User**
```powershell
# List app packages for a specific user (requires admin rights)
Get-AppxPackage -User "username"
```
This cmdlet helps administrators and users manage and review app installations on Windows devices.
___
### Remove-AppxPackage
The `Remove-AppxPackage` cmdlet in PowerShell removes an app package (Windows Store app) from a user account. This is useful for uninstalling unwanted or problematic apps from Windows 10/11 systems.
#### Key Points
- Uninstalls a specified app package for the current user by default.
- Can be used to remove apps for other users (requires admin rights).
- Useful for cleaning up or managing app installations.
**Removing an App Package by Name**
```powershell
# Remove a specific app package by its full package name
Remove-AppxPackage -Package "PackageFullName"
```
**Finding and Removing an App**
```powershell
# Find the package full name for an app (e.g., Microsoft Solitaire Collection)
Get-AppxPackage -Name "*Solitaire*" | Select-Object Name, PackageFullName

# Remove the app using its package full name
Remove-AppxPackage -Package "Microsoft.MicrosoftSolitaireCollection_4.12.12070.0_x64__8wekyb3d8bbwe"
```
This cmdlet helps administrators and users uninstall unwanted Windows Store apps from user profiles.
___
### Add-AppxProvisionedPackage

The `Add-AppxProvisionedPackage` cmdlet in PowerShell adds an app package (.appx or .appxbundle) to a Windows image. This ensures the app is automatically installed for every new user who logs on to the system. It is commonly used in deployment scenarios to preinstall apps on all user profiles.
#### Key Points
- Adds an app package to a Windows image (online or offline).
- The app will be installed for each new user who signs in.
- Useful for enterprise deployments and custom Windows images.
- Requires administrator privileges.

**Adding an Appx Package to an Online Windows Image**
```powershell
# Add an appx package to the currently running Windows installation
Add-AppxProvisionedPackage -Online -PackagePath "C:\Path\To\App.appx" -LicensePath "C:\Path\To\License.xml"
```
**Adding an Appx Package to an Offline Windows Image**
```powershell
# Add an appx package to an offline Windows image (mounted at D:\Mount)
Add-AppxProvisionedPackage -Path "D:\Mount" -PackagePath "C:\Path\To\App.appx" -LicensePath "C:\Path\To\License.xml"
```
This cmdlet is essential for administrators who want to ensure specific apps are available to all users on a Windows device.
___
### Get-AppxProvisionedPackage
The `Get-AppxProvisionedPackage` cmdlet in PowerShell retrieves information about appx packages that have been provisioned in a Windows image using DISM (Deployment Image Servicing and Management). These are the apps that will be installed automatically for every new user who logs on to the system.
#### Key Points
- Lists all provisioned appx packages in an online or offline Windows image.
- Useful for auditing, managing, or troubleshooting preinstalled apps in enterprise deployments.
- Can be used with both online (current system) and offline (mounted image) scenarios.

**Viewing Provisioned Appx Packages in the Current System**
```powershell
# List all provisioned appx packages in the currently running Windows installation
Get-AppxProvisionedPackage -Online
```
**Viewing Provisioned Appx Packages in an Offline Image**
```powershell
# List all provisioned appx packages in an offline Windows image (mounted at D:\Mount)
Get-AppxProvisionedPackage -Path "D:\Mount"
```
This cmdlet helps administrators manage and review which apps are provisioned to be installed for all users on a Windows device.
___
### Remove-AppxProvisionedPackage
The `Remove-AppxProvisionedPackage` cmdlet in PowerShell removes a provisioned appx package from a Windows image. This prevents the app from being automatically installed for new users who log on to the system. It is useful for customizing or cleaning up Windows images in deployment scenarios.
#### Key Points
- Removes a provisioned appx package from an online or offline Windows image.
- The app will no longer be installed for new users.
- Useful for managing and customizing enterprise or deployment images.
- Requires administrator privileges.

**Removing a Provisioned Appx Package from the Current System**
```powershell
# Remove a provisioned appx package by its package name from the currently running Windows installation
Remove-AppxProvisionedPackage -Online -PackageName "PackageName"
```
**Removing a Provisioned Appx Package from an Offline Image**
```powershell
# Remove a provisioned appx package from an offline Windows image (mounted at D:\Mount)
Remove-AppxProvisionedPackage -Path "D:\Mount" -PackageName "PackageName"
```
This cmdlet helps administrators ensure only the desired apps are provisioned for all users on a Windows device.
___
## <font color="#00b050">Archive</font>
### Compress-Archive
The `Compress-Archive` cmdlet in PowerShell creates a new archive (ZIP) file from specified files and folders. This is useful for packaging files for backup, sharing, or deployment. Available in PowerShell 5.0 and later.
#### Key Points
- Creates .zip files from files and folders.
- Can add to an existing archive or create a new one.
- Useful for backups, deployments, and sharing files.

**Creating a New Archive**
```powershell
# Compress a folder into a new ZIP file
Compress-Archive -Path "C:\Users\ganil\Documents\MyFolder" -DestinationPath "C:\Users\ganil\Documents\MyFolder.zip"
```
**Adding Files to an Existing Archive**
```powershell
# Add files to an existing ZIP archive
Compress-Archive -Path "C:\Users\ganil\Documents\file.txt" -Update -DestinationPath "C:\Users\ganil\Documents\MyFolder.zip"
```

___
### Expand-Archive
The `Expand-Archive` cmdlet in PowerShell extracts files from an archive (ZIP) file. This is useful for unpacking compressed files for use or inspection. Available in PowerShell 5.0 and later.
#### Key Points
- Extracts files and folders from .zip archives.
- Can extract to a specified folder.
- Useful for restoring backups or accessing shared files.

**Extracting an Archive**
```powershell
# Extract all files from a ZIP archive to a folder
Expand-Archive -Path "C:\Users\ganil\Documents\MyFolder.zip" -DestinationPath "C:\Users\ganil\Documents\ExtractedFolder"
```
**Overwriting Existing Files**
```powershell
# Extract and overwrite existing files in the destination
Expand-Archive -Path "C:\Users\ganil\Documents\MyFolder.zip" -DestinationPath "C:\Users\ganil\Documents\ExtractedFolder" -Force
```
___
## <font color="#00b050">AuthentiCodeSignature</font>
### Get-AuthenticodeSignature
The `Get-AuthenticodeSignature` cmdlet in PowerShell retrieves the digital signature information for a file, such as a script or executable. This is useful for verifying the authenticity and integrity of files, especially scripts and applications.
#### Key Points
- Returns the signature object for a specified file.
- Useful for checking if a file is signed and if the signature is valid.
- Helps ensure scripts and executables have not been tampered with.
**Viewing the Signature of a File**
```powershell
# Get the digital signature information for a script file
Get-AuthenticodeSignature -FilePath "C:\Users\ganil\Documents\myscript.ps1"
```
This command displays details about the signature, including its status (Valid, NotSigned, etc.).

___
### Set-AuthenticodeSignature
The `Set-AuthenticodeSignature` cmdlet in PowerShell applies a digital signature to a file, such as a PowerShell script (.ps1). This is used to sign scripts with a code-signing certificate, helping to establish trust and integrity.
#### Key Points
- Signs a file using a code-signing certificate.
- Used to comply with security policies requiring signed scripts.
- Requires a valid code-signing certificate installed on the system.
**Signing a Script File**
```powershell
# Get a code-signing certificate from the certificate store
$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Select-Object -First 1

# Sign the script file with the certificate
Set-AuthenticodeSignature -FilePath "C:\Users\ganil\Documents\myscript.ps1" -Certificate $cert
```
This ensures the script is signed and can be verified by others before execution.

___
## <font color="#00b050">Automation</font>
### Begin
The `Begin` block in PowerShell advanced functions is used to define code that runs once before any input is processed. It is typically used for initialization tasks, such as setting up variables, opening connections, or preparing resources needed for the main processing.
#### Key Points
- Runs once before the `Process` block.
- Ideal for initialization and setup.
- Used only in advanced functions or scripts with pipeline input.
**Example: Using a Begin Block in a Function**
```powershell
function Get-SampleData {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string]$InputObject
    )
    begin {
        Write-Host "Starting processing..."
        $results = @()
    }
    process {
        $results += $InputObject.ToUpper()
    }
    end {
        $results
    }
}
```
In this example, the `begin` block initializes an array before processing input data.
___
## <font color="#00b050">BITS (Background Intelligent Transfer Service)</font>
### BITS Cmdlets
PowerShell provides a set of cmdlets for managing Background Intelligent Transfer Service (BITS) jobs. BITS is used to transfer files asynchronously in the background, making it ideal for downloading or uploading large files without impacting network performance.
#### Key Points
- BITS transfers files in the background and can resume interrupted transfers.
- Useful for downloading updates, large files, or automating file transfers.
- Common BITS cmdlets include `Start-BitsTransfer`, `Get-BitsTransfer`, `Suspend-BitsTransfer`, `Resume-BitsTransfer`, and `Remove-BitsTransfer`.
**Starting a BITS Transfer**
```powershell
# Download a file from a URL to a local path
Start-BitsTransfer -Source "https://example.com/file.zip" -Destination "C:\Users\ganil\Downloads\file.zip"
```
**Listing Active BITS Jobs**
```powershell
# List all current BITS transfer jobs
Get-BitsTransfer
```
**Suspending and Resuming a BITS Job**
```powershell
# Suspend a BITS job by its ID
Suspend-BitsTransfer -BitsJob (Get-BitsTransfer -AllUsers | Select-Object -First 1)

# Resume a suspended BITS job
Resume-BitsTransfer -BitsJob (Get-BitsTransfer -AllUsers | Where-Object { $_.JobState -eq 'Suspended' } | Select-Object -First 1)
```
**Removing a BITS Job**
```powershell
# Remove a BITS job by its ID
Remove-BitsTransfer -BitsJob (Get-BitsTransfer -AllUsers | Select-Object -First 1)
```
BITS cmdlets are powerful tools for automating reliable file transfers in scripts and enterprise environments.
___
## <font color="#00b050">BitLocker</font>
PowerShell provides several cmdlets for managing BitLocker Drive Encryption, allowing you to enable, configure, and monitor encryption on Windows volumes.
### Enable-BitLocker
Enables BitLocker encryption on a specified volume.
#### Key Points
- Encrypts a drive to protect data.
- Can specify key protectors (password, TPM, recovery key, etc.).
- Requires administrator privileges.
**Example: Enable BitLocker on Drive C:**
```powershell
Enable-BitLocker -MountPoint "C:" -PasswordProtector
```
---
### Enable-BitLockerAutoUnlock
Enables automatic unlocking for a BitLocker-protected volume.
#### Key Points
- Useful for data drives that should unlock automatically when the OS drive is unlocked.
- Requires BitLocker to be enabled on the volume.
**Example: Enable Auto Unlock for D:**
```powershell
Enable-BitLockerAutoUnlock -MountPoint "D:"
```
---
### Disable-BitLocker
Disables BitLocker encryption and begins decrypting the specified volume.
#### Key Points
- Decrypts the drive and removes BitLocker protection.
- Requires administrator privileges.
**Example: Disable BitLocker on C:**
```powershell
Disable-BitLocker -MountPoint "C:"
```
---
### Resume-BitLocker
Resumes BitLocker encryption on a suspended volume.
#### Key Points
- Restarts encryption if it was previously suspended.
**Example: Resume BitLocker on C:**
```powershell
Resume-BitLocker -MountPoint "C:"
```
---
### Suspend-BitLocker
Temporarily suspends BitLocker protection on a volume.
#### Key Points
- Useful for system maintenance or firmware updates.
- Encryption remains, but protection is paused.
**Example: Suspend BitLocker on C:**
```powershell
Suspend-BitLocker -MountPoint "C:"
```
---
### Add-BitLockerKeyProtector
Adds a key protector (such as a password or recovery key) to a BitLocker-protected volume.
#### Key Points
- Multiple key protectors can be added for flexibility.
**Example: Add a Password Protector to D:**
```powershell
Add-BitLockerKeyProtector -MountPoint "D:" -PasswordProtector
```
---
### Remove-BitLockerKeyProtector
Removes a specified key protector from a BitLocker-protected volume.
#### Key Points
- At least one key protector must remain.
**Example: Remove a Key Protector by ID:**
```powershell
Remove-BitLockerKeyProtector -MountPoint "D:" -KeyProtectorId "{ProtectorID}"
```
---
### Get-BitLockerVolume
Retrieves information about volumes that BitLocker can protect.
#### Key Points
- Shows encryption status, key protectors, and more.
**Example: Get BitLocker Status for All Volumes**
```powershell
Get-BitLockerVolume
```
___
## <font color="#00b050">Data Conversion</font>

### ConvertFrom-CSV
The `ConvertFrom-CSV` cmdlet converts object properties in CSV format into PowerShell objects. It is useful for importing and working with CSV data.
#### Key Points
- Converts CSV-formatted strings into objects.
- Each row becomes an object with properties matching the CSV headers.
**Example: Convert CSV String to Objects**
```powershell
"Name,Age`nAlice,30`nBob,25" | ConvertFrom-CSV
```
---
### ConvertTo-CSV
The `ConvertTo-CSV` cmdlet converts PowerShell objects into CSV variable-length strings. This is useful for exporting data to CSV files.
#### Key Points
- Converts objects to CSV-formatted strings.
- Can be used with `Out-File` to save to disk.
**Example: Convert Objects to CSV**
```powershell
Get-Process | Select-Object Name, Id | ConvertTo-CSV
```
---
### ConvertFrom-Json
The `ConvertFrom-Json` cmdlet converts a JSON-formatted string to a custom PowerShell object.
#### Key Points
- Parses JSON strings into objects for easy manipulation.
- Useful for working with web APIs and configuration files.
**Example: Convert JSON String to Object**
```powershell
'{"Name":"Alice","Age":30}' | ConvertFrom-Json
```
---
### ConvertTo-Json
The `ConvertTo-Json` cmdlet converts a PowerShell object to a JSON-formatted string.
#### Key Points
- Serializes objects to JSON for storage or transmission.
- Useful for APIs, configuration, and data exchange.
**Example: Convert Object to JSON**
```powershell
Get-Process | Select-Object Name, Id | ConvertTo-Json
```
---
### ConvertTo-Html
The `ConvertTo-Html` cmdlet converts input objects into an HTML table, making it easy to generate web reports.
#### Key Points
- Converts objects to HTML for reporting and visualization.
- Can specify table properties and add custom headers/footers.
**Example: Convert Data to HTML Table**
```powershell
Get-Process | Select-Object Name, Id | ConvertTo-Html -Property Name, Id
```
---
### ConvertTo-Xml
The `ConvertTo-Xml` cmdlet converts input objects into XML format.
#### Key Points
- Serializes objects to XML for storage or interoperability.
- Useful for configuration, data exchange, and automation.
**Example: Convert Data to XML**
```powershell
Get-Process | Select-Object Name, Id | ConvertTo-Xml
```
---
### ConvertFrom-String (Alias: cfs)
The `ConvertFrom-String` cmdlet extracts and parses structured properties from a string, using a template or delimiter.
#### Key Points
- Parses unstructured text into structured objects.
- Useful for log parsing and text analysis.
**Example: Parse a Structured String**
```powershell
"Name: Alice, Age: 30" | ConvertFrom-String -PropertyNames Name, Age
```

---
### ConvertFrom-StringData
The `ConvertFrom-StringData` cmdlet converts a string containing key and value pairs into a hash table.
#### Key Points
- Converts multi-line key-value strings to hash tables.
- Useful for configuration and localization data.
**Example: Convert Key-Value String to Hash Table**
```powershell
@"
Key1=Value1
Key2=Value2
"@ | ConvertFrom-StringData
```

---
### ConvertFrom-SecureString
The `ConvertFrom-SecureString` cmdlet converts a secure string into an encrypted standard string.
#### Key Points
- Used for exporting or storing secure strings.
- Can specify a key or secure key for encryption.
**Example: Convert Secure String to Encrypted String**
```powershell
$secure = Read-Host -AsSecureString
$secure | ConvertFrom-SecureString
```

---
### ConvertTo-SecureString
The `ConvertTo-SecureString` cmdlet converts an encrypted standard string into a secure string.
#### Key Points
- Used for importing or reconstructing secure strings.
- Supports plain text or encrypted input.
**Example: Convert Encrypted String to Secure String**
```powershell
$encrypted = '01000000d08c9ddf0115d1118c7a00c04fc297eb01000000...'
$secure = $encrypted | ConvertTo-SecureString
```
___
## <font color="#00b050">Date & Time Management</font>

### Get-Date
The `Get-Date` cmdlet in PowerShell retrieves the current date and time of the system. It is widely used in scripting for logging, timestamping, scheduling, and automation tasks.
#### Key Points
- Returns the current date and time.
- Can format output for custom date/time strings.
- Useful for logging, file naming, and scheduling.
**Display the Current Date and Time**
```powershell
Get-Date
```
**Format the Date for a Log File Name**
```powershell
# Create a timestamped log file
$logFile = "C:\Logs\log_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss")
```
**Get Only the Current Year**
```powershell
(Get-Date).Year
```
---
### Set-Date
The `Set-Date` cmdlet sets the system date and time on the host computer. This is typically used by administrators for time synchronization or correction.
#### Key Points
- Changes the system date and/or time.
- Requires administrator privileges.
- Useful for correcting system clocks or synchronizing with external sources.
**Set the System Date and Time**
```powershell
Set-Date -Date "2025-06-10 14:30"
```
**Synchronize with an NTP Server**
```powershell
# Set the system time to match an NTP server (requires additional tools or scripts)
w32tm /resync
```
---
## <font color="#00b050">Certificate Management</font>

### Export-Certificate
The `Export-Certificate` cmdlet in PowerShell exports a certificate from a certificate store to a file. This is useful for backing up certificates or transferring them to other systems.
#### Key Points
- Exports certificates in .cer format.
- Can specify the certificate by its thumbprint or subject.
- Useful for backup, migration, or distribution.
**Example: Export a Certificate to a File**
```powershell
# Export a certificate by thumbprint to a .cer file
Export-Certificate -Cert Cert:\CurrentUser\My\<Thumbprint> -FilePath "C:\Users\ganil\Documents\exported.cer"
```

---
### Get-Certificate
The `Get-Certificate` cmdlet submits a certificate request to an enrollment server and installs the issued certificate. It can also retrieve existing certificates.
#### Key Points
- Used for certificate enrollment and retrieval.
- Can be used with Active Directory Certificate Services.
- Supports both online and offline requests.
**Example: Request and Install a Certificate**
```powershell
# Request a certificate from an enrollment server
Get-Certificate -Template "User" -CertStoreLocation "Cert:\CurrentUser\My"
```

---
### Import-Certificate
The `Import-Certificate` cmdlet imports one or more certificates into a certificate store. This is useful for installing trusted root certificates or personal certificates.
#### Key Points
- Imports certificates into specified certificate stores.
- Supports .cer, .crt, and .pfx files.
- Useful for trust establishment and secure communications.
**Example: Import a Certificate into the Trusted Root Store**
```powershell
# Import a certificate into the Trusted Root Certification Authorities store
Import-Certificate -FilePath "C:\Users\ganil\Documents\trustedroot.cer" -CertStoreLocation "Cert:\LocalMachine\Root"
```
___
## <font color="#00b050">Set-Location</font>
The `Set-Location` cmdlet in PowerShell changes the current working directory (location) to a specified path. It is similar to the `cd`, `chdir`, or `sl` commands in other shells and is used to navigate the file system or other PowerShell providers (like the registry).
#### Key Points
- Changes the current directory for the session.
- Supports file system paths, registry paths, and other providers.
- Aliases: `cd`, `chdir`, `sl`.
**Example: Change to a Specific Directory**
```powershell
# Change to the Documents folder
Set-Location -Path "C:\Users\ganil\Documents"

# Using the alias 'cd'
cd "C:\Users\ganil\Documents"
```
**Example: Change to the Root of the C: Drive**
```powershell
Set-Location -Path "C:\"
```
This cmdlet is essential for navigating and managing locations in PowerShell sessions.
___
## <font color="#00b050">Get-ChildItem</font>
The `Get-ChildItem` cmdlet in PowerShell retrieves the child items (such as files and folders) in a specified location, similar to the `dir`, `ls`, or `gci` commands in other shells. It can be used to list the contents of directories, registry keys, or other PowerShell providers.
#### Key Points
- Lists files and folders in a directory or items in other providers (e.g., registry).
- Supports filtering, recursion, and detailed output.
- Aliases: `dir`, `ls`, `gci`.
**Example: List All Files and Folders in a Directory**
```powershell
# List all items in the Documents folder
Get-ChildItem -Path "C:\Users\ganil\Documents"

# Using the alias 'ls'
ls "C:\Users\ganil\Documents"
```
**Example: List Only Files with a Specific Extension**
```powershell
# List all .txt files in the Documents folder
Get-ChildItem -Path "C:\Users\ganil\Documents" -Filter *.txt
```
**Example: Recursively List All Files in a Directory and Subdirectories**
```powershell
# List all files and folders recursively
Get-ChildItem -Path "C:\Users\ganil\Documents" -Recurse
```
**Example: List Registry Keys**
```powershell
# List all subkeys under HKCU:\Software
Get-ChildItem -Path "HKCU:\Software"
```
This cmdlet is essential for browsing and managing files, folders, and other hierarchical data in PowerShell.
___
## <font color="#00b050">Clear</font>

### Clear-Host
The `Clear-Host` cmdlet in PowerShell clears the contents of the console screen, similar to the `clear` or `cls` commands in other shells. This is useful for improving readability by removing previous output from view.
#### Key Points
- Clears all text from the PowerShell console window.
- Aliases: `clear`, `cls`.
**Example: Clear the Console Screen**
```powershell
Clear-Host

# Using the alias 'cls'
cls
```

---
### Clear-Item
The `Clear-Item` cmdlet in PowerShell removes the content from a variable, alias, or other item, but does not delete the item itself. This is useful for resetting the value of variables or clearing the target of an alias.
#### Key Points
- Removes content but keeps the item (variable, alias, etc.) in place.
- Alias: `cli`.
**Example: Clear the Value of a Variable**
```powershell
# Clear the contents of a variable
Clear-Item -Path Variable:MyVar
```
**Example: Clear the Target of an Alias**
```powershell
# Clear the target of an alias
Clear-Item -Path Alias:ll
```
___
## <font color="#00b050">CIM (Common Information Model)</font>
PowerShell provides a set of CIM cmdlets for managing and interacting with CIM (Common Information Model) resources, which are used to access management data such as storage, network, and software information on local or remote computers.
### Get-CimAssociatedInstance
Retrieves CIM instances that are associated with a specified CIM instance by an association.
#### Key Points
- Used to find related CIM objects (e.g., disks associated with a computer).
- Useful for exploring relationships between managed resources.
**Example: Get Associated Instances**
```powershell
# Get all logical disks associated with a specific computer system
$computer = Get-CimInstance -ClassName Win32_ComputerSystem
Get-CimAssociatedInstance -InputObject $computer
```
---
### Get-CimClass (Alias: gcls)
Gets a list of CIM classes in a specific namespace.
#### Key Points
- Lists available CIM classes for management tasks.
- Useful for discovering what can be managed via CIM.
**Example: List All CIM Classes**
```powershell
Get-CimClass -Namespace root\cimv2
```
---
### Register-CimIndicationEvent
Subscribes to CIM indications (events) using a filter or query expression.
#### Key Points
- Enables event-driven automation based on system changes.
- Useful for monitoring and responding to system events.
**Example: Subscribe to a CIM Event**
```powershell
Register-CimIndicationEvent -Query "SELECT * FROM __InstanceCreationEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_Process'" -Namespace root\cimv2 -SourceIdentifier "ProcessCreated"
```
---
### New-CimInstance (Alias: ncim)
Creates a new instance of a CIM class.
#### Key Points
- Used to create new managed resources (e.g., network shares).
- Requires specifying the class and property values.
**Example: Create a New CIM Instance**
```powershell
New-CimInstance -ClassName Win32_Process -Property @{ CommandLine = "notepad.exe" }
```
---
### Get-CimInstance (Alias: gcim)
Gets a managed resource (such as storage, network, or software) from a local or remote computer.
#### Key Points
- Retrieves CIM objects for management and inventory.
- Supports filtering and remote queries.
**Example: Get All Services**
```powershell
Get-CimInstance -ClassName Win32_Service
```
---
### Remove-CimInstance (Alias: rcim)
Removes a CIM instance from a computer.
#### Key Points
- Deletes the specified managed resource.
- Use with caution as it can remove system components.
**Example: Remove a Specific CIM Instance**
```powershell
$printer = Get-CimInstance -ClassName Win32_Printer -Filter "Name='TestPrinter'"
Remove-CimInstance -InputObject $printer
```
---
### Set-CimInstance (Alias: scim)
Modifies a CIM instance on a CIM server.
#### Key Points
- Updates properties of managed resources.
- Useful for configuration changes.
**Example: Change Service Start Mode**
```powershell
$service = Get-CimInstance -ClassName Win32_Service -Filter "Name='wuauserv'"
Set-CimInstance -InputObject $service -Property @{ StartMode = "Manual" }
```
---
### Invoke-CimMethod (Alias: icim)
Invokes a method of a CIM class or CIM instance.
#### Key Points
- Executes actions on managed resources (e.g., start/stop a service).
- Requires specifying the method name and parameters.
**Example: Start a Service**
```powershell
$service = Get-CimInstance -ClassName Win32_Service -Filter "Name='wuauserv'"
Invoke-CimMethod -InputObject $service -MethodName StartService
```
---
### Get-CimSession (Alias: gcms)
Gets current CIM session objects.
#### Key Points
- Lists active CIM sessions for remote management.
- Useful for managing multiple remote connections.
**Example: List All CIM Sessions**
```powershell
Get-CimSession
```
---
### New-CimSession (Alias: ncms)
Creates a new CIM session for remote management.
#### Key Points
- Establishes a persistent connection to a remote computer.
- Useful for running multiple CIM commands in a session.
**Example: Create a New CIM Session**
```powershell
New-CimSession -ComputerName "Server01"
```
---
### New-CimSessionOption
Specifies advanced options for creating a new CIM session.
#### Key Points
- Allows customization of session behavior (e.g., authentication, protocol).
- Used with `New-CimSession`.
**Example: Create a Session Option**
```powershell
$option = New-CimSessionOption -Protocol Dcom
New-CimSession -ComputerName "Server01" -SessionOption $option
```
---
### Remove-CimSession (Alias: rcms)
Removes one or more CIM session objects.
#### Key Points
- Closes and deletes CIM sessions.
- Helps manage and clean up remote connections.
**Example: Remove All CIM Sessions**
```powershell
Get-CimSession | Remove-CimSession
```
___
## <font color="#00b050">Clipboard</font>

### Get-Clipboard
The `Get-Clipboard` cmdlet in PowerShell retrieves the current contents of the Windows clipboard. This is useful for accessing text, images, or other data that has been copied to the clipboard.
#### Key Points
- Gets the current clipboard entry (text, image, etc.).
- Useful for automation, scripting, and data extraction.
- Can specify the format to retrieve (e.g., text, file list).
**Example: Get Text from the Clipboard**
```powershell
Get-Clipboard
```
**Example: Get Clipboard Content as a File List**
```powershell
Get-Clipboard -Format FileDropList
```
---
### Set-Clipboard
The `Set-Clipboard` cmdlet in PowerShell sets the contents of the Windows clipboard. This allows you to programmatically copy text or other data to the clipboard for use in other applications.
#### Key Points
- Sets the clipboard entry to specified text or data.
- Useful for automation and scripting tasks.
- Can set text, file paths, or other supported formats.
**Example: Set Text to the Clipboard**
```powershell
Set-Clipboard -Value "Hello, PowerShell clipboard!"
```
**Example: Copy the Contents of a File to the Clipboard**
```powershell
Get-Content "C:\Users\ganil\Documents\example.txt" | Set-Clipboard
```
___
## <font color="#00b050">Get-Command</font>
The `Get-Command` cmdlet in PowerShell retrieves basic information about cmdlets, functions, workflows, aliases, and applications available in your session. It is useful for discovering commands, checking command details, and exploring available modules.
#### Key Points
- Lists all available commands or filters by name, module, or type.
- Helps you discover new cmdlets and their syntax.
- Alias: `gcm`.
**Example: List All Commands**
```powershell
Get-Command
```
**Example: Find a Command by Name**
```powershell
Get-Command -Name Get-Process
```
**Example: List All Commands in a Module**
```powershell
Get-Command -Module Microsoft.PowerShell.Management
```
**Example: Find All Aliases**
```powershell
Get-Command -CommandType Alias
```
This cmdlet is essential for exploring and understanding the PowerShell environment.
___
## <font color="#00b050">Invoke-Command</font>
The `Invoke-Command` cmdlet in PowerShell runs commands on local or remote computers. It is commonly used for remote administration, automation, and running scripts or commands across multiple systems simultaneously.
#### Key Points
- Executes commands or scripts on one or more remote computers.
- Supports running code blocks (`ScriptBlock`) or script files.
- Can use existing sessions or create new ones.
- Alias: `icm`.
**Example: Run a Command on a Remote Computer**
```powershell
Invoke-Command -ComputerName "Server01" -ScriptBlock { Get-Process }
```
**Example: Run a Script File Remotely**
```powershell
Invoke-Command -ComputerName "Server01" -FilePath "C:\Scripts\MyScript.ps1"
```
**Example: Run a Command on Multiple Computers**
```powershell
Invoke-Command -ComputerName "Server01","Server02" -ScriptBlock { Get-Service }
```
**Example: Run a Command Locally**
```powershell
Invoke-Command -ScriptBlock { Get-Date }
```
This cmdlet is essential for automating tasks and managing multiple systems efficiently.
___
## <font color="#00b050">Show-Command</font>
The `Show-Command` cmdlet in PowerShell opens a graphical window that helps you build and run PowerShell commands. It provides a GUI for entering parameters, making it easier to construct complex commands without memorizing syntax.
#### Key Points
- Opens a graphical command window for any cmdlet or function.
- Useful for learning parameters and building commands interactively.
- Alias: `shcm`.
**Example: Open the GUI for Get-Process**
```powershell
Show-Command -Name Get-Process
```
---
## <font color="#00b050">Measure-Command</font>
The `Measure-Command` cmdlet measures how long it takes to run a script block or command. It is useful for performance testing and benchmarking scripts or cmdlets.
#### Key Points
- Returns the total execution time of the command.
- Useful for comparing performance of different approaches.
**Example: Measure the Time to List Files**
```powershell
Measure-Command { Get-ChildItem -Path "C:\Users\ganil\Documents" }
```
---
## <font color="#00b050">Trace-Command</font>
The `Trace-Command` cmdlet traces the execution of a command or expression, showing detailed information about how PowerShell processes it. This is useful for debugging and understanding command behavior.
#### Key Points
- Provides detailed tracing output for command execution.
- Useful for troubleshooting and learning how commands are processed.
**Example: Trace the Execution of Get-Process**
```powershell
Trace-Command -Name ParameterBinding -Expression { Get-Process } -PSHost
```
___
## <font color="#00b050">Computer Management</font>

### Add-Computer
The `Add-Computer` cmdlet adds the local computer to a domain or workgroup. It can also move the computer to a new domain or organizational unit (OU).
#### Key Points
- Joins a computer to a domain or workgroup.
- Can specify credentials and OU.
- Requires a restart to complete the operation.
**Example: Add Computer to a Domain**
```powershell
Add-Computer -DomainName "example.com" -Credential (Get-Credential) -Restart
```
---
### Checkpoint-Computer
The `Checkpoint-Computer` cmdlet creates a system restore point on the local computer. This allows you to revert the system to a previous state if needed.
#### Key Points
- Creates a restore point for system recovery.
- Useful before making major changes to the system.
- Only available on client editions of Windows.
**Example: Create a Restore Point**
```powershell
Checkpoint-Computer -Description "Before installing updates"
```
---
### Disable-ComputerRestore
The `Disable-ComputerRestore` cmdlet disables the System Restore feature on one or more specified drives. This prevents the system from creating new restore points on those drives.
#### Key Points
- Turns off System Restore for specified drives.
- No new restore points will be created for those drives.
- Useful for saving disk space or when restore points are not needed.
**Example: Disable System Restore on C:**
```powershell
Disable-ComputerRestore -Drive "C:\"
```
___
### Enable-ComputerRestore
The `Enable-ComputerRestore` cmdlet enables the System Restore feature on one or more specified drives. This allows the system to create restore points, which can be used to revert the system to a previous state if needed.
#### Key Points
- Turns on System Restore for specified drives.
- Required before creating restore points with `Checkpoint-Computer`.
- Useful for protecting against unwanted system changes.
**Example: Enable System Restore on C:**
```powershell
Enable-ComputerRestore -Drive "C:\"
```
---
### Remove-Computer
The `Remove-Computer` cmdlet removes the local computer from a domain or workgroup.
#### Key Points
- Unjoins the computer from a domain or workgroup.
- Can specify credentials.
- Requires a restart to complete the operation.
**Example: Remove Computer from Domain**
```powershell
Remove-Computer -UnjoinDomainCredential (Get-Credential) -Restart
```
---
### Rename-Computer
The `Rename-Computer` cmdlet renames the local or a remote computer.
#### Key Points
- Changes the computer name.
- Can specify credentials and restart automatically.
**Example: Rename the Local Computer**
```powershell
Rename-Computer -NewName "NewPCName" -Restart
```
---
### Restart-Computer
The `Restart-Computer` cmdlet restarts the operating system on the local or remote computer.
#### Key Points
- Restarts one or more computers.
- Can force applications to close and specify credentials.
**Example: Restart the Local Computer**
```powershell
Restart-Computer -Force
```
---
### Restore-Computer
The `Restore-Computer` cmdlet restores the computer to a previous state using a system restore point.
#### Key Points
- Rolls back the system to a specified restore point.
- Useful for undoing system changes.
**Example: Restore to a Specific Restore Point**
```powershell
Restore-Computer -RestorePoint 15
```
---
### Stop-Computer
The `Stop-Computer` cmdlet shuts down the local or remote computer.
#### Key Points
- Shuts down one or more computers.
- Can force shutdown and specify credentials.
**Example: Shut Down the Local Computer**
```powershell
Stop-Computer -Force
```
___
### Get-ComputerInfo
The `Get-ComputerInfo` cmdlet retrieves detailed information about the local computer, including hardware, operating system, BIOS, and network properties.
#### Key Points
- Provides comprehensive system and OS details.
- Useful for inventory, troubleshooting, and reporting.
**Example: Get All System Information**
```powershell
Get-ComputerInfo
```
---
### Reset-ComputerMachinePassword
The `Reset-ComputerMachinePassword` cmdlet resets the machine account password for the local computer in the domain. This is useful if the secure channel between the computer and the domain controller is broken.
#### Key Points
- Resets the computer's domain account password.
- Helps restore trust with the domain.
- Requires domain credentials.
**Example: Reset the Machine Account Password**
```powershell
Reset-ComputerMachinePassword -Credential (Get-Credential)
```
---
### Enable-ComputerRestore
The `Enable-ComputerRestore` cmdlet enables the System Restore feature on specified drives, allowing the creation of restore points.
#### Key Points
- Turns on System Restore for specified drives.
- Required before creating restore points with `Checkpoint-Computer`.
**Example: Enable System Restore on C:**
```powershell
Enable-ComputerRestore -Drive "C:\"
```
---
### Test-ComputerSecureChannel
The `Test-ComputerSecureChannel` cmdlet tests and repairs the secure channel between the local computer and its domain.
#### Key Points
- Checks if the computer's trust relationship with the domain is intact.
- Can attempt to repair the secure channel if broken.

**Example: Test the Secure Channel**
```powershell
Test-ComputerSecureChannel
```
**Example: Test and Repair the Secure Channel**
```powershell
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)
```
___
### <font color="#00b050">Disk Management</font>

### Clear-Disk
The `Clear-Disk` cmdlet removes all partition information and un-initializes a disk, effectively erasing all data on the disk. This is a powerful tool for preparing disks for reuse or secure disposal.
#### Key Points
- Erases all partition and formatting information from a disk.
- Leaves the disk in an uninitialized (RAW) state.
- Requires administrator privileges.
- Use with caution—**all data will be lost**.
**Clear a Disk by Number**
```powershell
Clear-Disk -Number 2 -RemoveData -Confirm:$false
```
**Clear All Offline Disks**
```powershell
Get-Disk | Where-Object OperationalStatus -eq 'Offline' | ForEach-Object {
    Clear-Disk -Number $_.Number -RemoveData -Confirm:$false
}
```
---
### Get-Disk
The `Get-Disk` cmdlet retrieves information about one or more physical disks visible to the operating system. It is essential for inventory, automation, and troubleshooting storage devices.
#### Key Points
- Lists all disks and their properties (number, size, status, etc.).
- Useful for identifying disks before performing operations.
- Can be filtered by status, size, or other properties.
**List All Disks**
```powershell
Get-Disk
```
**List Only RAW (Uninitialized) Disks**
```powershell
Get-Disk | Where-Object PartitionStyle -eq 'RAW'
```
---
### Set-Disk
The `Set-Disk` cmdlet sets attributes and updates properties of a physical disk, such as making it read-only or online/offline.

#### Key Points
- Can change disk attributes (e.g., read-only, offline/online).
- Useful for automation and enforcing storage policies.
**Set a Disk to Read-Only**
```powershell
Set-Disk -Number 2 -IsReadOnly $true
```
**Bring All Offline Disks Online**
```powershell
Get-Disk | Where-Object OperationalStatus -eq 'Offline' | Set-Disk -IsOffline $false
```
---
### Initialize-Disk
The `Initialize-Disk` cmdlet initializes a RAW (uninitialized) disk, preparing it for partitioning and formatting.
#### Key Points
- Required before creating partitions or formatting a new disk.
- Supports MBR and GPT partition styles.
- Typically used after `Clear-Disk`.
**Initialize a Disk with GPT**
```powershell
Initialize-Disk -Number 2 -PartitionStyle GPT
```
**Initialize All RAW Disks as MBR**
```powershell
Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle MBR
```
---
### Update-Disk
The `Update-Disk` cmdlet updates the cached disk information for the operating system, ensuring that PowerShell and the OS have the latest view of disk status and configuration.
#### Key Points
- Refreshes disk information after changes (e.g., after hot-swapping disks).
- Useful for troubleshooting and automation scripts.
**Update Disk Information**
```powershell
Update-Disk -Number 2
```
**Update All Disks**
```powershell
Get-Disk | ForEach-Object { Update-Disk -Number $_.Number }
```
---
### <font color="#00b050">Disk Image Management</font>

### Dismount-DiskImage
The `Dismount-DiskImage` cmdlet in PowerShell dismounts a disk image (such as a virtual hard disk (VHD/VHDX) or ISO file) that is currently mounted. This is essential for safely removing virtual media from the system.
#### Key Points
- Unmounts (detaches) a mounted disk image.
- Useful for automation, cleanup, and ensuring data integrity.
- Supports VHD, VHDX, and ISO formats.
**Dismount an ISO File**
```powershell
Dismount-DiskImage -ImagePath "C:\ISOs\Windows10.iso"
```
**Dismount All Mounted Disk Images**
```powershell
Get-DiskImage | Where-Object { $_.Attached } | Dismount-DiskImage
```
---
### Get-DiskImage
The `Get-DiskImage` cmdlet retrieves information about one or more disk image files (VHD, VHDX, ISO) on the system. This is useful for inventory, automation, and scripting scenarios involving virtual media.
#### Key Points
- Lists disk images and their properties (path, size, attached status, etc.).
- Can filter by file path or image type.
- Useful for managing virtual storage tasks.
**List All Disk Images**
```powershell
Get-DiskImage
```
**Get Only Mounted ISO Images**
```powershell
Get-DiskImage | Where-Object { $_.ImageType -eq 'ISO' -and $_.Attached }
```
---
### Mount-DiskImage
The `Mount-DiskImage` cmdlet mounts a disk image file (VHD, VHDX, ISO) so it appears as a drive on the system. This is commonly used for accessing installation media, backups, or virtual disks.
#### Key Points
- Mounts a disk image as a virtual drive.
- Supports VHD, VHDX, and ISO formats.
- Can be used interactively or in automation scripts.
**Mount an ISO File**
```powershell
Mount-DiskImage -ImagePath "C:\ISOs\Windows10.iso"
```
**Mount a VHD File and Assign a Drive Letter**
```powershell
Mount-DiskImage -ImagePath "D:\VirtualDisks\DataDisk.vhdx"
# Get the drive letter assigned to the mounted VHD
Get-DiskImage -ImagePath "D:\VirtualDisks\DataDisk.vhdx" | Get-Disk | Get-Partition | Get-Volume
```
___
## <font color="#00b050">Desired State Configuration (DSC)</font>
PowerShell Desired State Configuration (DSC) is a management platform in Windows PowerShell that enables you to manage your IT and development infrastructure with configuration as code. These cmdlets are essential for professionals automating configuration, compliance, and drift remediation.
### Get-DscConfiguration
Retrieves the current configuration applied to a node (computer) by DSC.
#### Key Points
- Shows the current state/configuration of the node.
- Useful for auditing and troubleshooting configuration drift.
- Can be run locally or remotely.
**Get Current DSC Configuration**
```powershell
Get-DscConfiguration
```
**Get DSC Configuration from a Remote Node**
```powershell
Invoke-Command -ComputerName "Server01" -ScriptBlock { Get-DscConfiguration }
```
---
### Get-DscLocalConfigurationManager
Retrieves the settings of the Local Configuration Manager (LCM) on a node.
#### Key Points
- LCM controls how DSC applies and manages configurations.
- Shows settings like refresh mode, configuration mode, and status.
**View LCM Settings**
```powershell
Get-DscLocalConfigurationManager
```
**View LCM Settings on Multiple Nodes**
```powershell
Invoke-Command -ComputerName "Server01","Server02" -ScriptBlock { Get-DscLocalConfigurationManager }
```
---
### Get-DscResource
Lists all DSC resources available on the computer. DSC resources are building blocks (like modules) for configuration scripts.
#### Key Points
- Shows all available DSC resources and their properties.
- Useful for discovering what can be managed/configured with DSC.
**List All DSC Resources**
```powershell
Get-DscResource
```
**Get Details for a Specific Resource**
```powershell
Get-DscResource -Name File
```
---
### New-DSCCheckSum
Creates checksum files for DSC documents and resources, which are used to ensure integrity when deploying configurations.
#### Key Points
- Generates .checksum files for DSC configurations and resources.
- Ensures files have not been tampered with during deployment.
**Create Checksums for a Configuration Folder**
```powershell
New-DSCCheckSum -Path "C:\DSC\Configurations"
```
**Create Checksums for Multiple Files**
```powershell
Get-ChildItem "C:\DSC\Configurations\*.mof" | ForEach-Object { New-DSCCheckSum -Path $_.FullName }
```

---
### Start-DscConfiguration
Applies a DSC configuration to one or more nodes.
#### Key Points
- Pushes a configuration to a node or set of nodes.
- Can run in the background or as a job.
- Supports verbose and force options for troubleshooting and reapplication.
**Apply a Configuration to the Local Node**
```powershell
Start-DscConfiguration -Path "C:\DSC\Configurations" -Wait -Verbose
```
**Apply Configuration to Multiple Nodes in Parallel**
```powershell
Start-DscConfiguration -ComputerName "Server01","Server02" -Path "C:\DSC\Configurations" -Wait -Verbose
```
---
## <font color="#00b050">Event Management</font>
PowerShell provides robust event management cmdlets for handling asynchronous and system events, which are essential for automation, monitoring, and building responsive scripts in scenarios.
### Get-Event
Retrieves events from the PowerShell event queue, allowing you to process or inspect events that have been raised.
#### Key Points
- Lists events currently in the PowerShell event queue.
- Useful for debugging, monitoring, and handling custom or system events.
- Can filter by event ID or source identifier.
**List All Events in the Queue**
```powershell
Get-Event
```
**Get Events by Source Identifier**
```powershell
Get-Event -SourceIdentifier "ProcessCreated"
```
---
### New-Event
Creates a new custom event in the PowerShell event queue. This is useful for signaling between scripts or triggering actions in event-driven automation.
#### Key Points
- Raises a custom event with a specified source identifier.
- Can include custom data with the event.
- Useful for inter-script communication and automation.
**Raise a Custom Event**
```powershell
New-Event -SourceIdentifier "MyCustomEvent" -MessageData "Hello, Event!"
```
**Trigger an Event and Handle It**
```powershell
Register-EngineEvent -SourceIdentifier "MyCustomEvent" -Action { Write-Host "Event received: $($event.MessageData)" }
New-Event -SourceIdentifier "MyCustomEvent" -MessageData "Triggered from script"
```
---
### Remove-Event
Deletes events from the PowerShell event queue, helping you manage or clear events that have been processed or are no longer needed.
#### Key Points
- Removes events by event ID or source identifier.
- Useful for cleaning up the event queue in long-running scripts.
**Remove All Events**
```powershell
Get-Event | Remove-Event
```
**Remove Events by Source Identifier**
```powershell
Get-Event -SourceIdentifier "MyCustomEvent" | Remove-Event
```
---
### Unregister-Event
Cancels an event subscription, stopping PowerShell from listening for a specific event.
#### Key Points
- Unregisters event subscriptions by subscription ID or source identifier.
- Essential for resource management in scripts that register events.
**Unregister an Event Subscription**
```powershell
# Register an event and then unregister it
$subscription = Register-EngineEvent -SourceIdentifier "MyCustomEvent" -Action { Write-Host "Event received" }
Unregister-Event -SubscriptionId $subscription.Id
```
**Unregister All Subscriptions for a Source**
```powershell
Get-EventSubscriber -SourceIdentifier "MyCustomEvent" | Unregister-Event
```
---
### Wait-Event
Waits for an event to occur in the PowerShell event queue, optionally with a timeout. This is useful for building responsive, event-driven scripts.
#### Key Points
- Pauses script execution until an event is received or a timeout occurs.
- Can filter by source identifier.
- Useful for automation, monitoring, and interactive scripts.
**Wait for Any Event**
```powershell
Wait-Event
```
**Wait for a Specific Event with Timeout**
```powershell
Wait-Event -SourceIdentifier "MyCustomEvent" -Timeout 10
```
---
## <font color="#00b050">Copy-Item</font>

The `Copy-Item` cmdlet in PowerShell copies an item (such as a file, folder, or registry key) from one location to another. It works across different PowerShell providers, including the file system and registry. Common aliases include `copy`, `cp`, and `cpi`.
#### Key Points
- Copies files, folders, or other items to a new location.
- Supports recursive copying of directories with the `-Recurse` parameter.
- Can overwrite existing items with the `-Force` parameter.
- Aliases: `copy`, `cp`, `cpi`.
**Example: Copy a File**
```powershell
Copy-Item -Path "C:\Users\ganil\Documents\file.txt" -Destination "C:\Users\ganil\Desktop\file.txt"
```
**Example: Copy a Folder Recursively**
```powershell
Copy-Item -Path "C:\Users\ganil\Documents\MyFolder" -Destination "D:\Backup\MyFolder" -Recurse
```
**Example: Overwrite an Existing File**
```powershell
Copy-Item -Path "C:\Users\ganil\Documents\file.txt" -Destination "C:\Users\ganil\Desktop\file.txt" -Force
```
___
## <font color="#00b050">Content Management</font>

### Add-Content (Alias: ac)
The `Add-Content` cmdlet appends content to the end of a file or item. It is useful for adding lines to text files, logs, or other data files.
#### Key Points
- Appends text or data to an existing file.
- Does not overwrite existing content.
- Alias: `ac`.
**Example: Append Text to a File**
```powershell
Add-Content -Path "C:\Users\ganil\Documents\log.txt" -Value "New log entry"
```
---
### Get-Content (Aliases: cat, type, gc)
The `Get-Content` cmdlet retrieves the content of a file or item at a specific location. It is commonly used to read text files line by line.
#### Key Points
- Reads content from files, such as text files or logs.
- Can read all lines or a specific range.
- Aliases: `cat`, `type`, `gc`.
**Example: Read All Lines from a File**
```powershell
Get-Content -Path "C:\Users\ganil\Documents\log.txt"
```
**Example: Read the First 5 Lines**
```powershell
Get-Content -Path "C:\Users\ganil\Documents\log.txt" -TotalCount 5
```
---
### Set-Content (Alias: sc)
The `Set-Content` cmdlet writes or replaces content in a file or item at a specific location. It overwrites any existing content.
#### Key Points
- Replaces all content in the specified file.
- Useful for creating or resetting files.
- Alias: `sc`.
**Example: Overwrite a File with New Content**
```powershell
Set-Content -Path "C:\Users\ganil\Documents\log.txt" -Value "This is the new content."
```

---
### Clear-Content (Alias: clc)
The `Clear-Content` cmdlet removes all content from a file or item but does not delete the file itself.
#### Key Points
- Empties the contents of a file or item.
- The file remains but is blank.
- Alias: `clc`.
**Example: Clear the Contents of a File**
```powershell
Clear-Content -Path "C:\Users\ganil\Documents\log.txt"
```
___
## <font color="#00b050">Localization & Regional Settings</font>

### Get-Culture
The `Get-Culture` cmdlet retrieves information about the current culture settings of the Windows operating system, including language, regional format, and keyboard layout. This is essential for scripts that need to adapt to different locales or for troubleshooting internationalization issues.
#### Key Points
- Returns the current culture (locale) settings for the user.
- Includes information such as language, date/time format, and keyboard layout.
- Useful for ensuring scripts behave correctly in different regions.
**Display Current Culture Settings**
```powershell
Get-Culture
```
**Use Culture Info in a Script**
```powershell
# Display the current date in the user's regional format
(Get-Date).ToString((Get-Culture).DateTimeFormat)
```
---
### Set-Culture
The `Set-Culture` cmdlet sets the culture (locale) for the current user account. This affects how dates, times, numbers, and currency are formatted, as well as the language used for system messages.
#### Key Points
- Changes the user culture for the current account.
- Requires administrative privileges and a restart to take full effect.
- Useful for preparing systems for users in different regions or for testing localization.
**Set Culture to US English**
```powershell
Set-Culture -CultureInfo "en-US"
```
**Set Culture to French (France)**
```powershell
Set-Culture -CultureInfo "fr-FR"
```
These cmdlets are important for professionals working in multinational environments or preparing systems for global deployment.
___
## <font color="#00b050">Networking </font>
### Test-Connection
The `Test-Connection` cmdlet in PowerShell sends ICMP echo requests ("pings") to one or more computers to test network connectivity. It is similar to the traditional `ping` command but offers more flexibility and output options.
#### Key Points
- Tests network connectivity to remote computers.
- Can send multiple echo requests and display detailed results.
- Supports testing multiple computers at once.
- Useful for troubleshooting network issues.
**Example: Ping a Single Computer**
```powershell
Test-Connection -ComputerName "google.com"
```
**Example: Ping Multiple Computers**
```powershell
Test-Connection -ComputerName "Server01","Server02","8.8.8.8"
```
**Example: Send a Specific Number of Echo Requests**
```powershell
Test-Connection -ComputerName "google.com" -Count 5
```
This cmdlet is essential for verifying network connectivity and diagnosing network problems.
___
### <font color="#00b050">DNS Management</font>

### Get-DnsClientCache
The `Get-DnsClientCache` cmdlet retrieves the content of the local DNS client cache. This is useful for troubleshooting name resolution issues and viewing cached DNS records.
#### Key Points
- Displays all DNS records currently cached on the local system.
- Useful for diagnosing DNS resolution problems and verifying recent lookups.
**View the Local DNS Cache**
```powershell
Get-DnsClientCache
```
**Filter for a Specific Hostname**
```powershell
Get-DnsClientCache | Where-Object { $_.Entry -like "*example.com*" }
```
---
### Clear-DnsClientCache
The `Clear-DnsClientCache` cmdlet clears the content of the DNS client cache. This is helpful when you need to force the system to resolve names again, such as after DNS changes.
#### Key Points
- Removes all cached DNS entries from the local system.
- Useful for troubleshooting and ensuring fresh DNS lookups.
**Clear the DNS Cache**
```powershell
Clear-DnsClientCache
```
---
### Get-DnsClientServerAddress
The `Get-DnsClientServerAddress` cmdlet retrieves the DNS server IP addresses configured on the network interfaces of the local computer.
#### Key Points
- Lists DNS server addresses for each network interface.
- Useful for auditing and troubleshooting network configurations.
**List DNS Servers for All Interfaces**
```powershell
Get-DnsClientServerAddress
```
**Show DNS Servers for a Specific Interface**
```powershell
Get-DnsClientServerAddress -InterfaceAlias "Ethernet"
```
---
### Set-DnsClientServerAddress
The `Set-DnsClientServerAddress` cmdlet sets the DNS server IP addresses on a network interface. This is essential for configuring static DNS or switching between DNS providers.
#### Key Points
- Assigns one or more DNS server addresses to a network interface.
- Can be used to set static or revert to automatic DNS configuration.
- Requires administrator privileges.
**Set Google DNS on an Interface**
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "8.8.8.8","8.8.4.4"
```
**Reset DNS to Automatic**
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
```
---
### Resolve-DnsName
The `Resolve-DnsName` cmdlet performs a DNS name query resolution for a specified name, similar to the `nslookup` command but with structured output.
#### Key Points
- Resolves hostnames to IP addresses and vice versa.
- Supports querying specific DNS record types (A, AAAA, MX, etc.).
- Useful for troubleshooting and verifying DNS records.
**Resolve a Hostname**
```powershell
Resolve-DnsName -Name "example.com"
```
**Query for MX Records**
```powershell
Resolve-DnsName -Name "example.com" -Type MX
```
---
## <font color="#00b050">Performance Monitoring</font>

### Export-Counter
The `Export-Counter` cmdlet in PowerShell exports performance counter data to log files. This is essential for long-term monitoring, capacity planning, and troubleshooting performance issues in enterprise environments.
#### Key Points
- Exports collected performance data to .blg, .csv, or .tsv log files.
- Useful for archiving, sharing, or analyzing performance data over time.
- Can be used in scheduled tasks for continuous monitoring.
**Practical Example: Export Performance Data to a BLG File**
```powershell
# Export collected counter data to a binary log file
Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 5 -MaxSamples 10 | 
Export-Counter -Path "C:\PerfLogs\cpu_usage.blg"
```
**Advanced Example: Export Multiple Counters to a CSV File**
```powershell
# Collect and export multiple counters to a CSV file for later analysis
Get-Counter -Counter "\Memory\Available MBytes","\Processor(_Total)\% Processor Time" -SampleInterval 10 -MaxSamples 30 | 
Export-Counter -Path "C:\PerfLogs\system_performance.csv" -FileFormat CSV
```
---
### Get-Counter
The `Get-Counter` cmdlet retrieves real-time performance counter data from local or remote computers. This is a core tool for monitoring system health, diagnosing bottlenecks, and validating system changes.
#### Key Points
- Retrieves data from Windows performance counters.
- Can monitor CPU, memory, disk, network, and custom application metrics.
- Supports both real-time and historical data collection.
**Practical Example: Get Current CPU Usage**
```powershell
Get-Counter -Counter "\Processor(_Total)\% Processor Time"
```

**Advanced Example: Monitor Multiple Counters Over Time**
```powershell
# Collect CPU and memory usage every 2 seconds, 5 times
Get-Counter -Counter "\Processor(_Total)\% Processor Time","\Memory\Available MBytes" -SampleInterval 2 -MaxSamples 5
```

**Example: Get Counter Data from a Remote Computer**
```powershell
Get-Counter -ComputerName "Server01" -Counter "\LogicalDisk(_Total)\% Free Space"
```

---
### Import-Counter
The `Import-Counter` cmdlet imports performance counter log files for analysis. This is useful for reviewing historical performance data, generating reports, or comparing system behavior over time.
#### Key Points
- Imports .blg, .csv, or .tsv log files created by `Export-Counter` or Performance Monitor.
- Enables analysis and visualization of historical performance data.
- Can filter and select specific counters or time ranges.
**Practical Example: Import and View Performance Data**
```powershell
# Import a previously exported performance log
Import-Counter -Path "C:\PerfLogs\cpu_usage.blg"
```
**Advanced Example: Filter Imported Data for a Specific Counter**
```powershell
# Import and display only memory counters from a log file
Import-Counter -Path "C:\PerfLogs\system_performance.csv" | 
Where-Object { $_.CounterSamples.Path -like "*Memory*" }
```
These cmdlets are essential for performance monitoring, troubleshooting, and capacity planning in Windows environments.
___
## <font color="#00b050">Programming </font>
### Break
The `break` statement in PowerShell is used to immediately exit a loop (`for`, `foreach`, `while`, or `do`) or a `switch` statement. It is useful for stopping execution when a certain condition is met within the loop.
#### Key Points
- Exits the innermost enclosing loop or switch statement.
- Execution continues with the statement following the loop or switch.
- Commonly used for conditional exits in scripts.
**Example: Using Break in a Loop**
```powershell
foreach ($number in 1..10) {
    if ($number -eq 5) {
        break
    }
    Write-Host $number
}
```
In this example, the loop stops when `$number` equals 5, so only numbers 1 to 4 are printed.
___
### Catch
The `catch` block in PowerShell is used to handle terminating errors that occur within a `try` block. It allows you to gracefully manage errors, log them, or take corrective actions instead of letting the script fail unexpectedly.
#### Key Points
- Used with `try` and `finally` blocks for structured error handling.
- Only catches terminating errors (use `-ErrorAction Stop` to make non-terminating errors catchable).
- Can access error details using the `$_` variable inside the `catch` block.
**Example: Using Try/Catch to Handle Errors**
```powershell
try {
    # Attempt to remove a file (will error if file doesn't exist)
    Remove-Item "C:\Users\ganil\Documents\nonexistent.txt" -ErrorAction Stop
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
}
```
In this example, if the file does not exist, the `catch` block will handle the error and display a message instead of stopping the script.
___
### Continue
The `continue` statement in PowerShell is used within loops (`for`, `foreach`, `while`, or `do`) to skip the current iteration and move directly to the next iteration of the loop. It is useful when you want to bypass certain conditions without exiting the loop entirely.
#### Key Points
- Skips the rest of the code in the current loop iteration.
- Execution continues with the next iteration of the loop.
- Commonly used for filtering or conditional processing in loops.
**Example: Using Continue in a Loop**
```powershell
foreach ($number in 1..5) {
    if ($number -eq 3) {
        continue
    }
    Write-Host $number
}
```
In this example, the number 3 is skipped, so only 1, 2, 4, and 5 are printed.
___
## <font color="#00b050">Security & Authentication</font>

### Get-Credential
The `Get-Credential` cmdlet in PowerShell prompts the user for a username and password, returning a credential object that can be used for authentication in scripts and cmdlets. This is essential for securely handling credentials in automation, remote management, and when accessing protected resources.
#### Key Points
- Prompts for or accepts credentials (username and password).
- Returns a `PSCredential` object for use with cmdlets that require authentication.
- Can be used interactively or with pre-supplied credentials for automation.
- Helps avoid storing plain-text passwords in scripts.
**Practical Example: Prompt for Credentials**
```powershell
# Prompt the user for credentials and store them in a variable
$cred = Get-Credential
```
**Advanced Example: Use Credentials for Remote Connection**
```powershell
# Use the credential object to connect to a remote computer
Invoke-Command -ComputerName "Server01" -Credential (Get-Credential) -ScriptBlock { Get-Service }
```
**Example: Pre-supply Username for Automation**
```powershell
# Prompt for password only, useful in automated scripts
$cred = Get-Credential -UserName "domain\admin"
```
This cmdlet is fundamental for secure automation  tasks involving remote management, Active Directory, and secure resource access.
___
An A-Z Index of Windows PowerShell commands
 	Cmdlet	Alias	Description
 	 	 % 	Alias for ForEach-Object
 	 	 ? 	Alias for Where-Object

 	
 
 	
 	
 	Remove-Item	Del / erase / rd / rm / rmdir	Delete an item.
 	Compare-Object	diff / compare	Compare the properties of objects.
 	
 	Do	 	Loop while a condition is True.
 	
E	 	 	 
 	Write-Output	Echo	Write an object to the pipeline.
 	End	 	Function END block.
 	Get-Error	gerr	Get and display errors.
 		 	Wait until a particular event is raised.
 	Clear-EventLog	 	Delete all entries from an event log.
 	Get-Eventlog	 	Get event log data (2003).
 	Limit-EventLog	 	Limit the size of the event log.
 	New-Eventlog	 	Create a new event log and a new event source.
 	Remove-EventLog	 	Delete an event log.
 	Show-EventLog	 	Display an event log.
 	Write-EventLog	 	Write an event to an event log.
 	Get-WinEvent	 	Get event log data.
 	Get-EventSubscriber	 	Get event subscribers.
 	Register-EngineEvent	 	Subscribe to PowerShell events.
 	Register-ObjectEvent	 	Subscribe to .NET events.
 	Register-WmiEvent	 	Subscribe to a WMI event.
 	Get-ExecutionPolicy	 	Get the execution policy for the shell.
 	Set-ExecutionPolicy	 	Change the execution policy (user preference).
 	Export-Alias	epal	Export currently defined aliases to a file.
 	Export-Clixml	 	Produce a clixml representation of PowerShell objects.
 	Export-Console	 	Export console configuration to a file.
 	Export-Csv	epcsv	Export to Comma Separated Values (spreadsheet).
 	Exit-PSSession	exsn	Exit a PowerShell session.
 	Exit	 	Exit a script or exit PowerShell.
F	 	 	 
 	-F operator	 	Format operator.
 	Unblock-File	 	Unblock files downloaded from the Internet.
 	Get-FileHash	 	Compute the hash value for a file.
 	ForEach-Object	foreach	Loop through each item in the pipeline ( % ).
 	ForEach	 	Loop through each item in a collection.
 	ForEach method	 	Loop through each item in a collection.
 	For	 	Loop through items that match a condition.
 	Format-Custom	fc	Format output using a customized view.
 	Format-Hex	fhx	Display a file or other input as hexadecimal.
 	Format-List	fl	Format output as a list of properties, each on a new line.
 	Format-Table	ft	Format output as a table.
 	Format-Wide	fw	Format output as a table listing one property only.
 	Export-FormatData	 	Save formatting data from the current session.
 	Get-FormatData	 	Get the formatting data in the current session.
G	 	 	 
 	Get-Item	gi	Get a file/registry object (or any other namespace object).
 	Get-ChildItem	dir / ls / gci	Get child items (contents of a folder or registry key).
 	Backup-GPO	 	Backup group policy objects (GPOs).
 	Restore-GPO	 	Restore one or all GPOs from a GPO backup.
 	Import-GPO	 	Import Group Policy settings into a specified GPO from a GPO backup.
 	Group-Object	group	Group objects that contain the same value.
 	New-Guid	 	Create a GUID.
H	 	 	 
 	Get-Help	help	Open the help file.
 	Update-Help	 	Download and install the newest help files on your computer.
 	Add-History	 	Add entries to the session history.
 	Clear-History	clhy	Delete entries from the session history.
 	Get-History	history / h / ghy	Get a listing of the session history.
 	Invoke-History	r / ihy	Invoke a previously executed Cmdlet.
 	Get-Host	 	Get host information (PowerShell Version and Region).
 	Clear-Host	clear / cls	Clear the screen.
 	Out-Host	oh	Send output to the host.
 	Read-Host	 	Read a line of user input from the host console.
 	Write-Host	 	Write customized output to the host/screen.
 	Get-HotFix	 	Get Installed hotfixes.
I	 	 	 
 	IF	 	Conditionally perform a command.
 	Invoke-CimMethod	icim	Invoke a method of a CIM class or CIM instance.
 	Import-Clixml	 	Import a clixml file and rebuild the PS object.
 	Import-Csv	ipcsv	Take values from a CSV list and send objects down the pipeline.
 	Import-PfxCertificate	 	Import certificates and keys from a Personal Information Exchange (PFX) file.
 	Write-Information	 	Specify how PowerShell should handle information stream data.
 	Get-InitiatorPort	 	Get one or more host bus adapter (HBA) initiator ports.
 	Install-Module	 	Download and install one or more modules from an online gallery.
 	Install-Package	 	Install one or more software packages.
 	Invoke-Command	icm	Run commands on local and remote computers.
 	Invoke-Expression	iex	Run a PowerShell expression.
 	Invoke-WebRequest	iwr	Get content from a web page.
 	Invoke-RestMethod	irm	Send an HTTP or HTTPS request to a RESTful web service.
 	Get-NetIPAddress	 	Get IPAddress configuration
 	Get-Item	gi	Get a file object or get a registry (or other namespace) object.
 	Invoke-Item	ii	Invoke an executable or open a file (START).
 	New-Item	md / mkdir / ni	Create a new item in a namespace.
 	Remove-Item	del / erase / rd / ri / rm/ rmdir	Remove an item.
 	Set-Item	si	Change the value of an item.
 	Clear-ItemProperty	clp	Remove the property value from a property.
 	Copy-ItemProperty	cpp	Copy a property along with its value.
 	Get-ItemProperty	gp	Retrieve the properties of an object.
 	Move-ItemProperty	mp	Move a property from one location to another.
 	New-ItemProperty	 	Set a new property.
 	Remove-ItemProperty	rp	Remove a property and its value.
 	Rename-ItemProperty	rnp	Rename a property at its location.
 	Set-ItemProperty	sp	Set a property at the specified location to a specified value.
 	Get-ItemPropertyValue	gpv	Get the value for one or more properties of a specified item.
J	 	 	 
 	Get-Job	gjb	Get PowerShell background jobs that are running.
 	Receive-Job	rcjb	Get PowerShell background job results.
 	Remove-Job	rjb	Delete a PowerShell background job.
 	Resume-Job	rujb	Restart a suspended job.
 	Start-Job	sajb	Start a PowerShell background job.
 	Stop-Job	spjb	Stop a PowerShell background job.
 	Suspend-Job	sujb	Suspend a PowerShell background job.
 	Wait-Job	wjb	Wait for a background job.
 	Job Trigger cmdlets	 	Get/Set Scheduled job triggers.
K	 	 	 
 	Stop-Process	kill / spps	Stop a running process.
 	Add-KdsRootKey	 	Generate a new root key for the MS.Group KdsSvc within AD.
L	 	 	 
 	Update-List	 	Add and remove items from a collection.
 	New-LocalGroup	 	Add a new local security group.
 	Get-LocalGroup	 	Get the local security groups.
 	Remove-LocalGroup	 	Remove a local security group.
 	Rename-LocalGroup	 	Rename a local security group.
 	Set-LocalGroup	 	Change a local security group.
 	Add-LocalGroupMember	 	Add members to a local group.
 	Get-LocalGroupMember	 	Get members from a local group.
 	Get-LocalUser	 	Get a local user account.
 	New-LocalUser	 	Create a local user account.
 	Set-LocalUser	 	Modify a local user account.
 	Get-Location	pwd / gl	Get and display the current location.
 	Pop-Location	popd	Set the current working location from the stack.
 	Push-Location	pushd	Push a location to the stack.
 	Set-Location	cd / chdir / sl	Set the current working location.
 	Get-WinSystemLocale	 	Get the System-locale setting for the current computer.
M	 	 	 
 	Send-MailMessage	 	Send an email message.
 	Measure-Object	measure	Measure the properties of an object.
 	Add-Member	 	Add a member to an instance of a PowerShell object.
 	Get-Member	gm	Enumerate the properties of an object.
 	MessageBox	 	Display a message box to the user
 	Find-Module	 	Find modules from an online gallery.
 	Get-Module	gmo	Get the modules imported to the session.
 	Import-Module	ipmo	Add a module to the session.
 	Install-Module	 	Download and install modules from an online repository.
 	New-Module	nmo	Create a new dynamic module (only in memory).
 	Remove-Module	rmo	Remove a module from the current session.
 	Save-Module	 	Save a module locally without installing it.
 	Get-InstalledModule	 	Get installed modules on a computer.
 	Uninstall-Module	 	Uninstall a module.
 	Update-Module	 	Download/install a new module version.
 	Export-ModuleMember	 	Export specific module members.
 	Move-Item	mv / move / mi	Move an item from one location to another.
 	Set-MpPreference	 	Configure preferences for Windows Defender.
N	 	 	 
 	Get-NetAdapter	 	Get the basic network adapter properties.
 	Set-NetAdapter	 	Set the basic network adapter properties.
 	Disable-NetAdapterBinding	 	Disable a binding to a network adapter.
 	Get-NetAdapterVmq	 	Get the VMQ properties of a network adapter.
 	Set-NetAdapterVmq	 	Set the VMQ properties of a network adapter.
 	Test-NetConnection	tnc	Display diagnostic information for a connection.
 	Get-NetConnectionProfile	 	Get a connection profile.
 	Set-NetConnectionProfile	 	Set a connection profile.
 	Set-NetFirewallProfile	 	Configure per-profile settings of Windows Firewall.
 	Enable-NetFirewallRule	 	Enable a previously disabled firewall rule.
 	Set-NetFirewallRule	 	Modify existing firewall rules.
 	Get-NetFirewallRule	 	Retrieve firewall rules from the target computer.
 	New-NetFirewallRule	 	Create a new firewall rule and add to a target computer.
 	Get-NetIPAddress	 	Get IP address configuration.
 	New-NetIPAddress	 	Create and configure an IP address.
 	Remove-NetIPAddress	 	Remove an IP address and its configuration.
 	Set-NetIPAddress	 	Modify the configuration of an IP address.
 	Get-NetIPConfiguration	 	Get IP network configuration.
 	Get-NetIPInterface	 	Get an IP interface.
 	Set-NetIPInterface	 	Modify an IP interface.
 	New-NetLbfoTeam	 	Create a new NIC team.
 	New-NetNat	 	Create a NAT object.
 	New-NetRoute	 	Create a route in the IP routing table.
 	Get-NetTCPConnection	 	Get TCP connections.
 	Set-NetTCPSetting	 	Modify a TCP setting.
O	 	 	 
 	Compare-Object	diff / compare	Compare the properties of objects.
 	Group-Object	group	Group objects that contain the same value.
 	Measure-Object	 	Measure the properties of an object.
 	New-Object	 	Create a new .Net object.
 	Select-Object	select	Select properties of objects.
 	Sort-Object	sort	Sort objects by property value.
 	Where-Object	 	Filter the objects passed along the command pipeline.
 	Add-OdbcDsn	 	Add an ODBC DSN.
 	Out-Default	 	Set the destination of default output.
 	Out-File	>	Send output to a file.
 	Out-GridView	ogv	Send output to an interactive table.
 	Out-Host	oh	Send output to the host.
 	Out-Null	 	Send output to null.
 	Out-Printer	lp	Send the output to a printer.
 	Out-String	 	Send objects to the host as strings.
P	 	 	 
 	Get-Package	 	Return a list of all software packages installed using Package Management.
 	Find-Package	 	Find software packages in available package sources.
 	Install-Package	 	Install one or more software packages.
 	Uninstall-Package	 	Uninstall one or more software packages.
 	Install-PackageProvider	 	Install one or more Package Management package providers.
 	Param	 	Script Parameters.
 	Get-Partition	 	Return a list of partition objects.
 	New-Partition	 	Create a new partition on an existing Disk object.
 	Resize-Partition	 	Resize a partition and the underlying file system.
 	Set-Partition	 	Set attributes of a partition: active, read-only, offline.
 	Convert-Path	cvpa	Convert a ps path to a provider path.
 	Join-Path	 	Combine a path and one or more child-paths.
 	Resolve-Path	rvpa	Resolves the wildcards in a path.
 	Split-Path	 	Return part of a path.
 	Test-Path	 	Return true if the path exists, otherwise return false.
 	Pause	 	Pause and display the message "Press Enter to continue..."
 	Invoke-Pester	 	Invoke Pester to recursively run all tests.
 	Export-PfxCertificate	 	Export a certificate or a PFXData object to a PFX file.
 	Get-PfxCertificate	 	Get pfx certificate information.
 	Get-PhysicalDisk	 	Retrieve a list of Physical Disk objects.
 	Remove-PhysicalDisk	 	Remove a physical disk from a specified storage pool.
 	Set-PhysicalDisk	 	Set attributes on a specific physical disk.
 	Get-PnpDevice	 	Return information about PnP devices.
 	Pop-Location	popd	Set the current working location from the stack.
 	Push-Location	pushd	Push a location to the stack.
 	Powershell	pwsh	Launch a PowerShell session/run a script.
 	Add-Printer	 	Add a printer to the specified computer.
 	Get-Printer	 	Retrieve a list of printers installed on a computer.
 	Remove-Printer	 	Remove a printer from the specified computer.
 	Set-Printer	 	Update the configuration of an existing printer.
 	Add-PrinterDriver	 	Install a printer driver on the computer.
 	Add-PrinterPort	 	Install a printer port on the computer.
 	Get-PrintJob	 	Retrieve a list of print jobs from the specified printer.
 	Process	 	Function PROCESS block.
 	Get-Process	ps / gps	Get a list of processes on a machine.
 	Debug-Process	 	Attach a debugger to a running process.
 	Start-Process	start / saps	Start one or more processes.
 	Stop-Process	kill / spps	Stop a running process.
 	Wait-Process	 	Wait for a process to stop.
 	Enable-PSBreakpoint	ebp	Enable a breakpoint in the current console.
 	Disable-PSBreakpoint	dbp	Disable a breakpoint in the current console.
 	Get-PSBreakpoint	gbp	Get the currently set breakpoints.
 	Set-PSBreakpoint	sbp	Set a breakpoint on a line, command, or variable.
 	Remove-PSBreakpoint	rbp	Delete breakpoints from the current console.
 	Get-PSCallStack	gcs	Display the current call stack.
 	Get-PSDrive	gdr	Get drive information (DriveInfo).
 	New-PSDrive	mount / ndr	Create a mapped network drive.
 	Remove-PSDrive	rdr	Remove a provider/drive from its location.
 	Get-PSProvider	 	Get information for the specified provider.
 	Set-PSdebug	 	Turn script debugging on or off.
 	Disable-PSRemoting	 	Disable remote session configuration on the local computer.
 	Enable-PSRemoting	 	Configure the computer to receive remote commands.
 	Get-PSRepository	 	Get PowerShell repositories.
 	Register-PSRepository	 	Register a PowerShell repository.
 	Set-PSRepository	 	Set values for a registered repository.
 	Connect-PSSession	cnsn	Reconnect to a disconnected session.
 	Disconnect-PSSession	dnsn	Disconnect from a session.
 	Enter-PSSession	etsn	Start an interactive session with a remote computer.
 	Exit-PSSession	exsn	End an interactive session with a remote computer.
 	Export-PSSession	epsn	Import commands and save them in a PowerShell module.
 	Get-PSSession	gsn	Get the PSSessions in the current session.
 	Import-PSSession	ipsn	Import commands from another session.
 	New-PSSession	nsn	Create a persistent connection to a local or remote computer.
 	Receive-PSSession	rcsn	Receive a PSSession.
 	Remove-PSSession	rsn	Close PowerShell sessions.
 	Disable-PSSessionConfiguration	 	Disable session configurations on the local computer.
 	Enable-PSSessionConfiguration	 	Enable session configurations on the local computer.
 	Get-PSSessionConfiguration	 	Get the registered PS session configuration.
 	Register-PSSessionConfiguration	 	Create and register a new PS session configuration.
 	Set-PSSessionConfiguration	 	Change properties of a registered session configuration.
 	Unregister-PSSessionConfiguration	 	Delete registered PS session configuration.
 	New-PSSessionConfigurationFile	 	Create a file that defines a session configuration.
 	New-PSSessionOption	 	Advanced options for a PSSession.
 	Add-PsSnapIn	 	Add snap-ins to the console.
 	Get-PsSnapin	 	List PowerShell snap-ins on this computer.
 	Remove-PSSnapin	 	Remove PowerShell snap-ins from the console.
R	 	 	 
 	Get-Random	 	Get a random number.
 	Read-Host	 	Read a line of input from the host console.
 	Clear-RecycleBin	 	Clear the RecycleBin.
 	Remove-Item	del / erase / rd / ri / rm / rmdir	Remove an item.
 	Rename-Item	ren / rni	Change the name of an existing item.
 	Rename-ItemProperty	rnp	Rename a property of an item.
 	Restart-Computer	 	Restart the Operating System on a computer.
 	Return	 	Exit the current scope, (function, script, or script block).
 	Run/Call	 & 	Run a command (call operator).
S	 	 	 
 	Scheduler cmdlets	 	Get/Set scheduled jobs.
 	Confirm-SecureBootUEFI	 	Confirm that Secure Boot is enabled on the local computer.
 	Select-Object	select	Select properties of objects.
 	Select-XML	 	Find text in an XML string or document.
 	New-SelfSignedCertificate	 	Create a new self-signed certificate for testing purposes.
 	Send-MailMessage	 	Send an email message.
 	Get-Service	gsv	Get a list of services.
 	New-Service	 	Create a new service.
 	Restart-Service	 	Stop and then restart a service.
 	Resume-Service	 	Resume a suspended service.
 	Set-Service	 	Change the start mode/properties of a service.
 	Start-Service	sasv	Start a stopped service.
 	Stop-Service	spsv	Stop a running service.
 	Suspend-Service	 	Suspend a running service.
 	Sort-Object	sort	Sort objects by property value.
 	Get-SmbConnection	 	Retrieve the connections established from the SMB client to the SMB servers.
 	Get-SmbOpenFile	 	Information about files that are open on behalf of SMB server clients.
 	Get-SMBMapping	 	Get an SMB mapping.
 	New-SmbMapping	 	Create an SMB mapping.
 	Remove-SmbMapping	 	Remove an SMB mapping.
 	Get-SmbSession	 	Retrieve information about current SMB sessions.
 	Set-SmbClientConfiguration	 	Set the SMB client configuration.
 	Get-SmbServerConfiguration	 	Get the SMB Server configuration.
 	Set-SmbServerConfiguration	 	Set the SMB Server configuration.
 	Get-SmbShare	 	Retrieve the SMB shares on the computer.
 	Set-SmbShare	 	Modify the properties of an SMB share.
 	New-SmbShare	 	Create an SMB share.
 	Remove-SmbShare	 	Remove an SMB share.
 	Get-SmbShareAccess	 	Retrieve the ACL of an SMB share.
 	Grant-SmbShareAccess	 	Add an allow ACE for a trustee to the security descriptor of the SMB share.
 	Set-StrictMode	 	Enforce coding rules in expressions & scripts.
 	Get-StartApps	 	Get the names and IDs of apps installed on the Start Menu.
 	Export-StartLayout	 	Export layout of the Start screen as an .xml file.
 	Import-StartLayout	 	Import the layout of the Start into a mounted Windows image.
 	Start-Sleep	sleep	Suspend shell, script, or runspace activity.
 	Get-StorageJob	 	Information about long-running Storage module jobs, such as a repair task.
 	New-StoragePool	 	Create a new storage pool using a group of physical disks.
 	Switch	 	Check multiple conditions.
 	ConvertFrom-StringData	 	Convert a here-string into a hash table.
 	Select-String	sls	Search through strings or files for patterns.
T	 	 	 
 	Tee-Object	tee	Send input objects to two places.
 	New-Timespan	 	Create a timespan object.
 	Get-TimeZone	gtz	Get the current time zone or a list of available time zones.
 	Set-TimeZone	stz	Set the system time zone to a specified time zone.
 	Get-TlsCipherSuite	 	Get the list of cipher suites for TLS for a computer.
 	Get-Tpm	 	Trusted Platform Module (TPM).
 	Trace-Command	trcm	Trace an expression or command.
 	Get-Tracesource	 	Get components that are instrumented for tracing.
 	Set-Tracesource	 	Trace a PowerShell component.
 	Start-Transaction	 	Start a new transaction.
 	Complete-Transaction	 	Commit the transaction.
 	Get-Transaction	 	Get information about the active transaction.
 	Use-Transaction	 	Add a command or expression to the transaction.
 	Undo-Transaction	 	Roll back a transaction.
 	Start-Transcript	 	Start a transcript of a command shell session.
 	Stop-Transcript	 	Stop the transcription process.
 	Trap	 	Handle a terminating error.
 	Try ... Catch	 	Handle a terminating error within a scriptblock.
 	Add-Type	 	Add a .NET Framework type to a PowerShell session.
 	Update-TypeData	 	Update extended type configuration.
U	 	 	 
 	Get-Uiculture	 	Get the ui culture information.
 	Unblock-File	 	Unblock files downloaded from the Internet.
 	Get-Unique	gu	Get the unique items in a collection.
 	Update-Formatdata	 	Update and append format data files.
 	Update-Help	 	Download and install help files.
 	Update-Typedata	 	Update the current extended type configuration.
V	 	 	 
 	Clear-Variable	clv	Remove the value from a variable.
 	Get-Variable	gv	Get a PowerShell variable.
 	New-Variable	nv	Create a new variable.
 	Remove-Variable	rv	Remove a variable and its value.
 	Set-Variable	set / sv	Set a variable and a value.
 	Get-VirtualDisk	 	Return a list of VirtualDisks across storage pools/providers.
 	New-VirtualDisk	 	Create a new virtual disk in the specified storage pool.
 	Get-Volume	 	Get the specified Volume object, or all Volume objects.
 	Format-Volume	 	Format one or more volumes.
 	New-Volume	 	Create a volume with the specified file system.
 	Optimize-Volume	 	Optimize a volume.
 	Repair-Volume	 	Perform repairs on a volume.
 	Add-VpnConnection	 	Add a VPN connection to the Connection Manager phone book.
 	Get-VpnConnection	 	Retrieve the specified VPN connection profile information.
 	Set-VpnConnection	 	Change the config. of a VPN connection profile.
 	Add-VpnConnectionRoute	 	Add a route to a VPN connection.
W	 	 	 
 	Checkpoint-WebApplicationMonitoring	 	Create a checkpoint for an IIS web app.
 	Get-WebApplicationMonitoringStatus	 	Get the monitoring status of web apps.
 	New-WebServiceProxy	 	Create a Web service proxy object.
 	Invoke-WebRequest	iwr	Get content from a web page.
 	Where-Object	where / ?	Filter input from the pipeline.
 	Where method	 	Filter objects from a collection.
 	While	 	Loop while a condition is True.
 	Add-WindowsCapability	 	Install a Windows capability package on the specified OS image.
 	Get-WindowsCapability	 	Get capabilities for an image or a running OS.
 	Remove-WindowsCapability	 	Uninstall a Windows capability package from an image.
 	Export-WindowsDriver	 	 
 	Add-WindowsFeature	 	Install roles, role services, and features. (Server 2008 R2).
 	Get-WindowsFeature	 	Retrieve roles, role services, and features.
 	Install-WindowsFeature	 	Install roles, role services, or features (Server 2012 R2).
 	Uninstall-WindowsFeature	 	Uninstall/remove roles, role services, and features (2012 R2)
 	Mount-WindowsImage	 	Mount a Windows image (WIM or VHD file) to a directory on the local computer.
 	Repair-WindowsImage	 	Repair a Windows image in a WIM or VHD file.
 	Disable-WindowsOptionalFeature	 	Disable a feature in a Windows image.
 	Enable-WindowsOptionalFeature	 	Enable a feature in a Windows image.
 	Get-WindowsOptionalFeature	 	Get information about optional features in a Windows image.
 	Add-WindowsPackage	 	Add a single .cab or .msu file to a Windows image.
 	Get-WindowsPackage	 	Get information about packages in a Windows image.
 	Remove-WindowsPackage	 	Remove a package from a Windows image.
 	Get-WindowsUpdateLog	 	Merge Windows Update .etl files into a single log file.
 	Set-WinSystemLocale	 	Set the system locale for the current computer.
 	Set-WinUserLanguageList	 	Set the language list/properties for the current user.
 	Write-Debug	 	Write a debug message to the console (5).
 	Write-Error	 	Write an object to the error pipeline (2).
 	Write-Host	 	Display text on screen.
 	Write-Information	 	Write to the information data stream (6).
 	Write-Output	write / echo	Write an object to the pipeline (1).
 	Write-Progress	 	Display a progress bar.
 	Write-Verbose	 	Write a string to the host’s verbose display (4).
 	Write-Warning	 	Write a warning string (3) in reverse video to the display.
 	Set-WmiInstance	swmi	Create or update an instance of an existing WMI class.
 	Invoke-WmiMethod	iwmi	Call WMI methods.
 	Get-WmiObject	gwmi	Get WMI class information.
 	Remove-WmiObject	rwmi	Delete an instance of a WMI class.
 	Connect-WSMan	 	Connect to the WinRM service on a remote computer.
 	Disconnect-WSMan	 	Disconnect from the WinRM service on a remote computer.
 	Test-WSMan	 	Test if a computer is setup to receive remote commands.
 	Invoke-WSManAction	 	Invoke an action on a specified object.
 	Disable-WSManCredSSP	 	Disable Credential Security Service Provider (SSP) authentication.
 	Enable-WSManCredSSP	 	Enable Credential SSP authentication.
 	Get-WSManCredSSP	 	Get the Credential SSP configuration.
 	New-WSManInstance	 	Create a new instance of a management resource.
 	Get-WSManInstance	 	Display management information (XML or value).
 	Set-WSManInstance	 	Modify the management information related to a resource.
 	Remove-WSManInstance	 	Delete a management resource instance.
 	Set-WSManQuickConfig	 	Configure the local computer for remote management.
 	New-WSManSessionOption	 	Options for WSMan commands.
Z	 	 	 
 	Zip	 	Compress or Extract zip files.
 	 	 # 	
Comment / Remark.
 	 	 . 	Run a command script in the current shell. Source or dot operator.
 	 	 & 	Run a command, script or function. Call operator.
 	 	 % 	Alias for ForEach-Object.
 	 	--% 	Stop parsing input.
 	 	 ? 	Alias for Where-Object.
 	$variable = "value"	 	Define a variable also: ${n!a#me} = "value".
 	 	$_	The current pipeline object.
 	 	@(...)	Force an expression to be evaluated as an array.
 	 	 ` 	Escape or Continue on the next line.
The cmdlets above are listed in A-Z order, matching the Verb- and/or -Noun and/or Alias of the cmdlet (so some duplicates).
To scroll this page, press [ a – z ] on the keyboard, also on the detail pages 's' = syntax 'e' = examples, '\' = Search.

PowerShell can also run all the standard CMD commands (external commands), .cmd batch files will run within a CMD.exe shell (so can include internal CMD commands), plus all Resource Kit utilities.