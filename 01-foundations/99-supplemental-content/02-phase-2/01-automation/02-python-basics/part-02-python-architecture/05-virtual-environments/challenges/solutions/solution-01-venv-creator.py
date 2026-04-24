"""
Solution: Virtual Environment Creator
"""
import venv
import subprocess
import os
import sys

def create_env(env_name, packages):
    """Creates a venv and installs packages via pip."""
    print(f"Creating environment: {env_name}...")
    venv.create(env_name, with_pip=True)
    
    # Path to pip
    if os.name == 'nt': # Windows
        pip_path = os.path.join(env_name, 'Scripts', 'pip.exe')
        activate_msg = f"{env_name}\\Scripts\\activate"
    else: # Linux / Mac
        pip_path = os.path.join(env_name, 'bin', 'pip')
        activate_msg = f"source {env_name}/bin/activate"
        
    if packages:
        print(f"Installing packages: {packages}...")
        subprocess.run([pip_path, "install"] + packages, check=True)
        
    print(f"\nSuccess! To activate, run:\n{activate_msg}")

if __name__ == "__main__":
    create_env("my-dev-env", ["requests"])
