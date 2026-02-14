# Browser Security Hardening Script - Enhancement Summary

## Overview
The original `block_popups.sh` script has been completely rewritten into a production-grade security hardening tool that provides comprehensive browser and system-level intrusion protection.

## Key Enhancements

### 🎯 **Original Features (Enhanced)**
- ✅ **Popup Blocking** - Now with granular URL-level control
- ✅ **Multi-Browser Support** - Chrome, Chromium, Brave, **+ Firefox**

### 🛡️ **New Security Features**

#### 1. **Browser-Level Protection**
- **Safe Browsing** - Enhanced protection level 2 (maximum security)
- **Malware/Phishing Protection** - Real-time threat detection
- **Third-Party Cookie Blocking** - Privacy protection
- **Notification Blocking** - Prevents spam notifications
- **Geolocation Blocking** - Prevents location tracking
- **Media Stream Blocking** - Blocks unauthorized camera/microphone access
- **DNS over HTTPS** - Encrypted DNS queries
- **SSL Error Override Disabled** - Prevents bypassing certificate warnings
- **Extension Management** - Restricts unauthorized extension installation
- **URL Blocklist** - Blocks known ad/tracking domains
- **Download Restrictions** - Disabled (reversed)
- **Audio/Video Capture Blocking** - Prevents unauthorized media access
- **WebBluetooth/WebUSB Blocking** - Prevents device access attacks

#### 2. **System-Level Protection**

##### **DNS-Level Blocking**
- Configures **Cloudflare Malware Blocking DNS** (1.1.1.2)
- Fallback to **Quad9 DNS** (9.9.9.9) for redundancy
- Enables **DNSSEC** for DNS validation
- Enables **DNS over TLS** for encrypted DNS

##### **Firewall Rules**
- Blocks Telnet (port 23)
- Blocks MS RPC (port 135)
- Blocks NetBIOS (port 139)
- Blocks SMB (port 445)
- Blocks RDP from external (port 3389)
- Rate limits SSH (port 22) to prevent brute force attacks
- Supports both **UFW** and **firewalld**

##### **Hosts File Blocking**
- Blocks known malicious domains at the system level:
  - doubleclick.net
  - googleadservices.com
  - googlesyndication.com
  - advertising.com

##### **System Hardening**
- Disables IPv6 (reduces attack surface)
- Enables automatic security updates (if available)

### 🔧 **Operational Features**

#### **Logging & Audit Trail**
- Comprehensive logging to `/var/log/browser-security/security-hardening.log`
- Timestamped entries with severity levels (INFO, SUCCESS, WARNING, ERROR)
- Color-coded console output for easy reading

#### **Backup & Rollback**
- Automatic backup of existing policies before changes
- Backups stored in `/var/backups/browser-policies/`
- One-command rollback: `sudo ./block_popups.sh --rollback`

#### **Control Specific Services**
You can selectively skip services by adding skip flags:
```bash
# Python
sudo ./block_popups.py --skip-dns --skip-firewall

# Bash
sudo ./block_popups.sh --skip-dns --skip-firewall
```

#### **Error Handling**
- Uses `set -euo pipefail` for strict error handling
- Graceful degradation when optional features are unavailable
- Informative error messages

#### **Reporting**
- Generates detailed security report after execution
- Shows which browsers were configured
- Lists all security features applied
- Provides next steps and rollback instructions

### 📋 **Usage**

#### **Apply Security Hardening**
```bash
sudo ./block_popups.sh
```

#### **Rollback to Previous Settings**
```bash
sudo ./block_popups.sh --rollback
```

#### **Show Help (with options)**
```bash
sudo ./block_popups.sh --help
# OR
sudo ./block_popups.py --help
```

## Security Policies Applied

### **Chromium-Based Browsers (Chrome, Chromium, Brave)**

| Policy | Value | Description |
|--------|-------|-------------|
| DefaultPopupsSetting | 2 | Block all popups |
| SafeBrowsingProtectionLevel | 2 | Enhanced protection |
| BlockThirdPartyCookies | true | Privacy protection |
| DefaultNotificationsSetting | 2 | Block notifications |
| DefaultGeolocationSetting | 2 | Block location access |
| DnsOverHttpsMode | secure | Force encrypted DNS |
| SSLErrorOverrideAllowed | false | Prevent cert bypass |
| ExtensionInstallBlocklist | ["*"] | Block all extensions by default |
| AudioCaptureAllowed | false | Block microphone access |
| VideoCaptureAllowed | false | Block camera access |

### **Firefox**

| Policy | Value | Description |
|--------|-------|-------------|
| DisableTelemetry | true | Privacy protection |
| EnableTrackingProtection | true | Block trackers |
| PopupBlocking | true | Block popups |
| DNSOverHTTPS | enabled | Encrypted DNS |
| Cookies.AcceptThirdParty | never | Block 3rd party cookies |
| Permissions.Camera.BlockNewRequests | true | Block camera access |
| Permissions.Microphone.BlockNewRequests | true | Block microphone access |

