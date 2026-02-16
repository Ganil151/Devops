"""
Django App Tester
Description: Automates Django unit tests and basic integration checks.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import os
import sys
import subprocess

def run_tests(project_path):
    print(f"Running Django Tests in {project_path}...")
    
    manage_py = os.path.join(project_path, 'manage.py')
    if not os.path.exists(manage_py):
        print("[ERROR] manage.py not found.")
        sys.exit(1)
        
    cmd = [sys.executable, manage_py, 'test']
    
    try:
        result = subprocess.run(cmd, cwd=project_path, capture_output=True, text=True)
        print(result.stdout)
        
        if result.returncode == 0:
            print("[SUCCESS] All tests passed.")
        else:
            print("[FAILURE] Tests failed.")
            print(result.stderr)
            sys.exit(1)
            
    except Exception as e:
        print(f"[ERROR] Execution failed: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test-django-app.py <path-to-django-root>")
        sys.exit(1)
        
    run_tests(sys.argv[1])
