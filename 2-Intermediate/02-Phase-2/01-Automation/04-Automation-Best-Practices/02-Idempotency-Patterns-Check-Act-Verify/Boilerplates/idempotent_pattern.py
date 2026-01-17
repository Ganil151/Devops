#!/usr/bin/env python3
"""
Name: idempotent_pattern.py
Description: Demonstrates the Check-Act-Verify pattern for file management.
"""

import os
import sys

def ensure_config_line(file_path, line):
    """
    Ensures a specific line exists in a configuration file.
    This is an IDEMPOTENT operation.
    """
    
    # 1. CHECK
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            content = f.read()
            if line in content:
                print(f"[OK] {file_path} already contains the line. No action taken.")
                return False # No change was made
    
    # 2. ACT
    print(f"[CHANGED] Writing to {file_path}...")
    with open(file_path, 'a') as f:
        f.write(line + '\n')
    
    # 3. VERIFY
    with open(file_path, 'r') as f:
        if line in f.read():
            print(f"[SUCCESS] Verified: Line is present.")
            return True
        else:
            print(f"[FAILURE] Verification failed!")
            sys.exit(1)

if __name__ == "__main__":
    target = "demo_config.conf"
    desired_line = "DEBUG_LEVEL=HIGH"
    
    # Run twice to see the patterns
    print("--- First Run ---")
    ensure_config_line(target, desired_line)
    
    print("\n--- Second Run ---")
    ensure_config_line(target, desired_line)
    
    # Cleanup
    if os.path.exists(target):
        os.remove(target)
        print("\n[CLEANUP] Demo file removed.")
