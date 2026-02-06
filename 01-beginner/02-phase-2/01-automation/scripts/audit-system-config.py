"""
System Config Auditor
Description: Snapshots system state (packages, configs) to JSON.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import os
import json
import subprocess
import platform
import datetime

OUTPUT_FILE = f"system_audit_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

def get_os_info():
    return {
        "system": platform.system(),
        "release": platform.release(),
        "version": platform.version()
    }

def get_installed_packages():
    # Simple check for pip packages as an example
    try:
        result = subprocess.run([sys.executable, "-m", "pip", "list", "--format=json"], capture_output=True, text=True)
        return json.loads(result.stdout)
    except:
        return []

def get_env_vars():
    # Filter sensitive vars in production
    return dict(os.environ)

def main():
    print("Starting System Audit...")
    
    audit_data = {
        "timestamp": str(datetime.datetime.now()),
        "os_info": get_os_info(),
        "env_vars": get_env_vars(),
        "python_packages": get_installed_packages()
    }
    
    with open(OUTPUT_FILE, 'w') as f:
        json.dump(audit_data, f, indent=4)
        
    print(f"Audit Complete. Saved to {OUTPUT_FILE}")

import sys
if __name__ == "__main__":
    main()
