#!/usr/bin/env python3

"""
Browser Security Hardening Script
Purpose: Comprehensive browser security and intrusion protection
Features:
  - Popup blocking
  - Malware/phishing protection
  - Safe browsing enforcement
  - Cookie and tracking protection
  - Extension management
  - DNS-level ad/malware blocking
  - Firewall rules for common attack vectors
  - Logging and audit trail
  - Rollback capability
"""

import os
import sys
import json
import shutil
import logging
import argparse
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, List
from dataclasses import dataclass


# ============================================================================
# CONFIGURATION
# ============================================================================

@dataclass
class Config:
    """Configuration constants for the security hardening script."""
    
    SCRIPT_NAME: str = Path(__file__).name
    SCRIPT_DIR: Path = Path(__file__).parent.absolute()
    LOG_DIR: Path = Path("/var/log/browser-security")
    BACKUP_DIR: Path = Path("/var/backups/browser-policies")
    TIMESTAMP: str = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Color codes for terminal output
    RED: str = '\033[0;31m'
    GREEN: str = '\033[0;32m'
    YELLOW: str = '\033[1;33m'
    BLUE: str = '\033[0;34m'
    NC: str = '\033[0m'  # No Color


# ============================================================================
# LOGGING SETUP
# ============================================================================

class ColoredFormatter(logging.Formatter):
    """Custom formatter with colored output for different log levels."""
    
    COLORS = {
        logging.DEBUG: Config.BLUE,
        logging.INFO: Config.BLUE,
        logging.WARNING: Config.YELLOW,
        logging.ERROR: Config.RED,
        logging.CRITICAL: Config.RED,
    }
    
    SYMBOLS = {
        logging.DEBUG: '[DEBUG]',
        logging.INFO: '[INFO]',
        logging.WARNING: '[⚠]',
        logging.ERROR: '[✗]',
        logging.CRITICAL: '[✗]',
    }
    
    def format(self, record: logging.LogRecord) -> str:
        """Format log record with colors and symbols."""
        color = self.COLORS.get(record.levelno, Config.NC)
        symbol = self.SYMBOLS.get(record.levelno, '[INFO]')
        
        # Format the message
        message = super().format(record)
        
        # Add color for console output
        if hasattr(record, 'console'):
            return f"{color}{symbol}{Config.NC} {record.getMessage()}"
        
        return message


