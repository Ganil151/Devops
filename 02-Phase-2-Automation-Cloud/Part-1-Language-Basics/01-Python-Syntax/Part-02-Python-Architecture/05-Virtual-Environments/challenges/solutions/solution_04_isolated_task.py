"""
Solution: Isolated Task Runner
"""
import subprocess
import os
import sys

def run_in_venv(venv_path, script_path):
    """Execution via direct interpreter path."""
    if os.name == 'nt':
        python_exe = os.path.join(venv_path, "Scripts", "python.exe")
    else:
        python_exe = os.path.join(venv_path, "bin", "python")
        
    if not os.path.exists(python_exe):
        print(f"Error: Venv not found at {venv_path}")
        return
        
    result = subprocess.run([python_exe, script_path], capture_output=True, text=True)
    print(result.stdout)

if __name__ == "__main__":
    # Test would require a real venv
    pass
pip
"""
