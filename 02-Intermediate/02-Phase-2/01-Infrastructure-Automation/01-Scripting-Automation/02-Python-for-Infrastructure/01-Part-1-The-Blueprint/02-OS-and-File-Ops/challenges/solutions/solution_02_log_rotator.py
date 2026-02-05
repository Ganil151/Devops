"""
Solution: Custom Log Rotator
"""
from pathlib import Path

def rotate_logs(log_dir, keep_count=5):
    path = Path(log_dir)
    # Get all logs
    logs = list(path.glob("*.log"))
    
    # Sort by modification time (st_mtime), descending
    logs.sort(key=lambda x: x.stat().st_mtime, reverse=True)
    
    deleted_files = []
    # Files from index [keep_count:] are the old ones
    if len(logs) > keep_count:
        old_logs = logs[keep_count:]
        for old_log in old_logs:
            deleted_files.append(old_log.name)
            old_log.unlink()
            
    return deleted_files

if __name__ == "__main__":
    # Test logic
    pass
