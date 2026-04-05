"""
Dockerfile Validator
Description: Checks for security best practices.
"""

import sys

def scan_dockerfile(path):
    print(f"Scanning {path}...")
    issues = []
    
    try:
        with open(path, 'r') as f:
            lines = f.readlines()
            
        has_user = False
        
        for i, line in enumerate(lines):
            line = line.strip()
            
            # Check 1: Using 'latest' tag
            if line.startswith("FROM") and ":latest" in line:
                issues.append(f"Line {i+1}: Avoid using ':latest' tag. Pin versions.")
                
            # Check 2: Verify USER instruction
            if line.startswith("USER"):
                has_user = True
                
            # Check 3: Sudo usage
            if "sudo" in line:
                issues.append(f"Line {i+1}: Avoid 'sudo'.")
                
        if not has_user:
            issues.append("Global: No USER instruction found. Container may run as root.")
            
        if issues:
            print(f"\n[FAIL] Found {len(issues)} issues:")
            for issue in issues:
                print(f" - {issue}")
        else:
            print("\n[PASS] Dockerfile looks good.")
            
    except FileNotFoundError:
        print("Dockerfile not found.")

if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else "Dockerfile"
    scan_dockerfile(path)