## File Locations

| Type | Location |
|------|----------|
| Chrome Policies | `/etc/opt/chrome/policies/managed/security_hardening.json` |
| Chromium Policies | `/etc/chromium/policies/managed/security_hardening.json` |
| Brave Policies | `/etc/brave/policies/managed/security_hardening.json` |
| Firefox Policies | `/etc/firefox/policies/policies.json` |
| Logs | `/var/log/browser-security/security-hardening.log` |
| Backups | `/var/backups/browser-policies/` |
| DNS Config | `/etc/systemd/resolved.conf.d/security.conf` |

## Protection Against Common Intrusions

### **1. Malvertising**
- ✅ Popup blocking
- ✅ URL blocklist for ad networks
- ✅ Hosts file blocking
- ✅ DNS-level blocking

### **2. Phishing**
- ✅ Safe browsing protection
- ✅ SSL error override disabled
- ✅ Password leak detection

### **3. Tracking & Privacy**
- ✅ Third-party cookie blocking
- ✅ Geolocation blocking
- ✅ Tracking protection (Firefox)
- ✅ Fingerprinting protection (Firefox)

### **4. Malicious Extensions**
- ✅ Extension installation restricted
- ✅ Only allow specific trusted extensions

### **5. Media Access Attacks**
- ✅ Camera access blocked
- ✅ Microphone access blocked
- ✅ Media stream blocking

### **6. Network-Level Attacks**
- ✅ DNS over HTTPS/TLS
- ✅ DNSSEC validation
- ✅ Firewall rules for common attack vectors
- ✅ SSH brute force protection

### **7. Man-in-the-Middle Attacks**
- ✅ SSL error override disabled
- ✅ DNS over HTTPS/TLS
- ✅ DNSSEC validation

- ✅ **Drive-by Downloads** - Protected by safe browsing (restrictions reversed)

## Best Practices

### **After Running the Script**
1. ✅ Restart all browsers for changes to take effect
2. ✅ Review the security report in `/var/log/browser-security/`
3. ✅ Test browser functionality to ensure no breakage
4. ✅ Whitelist trusted sites if needed (edit policy files)

### **Customization**
To allow specific sites for popups, notifications, etc., edit the policy files and add URLs to the appropriate allow lists:

```json
{
  "PopupsAllowedForUrls": ["https://trusted-site.com"],
  "NotificationsAllowedForUrls": ["https://trusted-site.com"]
}
```

### **Monitoring**
- Check logs regularly: `tail -f /var/log/browser-security/security-hardening.log`
- Review firewall logs: `sudo ufw status verbose` or `sudo firewall-cmd --list-all`

## Compatibility

### **Supported Operating Systems**
- ✅ Ubuntu/Debian (with UFW)
- ✅ Fedora/RHEL/CentOS (with firewalld)
- ✅ Any Linux distribution with systemd-resolved

### **Supported Browsers**
- ✅ Google Chrome
- ✅ Chromium
- ✅ Brave Browser
- ✅ Mozilla Firefox

## Security Considerations

### **What This Script Does NOT Protect Against**
- ❌ Zero-day exploits in browsers
- ❌ Compromised browser extensions (if already installed)
- ❌ User social engineering (clicking malicious links)
- ❌ Malware already on the system
- ❌ Advanced persistent threats (APTs)

### **Additional Recommendations**
1. Keep browsers and OS updated
2. Use a reputable antivirus/antimalware solution
3. Enable full disk encryption
4. Use strong, unique passwords with a password manager
5. Enable 2FA on all accounts
6. Regular security audits
7. User security awareness training

## Troubleshooting

### **Script Fails to Run**
- Ensure you're running with `sudo`
- Check permissions: `chmod +x block_popups.sh`

### **Browser Policies Not Applied**
- Restart the browser completely
- Check policy file syntax: `cat /etc/opt/chrome/policies/managed/security_hardening.json | jq`
- Check browser policy status: `chrome://policy` (Chrome) or `about:policies` (Firefox)

### **DNS Not Working**
- Check systemd-resolved status: `systemctl status systemd-resolved`
- Test DNS: `resolvectl query google.com`
- Rollback DNS changes if needed

### **Firewall Blocking Legitimate Traffic**
- Review firewall rules: `sudo ufw status numbered`
- Remove specific rule: `sudo ufw delete <rule_number>`

## Changelog

### **Version 2.0** (Current)
- Complete rewrite from basic popup blocker
- Added comprehensive browser security policies
- Added system-level intrusion protection
- Added DNS-level blocking
- Added firewall rules
- Added logging and audit trail
- Added backup and rollback functionality
- Added detailed reporting
- Added Firefox support
- Production-grade error handling

### **Version 1.0** (Original)
- Basic popup blocking for Chrome and Brave

## License
This script is provided as-is for educational and security hardening purposes.

## Contributing
Feel free to enhance this script with additional security measures!

---

**Author**: Enhanced by Antigravity AI  
**Date**: 2026-02-02  
**Purpose**: Comprehensive browser and system security hardening
