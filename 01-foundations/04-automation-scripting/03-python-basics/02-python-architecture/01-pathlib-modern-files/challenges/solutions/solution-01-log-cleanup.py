"""
Solution: Log File Cleanup
"""
from pathlib import Path
import time

def cleanup_logs(log_dir, days_old=7):
    """Delete log files older than N days."""
    root = Path(log_dir)
    if not root.exists():
        return 0
        
    # Convert days to seconds
    seconds_old = days_old * 24 * 60 * 60
    current_time = time.time()
    deleted_count = 0
    
    for log_file in root.glob("*.log"):
        # Get last modified time
        mtime = log_file.stat().st_mtime
        
        if (current_time - mtime) > seconds_old:
            print(f"🗑️ Deleting old log: {log_file.name}")
            log_file.unlink()
            deleted_count += 1
            
    return deleted_count

if __name__ == "__main__":
    # cleanup_logs("./logs", 30)
    pass
