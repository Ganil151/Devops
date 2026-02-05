"""
Solution: Requirements Checker
"""
import subprocess
import sys

def check_requirements(req_file):
    """Compares installed packages with requirements.txt."""
    # Get current installed packages
    result = subprocess.run([sys.executable, "-m", "pip", "freeze"], capture_output=True, text=True)
    installed = {}
    for line in result.stdout.splitlines():
        if '==' in line:
            name, ver = line.split('==')
            installed[name.lower()] = ver
            
    mismatches = []
    with open(req_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            
            if '==' in line:
                req_name, req_ver = line.split('==')
                req_name = req_name.lower()
                if req_name not in installed:
                    mismatches.append(f"Missing: {req_name}")
                elif installed[req_name] != req_ver:
                    mismatches.append(f"Version Mismatch: {req_name} (Got {installed[req_name]}, Need {req_ver})")
            else:
                # Simple package name check
                req_name = line.lower()
                if req_name not in installed:
                    mismatches.append(f"Missing: {req_name}")
                    
    return mismatches

if __name__ == "__main__":
    print(check_requirements("test_reqs.txt"))
