"""
Challenge: Pip Wrapper for CI
Scenario: You want to ensure that all `pip install` commands in your 
CI pipeline always use the `--no-cache-dir` flag and log their output 
to a central file.

TODO: Implement `safe_install(package_list, log_file)`.
1. Construct the command: `python -m pip install --no-cache-dir <packages>`.
2. Run it using `subprocess.run()`.
3. If successful, log "SUCCESS: Installed <packages>" to `log_file`.
4. If it fails, log "FAILURE: <error message>" and raise an exception.
"""
import subprocess
import logging

def safe_install(package_list, log_file):
    """
    Installs packages with safety flags and logging.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    safe_install(["requests", "pyyaml"], "install_history.log")
