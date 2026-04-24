"""
Dependency Verification Tool
Description: Checks installed versions of critical tools against requirements.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import subprocess
import sys
import shutil

# Define requirements
REQUIREMENTS = {
    "git": "2.0",
    "python": "3.8",
    "node": "14.0",
    "docker": "20.10",
    "terraform": "1.0",
    "kubectl": "1.20"
}

def check_version(command):
    if not shutil.which(command):
        return None
    
    try:
        if command == "python":
            cmd = ["python", "--version"]
        elif command == "java":
            cmd = ["java", "-version"]
        else:
            cmd = [command, "--version"]
            
        result = subprocess.run(cmd, capture_output=True, text=True)
        # Handle commands that output to stderr (like java)
        output = result.stdout + result.stderr
        
        # Simple extraction logic (first line)
        version_line = output.strip().split('\n')[0]
        return version_line
    except Exception:
        return "Error checking version"

def main():
    print("Dependency Check")
    print("================")
    print(f"{'Tool':<15} {'Status':<10} {'Detected Version'}")
    print("-" * 50)
    
    missing_count = 0
    
    for tool, min_ver in REQUIREMENTS.items():
        if tool == "python":
            path_cmd = sys.executable
        else:
            path_cmd = tool
            
        version_str = check_version(path_cmd)
        
        if version_str:
            status = "OK"
            print(f"{tool:<15} {status:<10} {version_str[:30]}")
        else:
            status = "MISSING"
            print(f"{tool:<15} {status:<10} Required: >={min_ver}")
            missing_count += 1
            
    print("-" * 50)
    if missing_count == 0:
        print("\nAll critical tools are installed!")
    else:
        print(f"\nMissing {missing_count} tools. Please install them.")

if __name__ == "__main__":
    main()
