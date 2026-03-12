"""
Challenge: Dependency Security Whitelist
Scenario: Your company only allows a specific set of verified Python 
packages. You need a script that checks a `requirements.txt` file against 
this whitelist.

TODO: Implement `verify_packages(req_file, whitelist)`.
1. Read the `req_file`.
2. Extract the package name (everything before `==`, `>=`, etc.).
3. If any package is NOT in the `whitelist`, add it to a `violations` list.
4. Return the list of violations.
"""

def verify_packages(req_file, whitelist):
    """
    Checks if all packages in requirements.txt are in the allowed whitelist.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    allowed = ["requests", "boto3", "pyyaml", "pandas"]
    
    with open("requirements.txt", "w") as f:
        f.write("requests==2.31.0\n")
        f.write("flask>=2.0\n")  # Not in whitelist
        f.write("pyyaml\n")
        
    violations = verify_packages("requirements.txt", allowed)
    print(f"Forbidden packages found: {violations}")
