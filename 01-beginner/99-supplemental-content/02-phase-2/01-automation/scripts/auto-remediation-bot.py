"""
Auto Remediation Bot (Mock)
Description: Watches a log file for errors and triggers remediation actions.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import time
import os
import random

LOG_FILE = "application.log"
RULES = {
    "DiskFull": "cleanup_disk",
    "ServiceDown": "restart_service",
    "ConnectionRefused": "check_firewall"
}

def cleanup_disk():
    print("[ACTION] Cleaning up temporary files...")
    # os.remove('/tmp/junk') # dangerous in mock
    return True

def restart_service():
    print("[ACTION] Restarting Application Service...")
    return True

def check_firewall():
    print("[ACTION] Verifying Firewall Rules...")
    return True

def process_log_line(line):
    for error, action_name in RULES.items():
        if error in line:
            print(f"[ALERT] Detected {error}")
            action_func = globals().get(action_name)
            if action_func:
                action_func()

def main():
    print(f"Watching {LOG_FILE} for errors ({list(RULES.keys())})...")
    print("Press Ctrl+C to stop.")
    
    # Create dummy log if not exists
    if not os.path.exists(LOG_FILE):
        with open(LOG_FILE, 'w') as f:
            f.write("System started.\n")

    # Tail the log file
    with open(LOG_FILE, 'r') as f:
        f.seek(0, 2) # Go to end
        while True:
            line = f.readline()
            if not line:
                time.sleep(0.5)
                # Mock generating an error occasionally
                if random.randint(0, 100) > 95:
                    err_type = random.choice(list(RULES.keys()))
                    with open(LOG_FILE, 'a') as log:
                        log.write(f"Error: {err_type} occurred at {time.time()}\n")
                continue
            
            print(f"[LOG] {line.strip()}")
            process_log_line(line)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nStopping Bot.")
