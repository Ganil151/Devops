"""
Challenge: Custom Log Rotator
Scenario: You have a directory of log files. You need to keep only the 
5 most recent logs and delete the rest to save space.

TODO: Implement `rotate_logs(log_dir, keep_count=5)`.
1. List all files in `log_dir` ending in `.log`.
2. Sort the files by their modification time (most recent first).
3. Identify files that fall outside the `keep_count` range.
4. Delete those files using `Path.unlink()`.
5. Return the list of deleted filenames.
"""
import os
import time
from pathlib import Path

def rotate_logs(log_dir, keep_count=5):
    """
    Deletes older log files, keeping only the most recent N.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Setup test logs
    log_path = Path("logs_demo")
    log_path.mkdir(exist_ok=True)
    for i in range(10):
        (log_path / f"app_{i}.log").write_text("log data")
        time.sleep(0.01) # Ensure different modification times
        
    deleted = rotate_logs(log_path, keep_count=5)
    print(f"Deleted files: {deleted}")
    print(f"Remaining: {len(list(log_path.glob('*.log')))}")
