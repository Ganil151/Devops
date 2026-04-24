"""
Challenge: Virtual Environment Creator
Scenario: You want to automate the setup of new Python projects. Instead of 
typing commands manually, you need a script that handles it for you.

TODO: Implement `create_env(env_name, packages)`.
1. Use the `venv` module to create a new virtual environment.
2. Determine the path to the `pip` executable within that venv (handle Windows vs Linux).
3. Use `subprocess.run()` to install the list of `packages`.
4. Print the activation command for the user.
"""
import venv
import subprocess
import os
import sys

def create_env(env_name, packages):
    """
    Creates a venv and installs specified packages.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    create_env("test-env", ["requests", "pyyaml"])
