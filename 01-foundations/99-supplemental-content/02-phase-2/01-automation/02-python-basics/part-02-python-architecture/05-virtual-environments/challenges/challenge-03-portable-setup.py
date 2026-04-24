"""
Challenge: Portable Setup Generator
Scenario: You want to provide a single script that users can run to set 
up their environment, regardless of their OS.

TODO: Implement `generate_setup_scripts(project_name)`.
1. Create a file named `setup.sh` (for Linux/Mac).
   - Content should: Create venv, activate it, install requirements.
2. Create a file named `setup.bat` (for Windows).
   - Content should do the same using Windows commands.
3. Write a `requirements.txt` with `requests` and `pyyaml`.
"""
import os

def generate_setup_scripts(project_name):
    """
    Generates cross-platform setup scripts.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    generate_setup_scripts("my_new_app")
pip
"""
