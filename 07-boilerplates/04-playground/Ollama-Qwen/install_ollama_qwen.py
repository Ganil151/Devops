#!/usr/bin/env python3
"""
Ollama & Qwen Installer for Fedora (Bare Metal)
Persona: Principal AI Product & UX Engineer
Optimization: User Intent Alignment / Conversational Fluidity
"""

import subprocess
import sys
import os
import shutil

# --- UX Configuration ---
COLORS = {
    "INFO": "\033[94m",
    "SUCCESS": "\033[92m",
    "WARNING": "\033[93m",
    "ERROR": "\033[91m",
    "RESET": "\033[0m",
    "BOLD": "\033[1m"
}

MODEL_NAME = "qwen2.5"  # Stable, performant version of Qwen

def log(level, message):
    """Standardized logging for consistent UX."""
    color = COLORS.get(level, COLORS["RESET"])
    print(f"{color}{COLORS['BOLD']}[{level}]{COLORS['RESET']} {message}")

def check_root():
    """Ensure script runs with necessary privileges."""
    if os.geteuid() != 0:
        log("ERROR", "This script requires root privileges (sudo).")
        log("INFO", "Please run: sudo python3 install_ollama_qwen.py")
        sys.exit(1)

def check_command(cmd):
    """Check if a command exists in PATH."""
    return shutil.which(cmd) is not None

def run_command(command, shell=False):
    """Execute command with error handling."""
    try:
        result = subprocess.run(
            command, 
            shell=shell, 
            check=True, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            text=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        log("ERROR", f"Command failed: {e.cmd}")
        log("ERROR", f"Details: {e.stderr}")
        return None

def install_dependencies():
    """Install necessary system tools via dnf."""
    log("INFO", "Checking system dependencies (dnf, curl, systemd)...")
    # Fedora usually has these, but ensuring curl is present is key for Ollama
    if not check_command("curl"):
        log("INFO", "Installing curl...")
        run_command("dnf install -y curl", shell=True)
    log("SUCCESS", "Dependencies verified.")

def install_ollama():
    """Install Ollama using the official install script."""
    log("INFO", "Downloading and running Ollama install script...")
    # Using the official script ensures latest compatibility with Fedora kernels
    success = run_command("curl -fsSL https://ollama.com/install.sh | sh", shell=True)
    
    if success is not None or os.path.exists("/usr/local/bin/ollama"):
        log("SUCCESS", "Ollama binary installed.")
    else:
        log("ERROR", "Ollama installation failed. Check network or permissions.")
        sys.exit(1)

def configure_service():
    """Enable and start the Ollama systemd service."""
    log("INFO", "Configuring systemd service...")
    run_command("systemctl daemon-reload", shell=True)
    run_command("systemctl enable ollama", shell=True)
    run_command("systemctl start ollama", shell=True)
    
    # Verify service status
    status = run_command("systemctl is-active ollama", shell=True)
    if status == "active":
        log("SUCCESS", "Ollama service is running.")
    else:
        log("WARNING", "Ollama service status: {}. Attempting to continue...".format(status))

def pull_model():
    """Pull the specified Qwen model."""
    log("INFO", f"Pulling model: {MODEL_NAME} (this may take a few minutes)...")
    # Run as current user (not root) if possible, but ollama CLI usually handles permissions
    # For bare metal root script, we run directly.
    result = run_command(f"ollama pull {MODEL_NAME}", shell=True)
    
    if result is not None:
        log("SUCCESS", f"Model {MODEL_NAME} ready for use.")
    else:
        log("WARNING", "Model pull encountered issues. You may need to run 'ollama pull {}' manually.".format(MODEL_NAME))

def verify_installation():
    """Final UX check."""
    log("INFO", "Running verification prompt...")
    test_prompt = "ollama run {} 'Say hello, I am ready.'".format(MODEL_NAME)
    # We don't capture output here to let the user see the stream, just check exit code
    result = subprocess.run(test_prompt, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    if result.returncode == 0:
        log("SUCCESS", "✅ Installation Complete! You can now use Ollama.")
        log("INFO", "Usage: ollama run {}".format(MODEL_NAME))
    else:
        log("WARNING", "Verification failed. Please check 'journalctl -u ollama' for logs.")

def main():
    print(f"{COLORS['BOLD']}=== Fedora Ollama & Qwen Setup ==={COLORS['RESET']}\n")
    
    # 1. Permission Check
    check_root()
    
    # 2. Dependencies
    install_dependencies()
    
    # 3. Core Install
    install_ollama()
    
    # 4. Service Config
    configure_service()
    
    # 5. Model Pull
    pull_model()
    
    # 6. Verification
    verify_installation()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log("WARNING", "Installation interrupted by user.")
        sys.exit(130)
    except Exception as e:
        log("ERROR", f"Unexpected error: {e}")
        sys.exit(1)
