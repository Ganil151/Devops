#!/usr/bin/env python3
"""
Name: atomic_write.py
Description: Demonstrates how to update a file safely without risking corruption.
"""

import os
import tempfile
import sys

def safe_update_config(target_file, content):
    """
    Updates a file using a temporary staging area to ensure atomicity.
    """
    directory = os.path.dirname(target_file) or "."
    
    # 1. PRE-FLIGHT (Check if we have write permission)
    if os.path.exists(target_file) and not os.access(target_file, os.W_OK):
        print(f"ERROR: No write permission for {target_file}")
        sys.exit(1)

    # 2. ACT (Write to temporary file)
    # mkstemp returns (file_descriptor, absolute_path)
    fd, temp_path = tempfile.mkstemp(dir=directory, text=True, prefix="tmp_")
    
    try:
        with os.fdopen(fd, 'w') as tmp:
            print(f"Stage 1: Writing new content to temp file: {temp_path}")
            tmp.write(content)
            # Simulate heavy work or potential crash
            # if True: raise Exception("Crash during write!")

        # 3. ATOMIC REPLACE (The 'Switch')
        print(f"Stage 2: Atomically replacing {target_file}")
        os.replace(temp_path, target_file)
        print("Stage 3: Success!")
        
    except Exception as e:
        print(f"CRITICAL: Failed during update! {e}")
        # CLEANUP
        if os.path.exists(temp_path):
            os.remove(temp_path)
        sys.exit(1)

if __name__ == "__main__":
    TARGET = "production.conf"
    NEW_DATA = "VERSION=2.0\nSTATUS=ACTIVE"
    
    # Create initial file
    with open(TARGET, "w") as f: f.write("VERSION=1.0")
    
    safe_update_config(TARGET, NEW_DATA)
    
    # Verify
    with open(TARGET, "r") as f:
        print(f"\nFinal content of {TARGET}:\n{f.read()}")
    
    # Clean up demo
    os.remove(TARGET)