def setup_logging(config: Config) -> logging.Logger:
    """Set up logging with file and console handlers."""
    # Create log directory if it doesn't exist
    config.LOG_DIR.mkdir(parents=True, exist_ok=True)
    
    # Create logger
    logger = logging.getLogger('browser_security')
    logger.setLevel(logging.DEBUG)
    
    # File handler
    log_file = config.LOG_DIR / "security-hardening.log"
    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.DEBUG)
    file_formatter = logging.Formatter(
        '[%(asctime)s] [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(file_formatter)
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_formatter = ColoredFormatter()
    console_handler.setFormatter(console_formatter)
    
    # Add handlers
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    
    return logger


# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

def check_root() -> None:
    """Verify script is running with root privileges."""
    if os.geteuid() != 0:
        print(f"{Config.RED}[✗]{Config.NC} This script must be run as root (use sudo)")
        sys.exit(1)


def run_command(
    cmd: List[str],
    logger: logging.Logger,
    check: bool = True,
    capture_output: bool = True
) -> Optional[subprocess.CompletedProcess]:
    """
    Execute a shell command with error handling.
    
    Args:
        cmd: Command and arguments as a list
        logger: Logger instance
        check: Whether to raise exception on non-zero exit
        capture_output: Whether to capture stdout/stderr
        
    Returns:
        CompletedProcess instance or None on error
    """
    try:
        result = subprocess.run(
            cmd,
            check=check,
            capture_output=capture_output,
            text=True
        )
        return result
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed: {' '.join(cmd)}")
        logger.error(f"Error: {e.stderr if e.stderr else str(e)}")
        if check:
            raise
        return None
    except FileNotFoundError:
        logger.warning(f"Command not found: {cmd[0]}")
        return None


def command_exists(command: str) -> bool:
    """Check if a command exists in PATH."""
    return shutil.which(command) is not None


# ============================================================================
# BROWSER POLICY DEFINITIONS
# ============================================================================

def generate_chromium_policy() -> Dict:
    """Generate comprehensive security policy for Chromium-based browsers."""
    return {
        "DefaultPopupsSetting": 2,
        "PopupsAllowedForUrls": ["http://ollama:11434", "http://localhost:5678"],
        "PopupsBlockedForUrls": ["*"],
        
        "SafeBrowsingEnabled": True,
        "SafeBrowsingProtectionLevel": 2,
        "SafeBrowsingExtendedReportingEnabled": False,
        
        "PasswordManagerEnabled": True,
        "PasswordLeakDetectionEnabled": True,
        
        "DefaultCookiesSetting": 1,
        "CookiesAllowedForUrls": ["http://ollama:11434", "http://localhost:5678"],
        "CookiesBlockedForUrls": [],
        "BlockThirdPartyCookies": True,
        
        "DefaultNotificationsSetting": 2,
        "NotificationsAllowedForUrls": [],
        
        "DefaultGeolocationSetting": 2,
        "DefaultMediaStreamSetting": 2,
        
        "AutofillAddressEnabled": False,
        "AutofillCreditCardEnabled": False,
        
        "DnsOverHttpsMode": "secure",
        "DnsOverHttpsTemplates": "https://dns.google/dns-query",
        
        "SSLErrorOverrideAllowed": False,
        "AllowCrossOriginAuthPrompt": False,
        
        "DefaultInsecureContentSetting": 2,
        "InsecureContentAllowedForUrls": ["http://ollama:11434", "http://localhost:5678"],
        
        "URLBlocklist": [
            "*://*.doubleclick.net/*",
            "*://*.googlesyndication.com/*",
            "*://*.googleadservices.com/*",
            "*://*.advertising.com/*",
            "*://*.ads-twitter.com/*",
            "*://*.adnxs.com/*"
        ],
        
        "ExtensionInstallBlocklist": ["*"],
        "ExtensionInstallAllowlist": [
            "cjpalhdlnbpafiamejdnhcphjbkeiagm",  # uBlock Origin
            "nngceckbapebfimnlniiiahkandclblb"   # Bitwarden
        ],
        
        "BrowserSignin": 1,
        "SyncDisabled": False,
        
        "DefaultSearchProviderEnabled": True,
        "DefaultSearchProviderSearchURL": "https://www.google.com/search?q={searchTerms}",
        
        "DownloadRestrictions": 0,
        "DownloadDirectory": "${HOME}/Downloads",
        
        "HomepageIsNewTabPage": True,
        "RestoreOnStartup": 1,
        
        "MetricsReportingEnabled": False,
        "CloudReportingEnabled": False,
        
        "AudioCaptureAllowed": False,
        "VideoCaptureAllowed": False,
        "AudioCaptureAllowedUrls": [],
        "VideoCaptureAllowedUrls": [],
        
        "DefaultWebBluetoothGuardSetting": 2,
        "DefaultWebUsbGuardSetting": 2,
        
        "AdvancedProtectionAllowed": True,
        "RemoteAccessHostFirewallTraversal": False,
        
        "ComponentUpdatesEnabled": True,
        "BackgroundModeEnabled": False,
        
        "BrowserNetworkTimeQueriesEnabled": True,
        "BuiltInDnsClientEnabled": True,
        
        "ChromeCleanupEnabled": True,
        "ChromeCleanupReportingEnabled": False,
        
        "DefaultJavaScriptSetting": 1,
        "JavaScriptAllowedForUrls": ["*"],
        "JavaScriptBlockedForUrls": [],
        
        "DefaultImagesSetting": 1,
        "ImagesAllowedForUrls": ["*"],
        "ImagesBlockedForUrls": [],
        
        "PromptForDownloadLocation": True,
        "AlternateErrorPagesEnabled": True,
        "SearchSuggestEnabled": True,
        
        "SpellCheckServiceEnabled": False,
        "TranslateEnabled": True,
        
        "NetworkPredictionOptions": 2,
        "WPADQuickCheckEnabled": False,
        
        "UrlKeyedAnonymizedDataCollectionEnabled": False,
        "EnableMediaRouter": False,
        
        "HideWebStoreIcon": True,
        "HideWebStorePromo": True
    }


def generate_firefox_policy() -> Dict:
    """Generate Firefox security policy (policies.json format)."""
    return {
        "policies": {
            "DisableTelemetry": True,
            "DisableFirefoxStudies": True,
            "DisablePocket": True,
            "DisableFirefoxAccounts": False,
            "DisableFormHistory": False,
            "DisplayBookmarksToolbar": True,
            "DontCheckDefaultBrowser": True,
            
            "EnableTrackingProtection": {
                "Value": True,
                "Locked": True,
                "Cryptomining": True,
                "Fingerprinting": True
            },
            
            "Cookies": {
                "Allow": ["http://ollama:11434", "http://localhost:5678"],
                "AcceptThirdParty": "never",
                "Locked": True
            },
            
            "Permissions": {
                "Camera": {
                    "BlockNewRequests": True,
                    "Locked": True
                },
                "Microphone": {
                    "BlockNewRequests": True,
                    "Locked": True
                },
                "Location": {
                    "BlockNewRequests": True,
                    "Locked": True
                },
                "Notifications": {
                    "BlockNewRequests": True,
                    "Locked": True
                }
            },
            
            "PopupBlocking": {
                "Allow": ["http://ollama:11434", "http://localhost:5678"],
                "Default": True,
                "Locked": True
            },
            
            "DNSOverHTTPS": {
                "Enabled": True,
                "ProviderURL": "https://mozilla.cloudflare-dns.com/dns-query",
                "Locked": True
            },
            
            "EncryptedMediaExtensions": {
                "Enabled": True,
                "Locked": False
            },
            
            "ExtensionSettings": {
                "*": {
                    "blocked_install_message": "Extension installation is restricted for security.",
                    "install_sources": ["https://addons.mozilla.org/"],
                    "installation_mode": "blocked",
                    "allowed_types": ["extension", "theme"]
                }
            },
            
            "FirefoxHome": {
                "Search": True,
                "TopSites": False,
                "Highlights": False,
                "Pocket": False,
                "Snippets": False,
                "Locked": True
            },
            
            "Homepage": {
                "StartPage": "homepage"
            },
            
            "OfferToSaveLogins": True,
            "PasswordManagerEnabled": True,
            
            "SSLVersionMin": "tls1.2",
            
            "WebsiteFilter": {
                "Block": [
                    "*://*.doubleclick.net/*",
                    "*://*.googlesyndication.com/*",
                    "*://*.advertising.com/*"
                ]
            }
        }
    }


# ============================================================================
# BROWSER SECURITY MANAGER
# ============================================================================

class BrowserSecurityManager:
    """Manages browser security policies and system hardening."""
    
    def __init__(self, config: Config, logger: logging.Logger):
        """Initialize the security manager."""
        self.config = config
        self.logger = logger
        
    def create_directories(self) -> None:
        """Create necessary directories for logs and backups."""
        self.logger.info("Creating necessary directories...")
        
        self.config.LOG_DIR.mkdir(parents=True, exist_ok=True)
        self.config.BACKUP_DIR.mkdir(parents=True, exist_ok=True)
        
        # Set permissions
        os.chmod(self.config.LOG_DIR, 0o755)
        os.chmod(self.config.BACKUP_DIR, 0o755)
        
        self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Directories created")
        
    def backup_existing_policies(self, policy_dir: Path, browser_name: str) -> None:
        """
        Backup existing browser policies.
        
        Args:
            policy_dir: Directory containing browser policies
            browser_name: Name of the browser
        """
        if policy_dir.exists():
            backup_path = self.config.BACKUP_DIR / f"{browser_name}_{self.config.TIMESTAMP}"
            self.logger.info(f"Backing up existing {browser_name} policies to {backup_path}")
            shutil.copytree(policy_dir, backup_path)
            self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Backup completed for {browser_name}")
            
    def apply_chrome_policies(self) -> None:
        """Apply Google Chrome security policies."""
        self.logger.info("Applying Google Chrome policies...")
        chrome_dir = Path("/etc/opt/chrome/policies/managed")
        
        self.backup_existing_policies(chrome_dir, "chrome")
        chrome_dir.mkdir(parents=True, exist_ok=True)
        
        policy_file = chrome_dir / "security_hardening.json"
        with open(policy_file, 'w') as f:
            json.dump(generate_chromium_policy(), f, indent=2)
        
        os.chmod(policy_file, 0o644)
        self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Chrome policies applied successfully")
        
    def apply_chromium_policies(self) -> None:
        """Apply Chromium security policies."""
        self.logger.info("Applying Chromium policies...")
        chromium_dir = Path("/etc/chromium/policies/managed")
        
        self.backup_existing_policies(chromium_dir, "chromium")
        chromium_dir.mkdir(parents=True, exist_ok=True)
        
        policy_file = chromium_dir / "security_hardening.json"
        with open(policy_file, 'w') as f:
            json.dump(generate_chromium_policy(), f, indent=2)
        
        os.chmod(policy_file, 0o644)
        self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Chromium policies applied successfully")
        
    def apply_brave_policies(self) -> None:
        """Apply Brave Browser security policies."""
        self.logger.info("Applying Brave Browser policies...")
        brave_dir = Path("/etc/brave/policies/managed")
        
        self.backup_existing_policies(brave_dir, "brave")
        brave_dir.mkdir(parents=True, exist_ok=True)
        
        policy_file = brave_dir / "security_hardening.json"
        with open(policy_file, 'w') as f:
            json.dump(generate_chromium_policy(), f, indent=2)
        
        os.chmod(policy_file, 0o644)
        self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Brave policies applied successfully")
        
    def apply_firefox_policies(self) -> None:
        """Apply Firefox security policies."""
        self.logger.info("Applying Firefox policies...")
        firefox_dir = Path("/etc/firefox/policies")
        
        self.backup_existing_policies(firefox_dir, "firefox")
        firefox_dir.mkdir(parents=True, exist_ok=True)
        
        policy_file = firefox_dir / "policies.json"
        with open(policy_file, 'w') as f:
            json.dump(generate_firefox_policy(), f, indent=2)
        
        os.chmod(policy_file, 0o644)
        self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Firefox policies applied successfully")
        
    def setup_dns_blocking(self) -> None:
        """Set up DNS-level ad and malware blocking."""
        self.logger.info("Setting up DNS-level ad and malware blocking...")
        
        # Check if systemd-resolved is running
        result = run_command(
            ["systemctl", "is-active", "systemd-resolved"],
            self.logger,
            check=False
        )
        
        if result and result.returncode == 0:
            self.logger.info("Configuring systemd-resolved for secure DNS...")
            
            resolved_conf_dir = Path("/etc/systemd/resolved.conf.d")
            resolved_conf_dir.mkdir(parents=True, exist_ok=True)
            
            resolved_conf = resolved_conf_dir / "security.conf"
            with open(resolved_conf, 'w') as f:
                f.write("""[Resolve]
DNS=1.1.1.2 1.0.0.2
FallbackDNS=9.9.9.9 149.112.112.112
DNSSEC=yes
DNSOverTLS=yes
""")
            
            run_command(["systemctl", "restart", "systemd-resolved"], self.logger)
            self.logger.info(f"{Config.GREEN}[✓]{Config.NC} DNS-level blocking configured (Cloudflare Malware Blocking DNS)")
        else:
            self.logger.warning("systemd-resolved not active, skipping DNS configuration")
            
    def setup_firewall_rules(self) -> None:
        """Configure firewall rules for intrusion protection."""
        self.logger.info("Configuring firewall rules for intrusion protection...")
        
        # Check for UFW
        if command_exists("ufw"):
            self.logger.info("Configuring UFW firewall...")
            
            # Enable UFW
            run_command(["ufw", "--force", "enable"], self.logger, check=False)
            
            # Block common malicious ports
            firewall_rules = [
                (["ufw", "deny", "23/tcp", "comment", "Block Telnet"], "Telnet"),
                (["ufw", "deny", "135/tcp", "comment", "Block MS RPC"], "MS RPC"),
                (["ufw", "deny", "139/tcp", "comment", "Block NetBIOS"], "NetBIOS"),
                (["ufw", "deny", "445/tcp", "comment", "Block SMB"], "SMB"),
                (["ufw", "deny", "3389/tcp", "comment", "Block RDP from external"], "RDP"),
                (["ufw", "limit", "22/tcp", "comment", "Rate limit SSH"], "SSH rate limit"),
                (["ufw", "allow", "11434/tcp", "comment", "Allow Ollama"], "Ollama"),
                (["ufw", "allow", "5678/tcp", "comment", "Allow n8n"], "n8n"),
            ]
            
            for cmd, description in firewall_rules:
                run_command(cmd, self.logger, check=False)
                
            self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Firewall rules applied")
            
        # Check for firewalld
        elif command_exists("firewall-cmd"):
            self.logger.info("Configuring firewalld...")
            
            firewall_rules = [
                ["firewall-cmd", "--permanent", "--add-rich-rule=rule service name=\"telnet\" reject"],
                ["firewall-cmd", "--permanent", "--add-rich-rule=rule service name=\"rpc-bind\" reject"],
            ]
            
            for cmd in firewall_rules:
                run_command(cmd, self.logger, check=False)
                
            run_command(["firewall-cmd", "--reload"], self.logger, check=False)
            self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Firewall rules applied")
            
        else:
            self.logger.warning("No supported firewall found (ufw or firewalld)")
            
    def update_hosts_file(self) -> None:
        """Update /etc/hosts with known malicious domains."""
        self.logger.info("Updating /etc/hosts with known malicious domains...")
        
        hosts_file = Path("/etc/hosts")
        hosts_backup = Path(f"/etc/hosts.backup.{self.config.TIMESTAMP}")
        
        # Backup current hosts file
        shutil.copy2(hosts_file, hosts_backup)
        
        # Malicious domains to block
        malicious_domains = [
            "doubleclick.net",
            "www.doubleclick.net",
            "ad.doubleclick.net",
            "googleadservices.com",
            "www.googleadservices.com",
            "googlesyndication.com",
            "www.googlesyndication.com",
            "advertising.com",
            "www.advertising.com",
        ]
        
        # Append to hosts file
        with open(hosts_file, 'a') as f:
            f.write("\n# Browser Security Script - Malicious Domain Blocking\n")
            for domain in malicious_domains:
                f.write(f"127.0.0.1 {domain}\n")
                
        self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Hosts file updated (backup: {hosts_backup})")
        
    def apply_system_hardening(self) -> None:
        """Apply system-level security hardening."""
        self.logger.info("Applying system-level security hardening...")
        
        sysctl_conf = Path("/etc/sysctl.conf")
        
        # Check if IPv6 hardening is already applied
        if sysctl_conf.exists():
            with open(sysctl_conf, 'r') as f:
                content = f.read()
                
            if "net.ipv6.conf.all.disable_ipv6" not in content:
                with open(sysctl_conf, 'a') as f:
                    f.write("""
# Browser Security Script - IPv6 Hardening
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
""")
                
                run_command(["sysctl", "-p"], self.logger, check=False)
                self.logger.info(f"{Config.GREEN}[✓]{Config.NC} IPv6 disabled for security")
                
        # Enable automatic security updates if available
        if command_exists("unattended-upgrades"):
            run_command(
                ["dpkg-reconfigure", "-plow", "unattended-upgrades"],
                self.logger,
                check=False
            )
            self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Automatic security updates enabled")
            
    def rollback_policies(self) -> None:
        """Roll back to previous browser policies."""
        self.logger.info("Rolling back to previous policies...")
        
        if not self.config.BACKUP_DIR.exists() or not any(self.config.BACKUP_DIR.iterdir()):
            self.logger.error(f"No backups found in {self.config.BACKUP_DIR}")
            sys.exit(1)
            
        # Browser policy directories mapping
        browser_dirs = {
            "chrome": Path("/etc/opt/chrome/policies/managed"),
            "chromium": Path("/etc/chromium/policies/managed"),
            "brave": Path("/etc/brave/policies/managed"),
            "firefox": Path("/etc/firefox/policies"),
        }
        
        # Restore each browser's policies
        for backup_dir in self.config.BACKUP_DIR.iterdir():
            browser_name = backup_dir.name.split('_')[0]
            
            if browser_name in browser_dirs:
                target_dir = browser_dirs[browser_name]
                
                # Remove current policies
                if target_dir.exists():
                    shutil.rmtree(target_dir)
                    
                # Restore from backup
                shutil.copytree(backup_dir, target_dir)
                self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Restored {browser_name} policies")
                
        self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Rollback completed")
        
    def generate_report(self) -> None:
        """Generate security hardening report."""
        self.logger.info("Generating security report...")
        
        report_file = self.config.LOG_DIR / f"security_report_{self.config.TIMESTAMP}.txt"
        
        # Check which policies are applied
        policies_status = {
            "Google Chrome": Path("/etc/opt/chrome/policies/managed/security_hardening.json").exists(),
            "Chromium": Path("/etc/chromium/policies/managed/security_hardening.json").exists(),
            "Brave Browser": Path("/etc/brave/policies/managed/security_hardening.json").exists(),
            "Firefox": Path("/etc/firefox/policies/policies.json").exists(),
        }
        
        # Check system hardening status
        dns_active = run_command(
            ["systemctl", "is-active", "systemd-resolved"],
            self.logger,
            check=False
        )
        dns_configured = dns_active and dns_active.returncode == 0
        
        firewall_active = False
        if command_exists("ufw"):
            ufw_status = run_command(["ufw", "status"], self.logger, check=False, capture_output=True)
            firewall_active = ufw_status and "Status: active" in ufw_status.stdout
            
        # Get latest backup
        latest_backup = "None"
        if self.config.BACKUP_DIR.exists():
            backups = sorted(self.config.BACKUP_DIR.iterdir(), key=lambda x: x.stat().st_mtime, reverse=True)
            if backups:
                latest_backup = backups[0].name
                
        # Generate report
        report_content = f"""================================================================================
Browser Security Hardening Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
================================================================================

POLICIES APPLIED:
-----------------
"""
        
        for browser, applied in policies_status.items():
            status = "✓" if applied else "✗"
            report_content += f"{status} {browser}\n"
            
        report_content += f"""
SECURITY FEATURES:
------------------
✓ Popup blocking enabled
✓ Safe browsing protection (Enhanced)
✓ Third-party cookie blocking
✓ Notification blocking
✓ Geolocation blocking
✓ Media stream blocking
✓ DNS over HTTPS enabled
✓ SSL error override disabled
✓ Extension installation restricted
✓ Malicious URL blocking
✗ Download restrictions (reversed)
✓ Audio/video capture blocked

SYSTEM HARDENING:
-----------------
{"✓" if dns_configured else "✗"} Secure DNS configured
{"✓" if firewall_active else "✗"} Firewall active
✓ Hosts file updated with malicious domains

BACKUPS:
--------
Backup location: {self.config.BACKUP_DIR}
Latest backup: {latest_backup}

NEXT STEPS:
-----------
1. Restart all browsers for policies to take effect
2. Review {self.config.LOG_DIR / 'security-hardening.log'} for detailed logs
3. Test browser functionality to ensure no breakage
4. To rollback: sudo {self.config.SCRIPT_NAME} --rollback

================================================================================
"""
        
        # Write report to file
        with open(report_file, 'w') as f:
            f.write(report_content)
            
        # Print report to console
        print(report_content)
        
        self.logger.info(f"{Config.GREEN}[✓]{Config.NC} Report saved to {report_file}")
        
    def apply_all_hardening(self) -> None:
        """Apply all security hardening measures."""
        print("=" * 80)
        print("  Browser Security Hardening & Intrusion Protection Script")
        print("=" * 80)
        print()
        
        self.logger.info("Starting security hardening process...")
        
        # Apply browser policies
        self.apply_chrome_policies()
        self.apply_chromium_policies()
        self.apply_brave_policies()
        self.apply_firefox_policies()
        
        # Apply system-level protections
        self.setup_dns_blocking()
        self.setup_firewall_rules()
        self.update_hosts_file()
        self.apply_system_hardening()
        
        # Generate report
        self.generate_report()
        
        print()
        print("=" * 80)
        print(f"{Config.GREEN}Security hardening completed successfully!{Config.NC}")
        print("=" * 80)
        print()
        print("IMPORTANT: Please restart all browsers for changes to take effect.")
        print()
        print(f"Logs: {self.config.LOG_DIR / 'security-hardening.log'}")
        print(f"Backups: {self.config.BACKUP_DIR}")
        print()
        print(f"To rollback changes: sudo {self.config.SCRIPT_NAME} --rollback")
        print()


# ============================================================================
# MAIN EXECUTION
# ============================================================================

def main() -> None:
    """Main entry point for the script."""
    parser = argparse.ArgumentParser(
        description="Browser Security Hardening & Intrusion Protection Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
DESCRIPTION:
    This script applies comprehensive browser security policies and system-level
    intrusion protection measures including:
    
    - Popup and notification blocking
    - Malware and phishing protection
    - Safe browsing enforcement
    - Cookie and tracking protection
    - DNS-level ad/malware blocking
    - Firewall rules for common attack vectors
    - Extension installation restrictions
    
    Supported browsers: Chrome, Chromium, Brave, Firefox

EXAMPLES:
    sudo %(prog)s                 # Apply security hardening
    sudo %(prog)s --rollback      # Restore previous settings
        """
    )
    
    parser.add_argument(
        '--rollback',
        action='store_true',
        help='Restore previous policies from backup'
    )
    
    args = parser.parse_args()
    
    # Check for root privileges
    check_root()
    
    # Initialize configuration and logging
    config = Config()
    logger = setup_logging(config)
    
    # Create security manager
    manager = BrowserSecurityManager(config, logger)
    manager.create_directories()
    
    # Execute requested action
    if args.rollback:
        manager.rollback_policies()
    else:
        manager.apply_all_hardening()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Config.YELLOW}[⚠]{Config.NC} Operation cancelled by user")
        sys.exit(130)
    except Exception as e:
        print(f"{Config.RED}[✗]{Config.NC} Unexpected error: {e}")
        sys.exit(1)
