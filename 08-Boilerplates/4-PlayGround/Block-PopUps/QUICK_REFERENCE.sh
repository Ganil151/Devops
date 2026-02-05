#!/bin/bash
# Quick Reference: Browser Security Script

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                    BROWSER SECURITY HARDENING SCRIPT                         ║
║                           Quick Reference Card                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

📋 USAGE
────────────────────────────────────────────────────────────────────────────────
  Apply Security:     sudo ./block_popups.sh
  Rollback:           sudo ./block_popups.sh --rollback
  Help:               ./block_popups.sh --help

🛡️ SECURITY FEATURES APPLIED
────────────────────────────────────────────────────────────────────────────────
  Browser Level:
    ✓ Popup blocking (all browsers)
    ✓ Safe browsing (enhanced protection)
    ✓ Malware/phishing protection
    ✓ Third-party cookie blocking
    ✓ Notification blocking
    ✓ Geolocation blocking
    ✓ Camera/microphone blocking
    ✓ Extension installation restrictions
    ✓ DNS over HTTPS
    ✓ SSL error override disabled
    ✓ Malicious URL blocking

  System Level:
    ✓ DNS-level malware blocking (Cloudflare 1.1.1.2)
    ✓ Firewall rules (blocks Telnet, RPC, NetBIOS, SMB, RDP)
    ✓ SSH brute force protection (rate limiting)
    ✓ Hosts file blocking (ad/malware domains)
    ✓ IPv6 disabled (reduces attack surface)
    ✓ Automatic security updates enabled

🌐 SUPPORTED BROWSERS
────────────────────────────────────────────────────────────────────────────────
  ✓ Google Chrome
  ✓ Chromium
  ✓ Brave Browser
  ✓ Mozilla Firefox

📁 FILE LOCATIONS
────────────────────────────────────────────────────────────────────────────────
  Policies:
    Chrome:     /etc/opt/chrome/policies/managed/security_hardening.json
    Chromium:   /etc/chromium/policies/managed/security_hardening.json
    Brave:      /etc/brave/policies/managed/security_hardening.json
    Firefox:    /etc/firefox/policies/policies.json

  Logs & Backups:
    Logs:       /var/log/browser-security/security-hardening.log
    Backups:    /var/backups/browser-policies/
    DNS Config: /etc/systemd/resolved.conf.d/security.conf

🔍 VERIFICATION
────────────────────────────────────────────────────────────────────────────────
  Check Chrome Policies:    chrome://policy
  Check Firefox Policies:   about:policies
  Check Firewall:           sudo ufw status verbose
  Check DNS:                resolvectl query google.com
  Check Logs:               tail -f /var/log/browser-security/security-hardening.log

⚙️ CUSTOMIZATION
────────────────────────────────────────────────────────────────────────────────
  To allow specific sites for popups/notifications, edit policy files:
  
  Example (Chrome/Brave/Chromium):
    sudo nano /etc/opt/chrome/policies/managed/security_hardening.json
    
    Add to "PopupsAllowedForUrls": ["https://trusted-site.com"]
    Add to "NotificationsAllowedForUrls": ["https://trusted-site.com"]

  Example (Firefox):
    sudo nano /etc/firefox/policies/policies.json

🔧 TROUBLESHOOTING
────────────────────────────────────────────────────────────────────────────────
  Policies not working?
    → Restart browser completely
    → Check policy syntax: cat <policy_file> | jq
    → Verify in browser: chrome://policy or about:policies

  DNS not working?
    → Check: systemctl status systemd-resolved
    → Restart: sudo systemctl restart systemd-resolved
    → Rollback if needed

  Firewall blocking legitimate traffic?
    → List rules: sudo ufw status numbered
    → Delete rule: sudo ufw delete <number>

  Need to rollback everything?
    → Run: sudo ./block_popups.sh --rollback

🚨 IMPORTANT NOTES
────────────────────────────────────────────────────────────────────────────────
  ⚠ Must run with sudo (requires root privileges)
  ⚠ Restart all browsers after running script
  ⚠ Test browser functionality after applying
  ⚠ Backups are created automatically before changes
  ⚠ Some sites may break - whitelist as needed

📊 PROTECTION COVERAGE
────────────────────────────────────────────────────────────────────────────────
  ✓ Malvertising           ✓ Phishing attacks
  ✓ Tracking & Privacy     ✓ Malicious extensions
  ✓ Media access attacks   ✓ Network-level attacks
  ✓ MITM attacks           ✓ Drive-by downloads
  ✓ Brute force (SSH)      ✓ Common port scans

📚 DOCUMENTATION
────────────────────────────────────────────────────────────────────────────────
  Full documentation: SECURITY_ENHANCEMENTS.md
  
  For more details on specific policies, see:
    - Chrome Enterprise Policies: https://chromeenterprise.google/policies/
    - Firefox Policies: https://github.com/mozilla/policy-templates

╔══════════════════════════════════════════════════════════════════════════════╗
║  Remember: Security is a process, not a product. Keep systems updated!      ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
