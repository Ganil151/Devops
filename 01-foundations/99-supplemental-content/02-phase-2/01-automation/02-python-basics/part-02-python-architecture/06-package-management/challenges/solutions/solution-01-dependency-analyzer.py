"""
Solution: Dependency Security Whitelist
"""
import re

def verify_packages(req_file, whitelist):
    """Verifies requirements against an approved list."""
    violations = []
    whitelist_lower = [pkg.lower() for pkg in whitelist]
    
    with open(req_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            
            # Use regex to get the name before any version specifier
            # Matches start of line until it hits ==, >=, <=, ~, >, <, ! or [
            match = re.split(r'[=<>~!\[]', line)[0].strip()
            
            if match.lower() not in whitelist_lower:
                violations.append(match)
                
    return violations

if __name__ == "__main__":
    allowed = ["requests", "boto3", "pyyaml"]
    print(verify_packages("requirements.txt", allowed))
