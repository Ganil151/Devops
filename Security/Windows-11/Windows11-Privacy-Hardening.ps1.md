## **How to Run**

### **Method 1: Direct Execution**
1. **Right-click on Windows Start button** → Select "Windows Terminal (Admin)" or "PowerShell (Admin)"
2. **Copy the script** from the artifact above
3. **Paste and run** in the PowerShell window
4. Type **YES** to confirm
5. **Restart** your computer when done

### **Method 2: Save as File**
1. Save the script as `Windows11-Privacy-Hardening.ps1`
2. Right-click on the file → **"Run with PowerShell"**
3. If you get an execution policy error, run this first:    
 ```powershell
 Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

### **Method 3: Run from URL**
1. Open **PowerShell (Admin)**
2. Run the following command:
```powershell
# Method 1: Direct execution
& "C:\Users\ganil\Documents\Devops\Security\Windows-11\Windows11-Privacy-Hardening.ps1"

# Method 2: Using dot-sourcing
. "C:\Users\ganil\Documents\Devops\Security\Windows-11\Windows11-Privacy-Hardening.ps1"

# Method 3: If execution policy blocks it
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
& "C:\Users\ganil\Documents\Devops\Security\Windows-11\Windows11-Privacy-Hardening.ps1"
```
    

## **What This Script Does**

### **Core Features Disabled:**

✅ **Windows Recall** - AI screenshot/recording feature  
✅ **Windows Copilot** - AI assistant  
✅ **Telemetry Services** - Data collection services  
✅ **Cortana** - Voice assistant  
✅ **Location Tracking** - GPS/location services  
✅ **Activity History** - Timeline and activity tracking  
✅ **OneDrive** - Cloud sync (fully removed)  
✅ **Advertising ID** - Ad tracking  
✅ **Feedback & Experimentation** - User surveys  
✅ **Biometric Data Collection** - Face/fingerprint telemetry  
✅ **Cloud Clipboard** - Clipboard sync  
✅ **WiFi Sense** - WiFi sharing

### **Additional Protections:**

- Blocks 50+ telemetry domains in hosts file
- Creates firewall rules to block telemetry IPs
- Disables telemetry scheduled tasks
- Configures Edge privacy settings
- Disables Windows Defender sample submission

## **Safety Features**

1. **Creates System Restore Point** before making changes
2. **Color-coded output** shows what's happening
3. **Confirmation prompt** before execution
4. **Error handling** for failed operations
5. **Detailed summary** at the end

## **Important Notes**

⚠️ **Restart Required** - Changes take effect after reboot  
⚠️ **Windows Updates** - May re-enable some features  
⚠️ **Reversible** - Use System Restore to undo  
⚠️ **Admin Rights** - Must run as Administrator

## **Additional Privacy Tools**

Consider using these alongside the script:

- **O&O ShutUp10++** - GUI privacy tool
- **Simplewall** - Advanced firewall
- **Pi-hole** - Network-wide ad blocking
- **DNS over HTTPS** - Encrypted DNS

## **Verification**

After running and restarting, verify:

```powershell
# Check Recall status
Dism /Online /Get-Featureinfo /Featurename:Recall

# Check telemetry services
Get-Service DiagTrack, dmwappushservice, WerSvc

# Check hosts file
Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String "telemetry"
```

**Want me to create a version that's more or less aggressive, or add/remove specific features?**