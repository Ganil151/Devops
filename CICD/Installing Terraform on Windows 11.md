Terraform is a single binary executable. The simplest method for installation on Windows is to download the pre-compiled binary and add its location to your system's PATH.

**Step 1: Download Terraform**
1. **Open your web browser** on your Windows 11 machine.    
2. **Navigate to the official HashiCorp Terraform downloads page**: https://developer.hashicorp.com/terraform/downloads`    
3. **Locate the Windows section**.    
4. **Download the latest stable version for `amd64` (64-bit)**. This will typically be a `.zip` file.    

**Step 2: Extract the Terraform Executable**
1. **Create a new directory** where you want to store the Terraform executable. A common practice is to create a folder like `C:\Program Files\Terraform` or `C:\terraform`. For consistency and ease of access, let's use `C:\terraform`.    
    - Open File Explorer.        
    - Navigate to your `C:` drive.        
    - Right-click and select `New` > `Folder`.        
    - Name the folder `terraform`.        
2. **Unzip the downloaded Terraform `.zip` file**.    
3. **Move the extracted `terraform.exe` file** into the `C:\terraform` directory you just created.    

**Step 3: Add Terraform to your System PATH**
This step allows you to run `terraform` commands from any directory in your Command Prompt or PowerShell.
1. **Open the Start Menu** on Windows 11.    
2. **Type `environment variables`** and select `Edit the system environment variables` from the search results. This will open the System Properties dialog.    
3. In the System Properties dialog, click the **`Environment Variables...`** button.    
4. In the Environment Variables dialog:    
    - Under "System variables" (not "User variables"), scroll down and find the variable named **`Path`**.        
    - Select `Path` and click the **`Edit...`** button.        
5. In the "Edit environment variable" dialog:    
    - Click **`New`**.        
    - Type the full path to your Terraform directory: `C:\terraform`        
    - Click **`OK`** on all open dialogs to close them and apply the changes.        

**Step 4: Verify the Installation**
1. **Open a _new_ Command Prompt or PowerShell window**. It's crucial to open a new one, as existing windows might not have the updated PATH.    
2. **Type the following command and press Enter**:
```powershell
terraform --version
```
3. You should see output similar to this (the version number will vary based on your download):
```
Terraform v1.x.x on windows_amd64
```
If you see this, Terraform is successfully installed and accessible from your command line.