#!/usr/bin/env python3
"""
Boilerplate: Log Rotator
DevOps Context: Managing disk usage by rotating and renaming log files.
"""
from pathlib import Path
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("Rotator")

def rotate_file(file_path):
    """
    Renames file.log -> file.log.timestamp
    """
    path = Path(file_path)
    if not path.exists():
        logger.warning(f"File {path} does not exist.")
        return

    timestamp = int(time.time())
    new_name = path.with_suffix(f".log.{timestamp}")
    
    logger.info(f"Rotating: {path.name} -> {new_name.name}")
    path.rename(new_name)
    
    # Create empty new file
    path.touch()
    logger.info("Created new empty log file.")

def main():
    # Setup dummy log
    log_file = Path("app.log")
    log_file.write_text("Log data line 1\nLog data line 2")
    
    logger.info(f"Original size: {log_file.stat().st_size} bytes")
    
    rotate_file("app.log")
    
    # Verify
    backups = list(Path(".").glob("app.log.*"))
    logger.info(f"Backups found: {[b.name for b in backups]}")
    
    # Cleanup
    log_file.unlink()
    for b in backups:
        b.unlink()

if __name__ == "__main__":
    main()
