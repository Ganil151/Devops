"""
Solution: Portable Setup Generator
"""
import os

def generate_setup_scripts(project_name):
    """Generates cross-platform setup scripts."""
    
    # setup.sh
    sh_content = """#!/bin/bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
echo "Setup Complete!"
"""
    with open("setup.sh", "w") as f:
        f.write(sh_content)
        
    # setup.bat
    bat_content = """@echo off
python -m venv venv
call venv\\Scripts\\activate
pip install -r requirements.txt
echo Setup Complete!
"""
    with open("setup.bat", "w") as f:
        f.write(bat_content)
        
    # requirements.txt
    with open("requirements.txt", "w") as f:
        f.write("requests\\npyyaml\\n")

if __name__ == "__main__":
    generate_setup_scripts("test_project")
