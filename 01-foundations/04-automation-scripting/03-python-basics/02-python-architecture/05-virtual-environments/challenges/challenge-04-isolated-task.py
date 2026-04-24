"""
Challenge: Isolated Task Runner
Scenario: You need to run a small Python snippet inside a specific virtual 
environment WITHOUT activating it in your current terminal.

TODO: Implement `run_in_venv(venv_path, script_path)`.
1. Construct the path to the Python executable inside `venv_path`.
2. Use `subprocess.run()` to execute `script_path` using that specific Python.
3. Capture and print the output.
"""
import subprocess
import os

def run_in_venv(venv_path, script_path):
    """
    Executes a script using the Python interpreter from a specific venv.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Assume a venv exists at 'test-env'
    with open("hello.py", "w") as f:
        f.write("import sys; print(f'Running in: {sys.prefix}')")
        
    run_in_venv("test-env", "hello.py")
