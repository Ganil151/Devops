#!/usr/bin/env python3
"""
Name: logging_setup.py
Description: Demonstrates production-grade logging with multiple handlers.
"""

import logging
import sys
from datetime import datetime

def setup_automation_logger(script_name):
    """
    Creates a logger that writes to BOTH console and a log file.
    """
    logger = logging.getLogger(script_name)
    logger.setLevel(logging.DEBUG) # Catch everything

    # 1. Console Handler (Pretty output for humans)
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO) # Only show INFO+ to console
    console_formatter = logging.Formatter('%(levelname)s: %(message)s')
    console_handler.setFormatter(console_formatter)

    # 2. File Handler (Detailed output for debugging)
    log_filename = f"{script_name}_{datetime.now().strftime('%Y%m%d')}.log"
    file_handler = logging.FileHandler(log_filename)
    file_handler.setLevel(logging.DEBUG) # Log EVERYTHING to the file
    file_formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(name)s: %(message)s')
    file_handler.setFormatter(file_formatter)

    # Add handlers to the logger
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    
    return logger

if __name__ == "__main__":
    log = setup_automation_logger("backup_script")

    log.info("Starting the backup process...")
    log.debug("Initializing connection to S3...")
    
    # Simulate work
    log.warning("Disk space is below 20% on /var/backups")
    
    try:
        # Simulate a crash
        # 1 / 0
        log.info("Backup uploaded to s3://my-bucket/backup.tar.gz")
    except Exception as e:
        log.error(f"FATAL ERROR during backup: {e}", exc_info=True)
    
    print(f"\n[INFO] Check the local directory for the log file!")
