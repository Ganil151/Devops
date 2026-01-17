#!/usr/bin/env python3
"""
Name: os_operations.py
Description: Demonstrates modern file system operations using pathlib.
"""

import shutil
import subprocess
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("sys_ops")

def list_files(directory: str, extension: str = ".txt") -> None:
    """Lists files with a specific extension using Pathlib."""
    path = Path(directory)
    if not path.exists():
        logger.error(f"Directory {directory} does not exist.")
        return

    logger.info(f"Scanning {directory} for {extension} files:")
    # glob is safer and easier than os.walk for simple depth
    for file in path.glob(f"**/*{extension}"):
        logger.info(f"Found: {file.name} ({file.stat().st_size} bytes)")

def run_command(command: list) -> bool:
    """Runs a shell command safely without shell=True."""
    try:
        logger.info(f"Executing: {' '.join(command)}")
        # capture_output=True allows us to interact with stdout
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        logger.info(f"Output: {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed with exit code {e.returncode}")
        logger.error(f"Error output: {e.stderr}")
        return False
    except FileNotFoundError:
        logger.error(f"Tool not found: {command[0]}")
        return False

def backup_file(target: str) -> None:
    """Creates a backup .bak file."""
    src = Path(target)
    if not src.exists():
        logger.warning(f"File {target} not found, cannot backup.")
        return
    
    dest = src.with_suffix(src.suffix + ".bak")
    shutil.copy2(src, dest)
    logger.info(f"Backup created: {dest}")

if __name__ == "__main__":
    # Create dummy file for demo
    dummy = Path("test.txt")
    dummy.write_text("Hello World")
    
    backup_file("test.txt")
    list_files(".", ".bak")
    
    # Run a safe command (e.g., 'whoami' on Linux/Mac or 'whoami' on Windows)
    # This works cross-platform usually
    run_command(["whoami"])
    
    # Cleanup
    dummy.unlink()
    Path("test.txt.bak").unlink()
