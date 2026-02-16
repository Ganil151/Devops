"""
Logging Demo: Enterprise Audit & Alert System
---------------------------------------------
This script demonstrates the "Flight Recorder" pattern for production DevOps:
1. Dual Handlers: Log to Console (INFO+) and File (DEBUG+).
2. Log Rotation: Automatically manage log file size to prevent disk exhaustion.
3. Exception Tracking: Capture full stack traces automatically with logger.exception().
"""

import logging
from logging.handlers import RotatingFileHandler
import os

def setup_enterprise_logger(logger_name: str) -> logging.Logger:
    """
    Configures a professional logger with dual output and rotation.
    """
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.DEBUG) # Collect everything at the root level

    # 1. Console Handler (Standard Output)
    # We show INFO and above to the human running the script.
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_formatter = logging.Formatter("%(levelname)s: %(message)s")
    console_handler.setFormatter(console_formatter)

    # 2. Rotating File Handler (Persistent Audit)
    # We save EVERYTHING (DEBUG+) for investigation and rotate at 2KB for demo.
    log_file = "service_audit.log"
    file_handler = RotatingFileHandler(
        log_file, 
        maxBytes=2048, # 2KB rotation for visibility in this demo
        backupCount=3  # Keep 3 old log files
    )
    file_handler.setLevel(logging.DEBUG)
    file_formatter = logging.Formatter("%(asctime)s [%(levelname)s] (%(name)s): %(message)s")
    file_handler.setFormatter(file_formatter)

    # 3. Attach handlers to the logger
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    
    return logger

def perform_system_update(logger: logging.Logger):
    """
    Simulates a sequence of typical DevOps tasks with varying log levels.
    """
    logger.info("INIT: System update sequence started.")
    
    logger.debug("Establishing secure tunnel to 'deploy-gateway-01'...")
    logger.info("Tunnel established. Checking current package versions...")

    # Simulating a minor warning
    disk_usage = 82
    if disk_usage > 80:
        logger.warning(f"High Disk Usage: Root partition at {disk_usage}%. Cleanup recommended.")

    logger.debug("Metadata synchronization in progress...")
    logger.info("✓ System packages are up to date.")

    # Simulating a Critical Error with Traceback
    print("\n--- Triggering a Simulated System Fault ---")
    try:
        # Code that fails
        malformed_config = None
        malformed_config.get("api_key") # This will raise AttributeError
    except Exception:
        # logger.exception automatically includes the full Traceback!
        logger.exception("CRITICAL: Failed to load configuration object!")

# --- Execution ---
if __name__ == "__main__":
    # Clean up previous runs
    if os.path.exists("service_audit.log"):
        os.remove("service_audit.log")

    # 1. Setup
    audit_logger = setup_enterprise_logger("system-updater")
    
    # 2. Run logic
    perform_system_update(audit_logger)
    
    print(f"\nAudit complete.")
    print(f"Check the local directory for 'service_audit.log' to see the detailed debug trail.")
