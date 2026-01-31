#!/usr/bin/env python3
"""
Lab: The Self-Healing Daemon
Task: Monitor a mission-critical process and restart it with exponential backoff.
Focus: Reliability, Signal Handling, and JSON Logging.
"""

import subprocess
import time
import signal
import sys
import json
import logging
from datetime import datetime
from typing import NoReturn

# --- Configuration ---
MONITOR_COMMAND = ["sleep", "10"] # Example process
MAX_BACKOFF = 60 # Seconds
INITIAL_BACKOFF = 2 # Seconds
LOG_FILE = "self_healing.json"

# --- Setup Structured Logging ---
def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(message)s',
        handlers=[logging.FileHandler(LOG_FILE), logging.StreamHandler()]
    )

def log_event(status: str, message: str, **kwargs):
    """Logs events in structured JSON format for observability."""
    event = {
        "timestamp": datetime.utcnow().isoformat(),
        "status": status,
        "message": message,
        **kwargs
    }
    logging.info(json.dumps(event))

# --- Signal Handling ---
def handle_exit(signum, frame):
    log_event("SHUTDOWN", f"Received signal {signum}. Terminating daemon.")
    sys.exit(0)

signal.signal(signal.SIGINT, handle_exit)
signal.signal(signal.SIGTERM, handle_exit)

# --- Core Logic ---
def run_monitor() -> NoReturn:
    """
    Main loop with Exponential Backoff logic.
    """
    backoff = INITIAL_BACKOFF
    
    log_event("STARTING", "Self-healing watchdog initialized.", command=MONITOR_COMMAND)

    while True:
        try:
            # 🚀 Act: Launch the process
            log_event("LAUNCH", f"Starting monitored process: {' '.join(MONITOR_COMMAND)}")
            process = subprocess.Popen(MONITOR_COMMAND)
            
            # Wait for process to complete
            process.wait()
            
            # If we reach here, the process died
            log_event("FAILURE", "Process terminated unexpectedly.", exit_code=process.returncode)
            
            # 🔄 Rollback/Retry: Exponential Backoff
            log_event("RETRY_WAIT", f"Waiting {backoff} seconds before restart...")
            time.sleep(backoff)
            
            # Update backoff
            backoff = min(backoff * 2, MAX_BACKOFF)

        except Exception as e:
            log_event("CRITICAL_ERROR", str(e))
            time.sleep(5)

if __name__ == "__main__":
    setup_logging()
    run_monitor()
