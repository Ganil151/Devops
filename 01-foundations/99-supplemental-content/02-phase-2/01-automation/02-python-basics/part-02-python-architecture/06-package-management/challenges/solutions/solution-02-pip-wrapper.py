"""
Solution: Pip Wrapper for CI
"""
import subprocess
import sys

def safe_install(package_list, log_file):
    """Execution and logging of pip commands."""
    cmd = [sys.executable, "-m", "pip", "install", "--no-cache-dir"] + package_list
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        with open(log_file, "a") as f:
            f.write(f"SUCCESS: Installed {' '.join(package_list)}\n")
        print("Installation successful.")
    except subprocess.CalledProcessError as e:
        with open(log_file, "a") as f:
            f.write(f"FAILURE: {e.stderr}\n")
        print(f"Installation failed: {e.stderr}")
        raise

if __name__ == "__main__":
    safe_install(["requests"], "ci_pip.log")
