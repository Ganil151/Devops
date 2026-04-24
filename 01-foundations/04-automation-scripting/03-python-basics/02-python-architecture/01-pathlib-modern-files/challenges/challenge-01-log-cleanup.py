"""
Challenge: Log File Cleanup
Scenario: Your application generates many log files. You need to automate 
deleting any `.log` files that haven't been modified in over 7 days.

TODO: Implement `cleanup_logs(log_dir, days_old=7)`.
1. Use `Path(log_dir).glob("*.log")` to find all log files.
2. For each file, get its modification time using `file.stat().st_mtime`.
3. Calculate the age of the file.
4. If it's older than `days_old`, delete it using `file.unlink()`.
5. Return the total number of files deleted.
"""
from pathlib import Path
from datetime import datetime, timedelta

def cleanup_logs(log_dir, days_old=7):
    """
    Deletes log files older than a certain number of days.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test setup: create some dummy files
    test_dir = Path("test_cleanup_logs")
    test_dir.mkdir(exist_ok=True)
    (test_dir / "recent.log").write_text("recent")
    
    # We can't easily mock 'old' files without os.utime, 
    # so just ensuring the logic is correct.
    deleted = cleanup_logs(test_dir, days_old=7)
    print(f"Deleted {deleted} files.")
