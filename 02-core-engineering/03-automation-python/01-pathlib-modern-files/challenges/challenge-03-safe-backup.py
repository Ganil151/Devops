"""
Challenge: Safe File Backup
Scenario: You need a utility to back up a configuration file before editing it.

TODO: Implement `backup_config(config_file, backup_dir)`.
1. Ensure the `backup_dir` exists; create it if not (use `parents=True`).
2. Construct a backup filename with a timestamp: `app_20260113_120000.yaml`.
3. Use `shutil.copy2` to copy the file (preserves metadata).
4. If there are more than 5 backups in the directory, delete the oldest one.
"""
from pathlib import Path
import shutil
from datetime import datetime

def backup_config(config_file, backup_dir):
    """
    Creates a timestamped backup and manages retention.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test
    cfg = Path("test_config.yaml")
    cfg.write_text("setting: true")
    
    backup_path = backup_config(cfg, "backups")
    print(f"Backup created at: {backup_path}")
