"""
Challenge: Requirements Checker
Scenario: You have a `requirements.txt` file and you want to verify that 
your current environment has these exact packages installed.

TODO: Implement `check_requirements(req_file)`.
1. Read the `req_file` line by line.
2. For each line (e.g., `requests==2.31.0`), parse the package name and version.
3. Use `subprocess.run(["pip", "show", package_name])` or `pip freeze` to check 
   the installed version.
4. Return a list of mismatches or missing packages.
"""
import subprocess
import sys

def check_requirements(req_file):
    """
    Checks if the current environment matches the requirements file.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Create a dummy requirements.txt for testing
    with open("test_reqs.txt", "w") as f:
        f.write("requests==99.9.9\n") # This should fail
        f.write("pip\n")
        
    mismatches = check_requirements("test_reqs.txt")
    print(f"Mismatches found: {mismatches}")
